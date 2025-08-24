--[[ 
    ANTI-RAGDOLL ULTRA ROBUSTO
    - Español en GUI y mensajes.
    - No te caes, no te tumban, no te quedas ragdoll ni physics ni platformstand.
    - Puedes moverte, saltar, correr y recibir daño normalmente.
    - Hotkey Ctrl+R para activar/desactivar. F4 para mostrar/ocultar GUI.
    - Compatible con respawn y casi todos los juegos.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local enabled = true
local guiVisible = true

local allConns = {}
local function disconnectAll()
    for _,c in pairs(allConns) do
        if c and c.Connected then pcall(function() c:Disconnect() end) end
    end
    table.clear(allConns)
end

local function blockRagdoll()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    disconnectAll()

    -- Lista de estados peligrosos
    local blockStates = {
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.Physics] = true,
        [Enum.HumanoidStateType.PlatformStand] = true,
        [Enum.HumanoidStateType.FallingDown] = true,
        [Enum.HumanoidStateType.GettingUp] = true,
        [Enum.HumanoidStateType.Seated] = true
    }

    -- Reparación instantánea (cada frame)
    table.insert(allConns, RunService.Heartbeat:Connect(function()
        if not enabled then return end
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if humanoid.Sit then humanoid.Sit = false end
        local state = humanoid:GetState()
        if blockStates[state] then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        -- Además, limpia velocidades físicas pero permite saltos y movimiento
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyAngularVelocity = Vector3.new(0,0,0)
            -- Permite saltos, pero limita el empuje en XZ
            root.AssemblyLinearVelocity = Vector3.new(
                math.clamp(root.AssemblyLinearVelocity.X, -32, 32),
                root.AssemblyLinearVelocity.Y,
                math.clamp(root.AssemblyLinearVelocity.Z, -32, 32)
            )
        end
    end))

    -- Reparación en cambios de estado
    table.insert(allConns, humanoid.StateChanged:Connect(function(_, newState)
        if not enabled then return end
        if blockStates[newState] then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end))

    -- Reparación en propiedades
    table.insert(allConns, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if enabled and humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
    end))
    table.insert(allConns, humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if enabled and humanoid.Sit then
            humanoid.Sit = false
        end
    end))
end

-----------------------
-- GUI Minimalista
-----------------------
local function createMiniGUI()
    local guiName = "AntiRagdollMiniGUI"
    local gui = game:GetService("CoreGui"):FindFirstChild(guiName) or player.PlayerGui:FindFirstChild(guiName)
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = guiName
    gui.Parent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or player.PlayerGui
    gui.ResetOnSpawn = false
    gui.Enabled = guiVisible

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 195, 0, 60)
    frame.Position = UDim2.new(0, 32, 0, 96)
    frame.BackgroundColor3 = Color3.fromRGB(32, 38, 54)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 15
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Text = "Anti-Ragdoll VIP"

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.89, 0, 0, 22)
    toggle.Position = UDim2.new(0.055, 0, 0, 27)
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,255,100) or Color3.fromRGB(190,60,60)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.Code
    toggle.TextSize = 13
    toggle.Text = enabled and "PROTECCIÓN ACTIVADA" or "PROTECCIÓN DESACTIVADA"
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "PROTECCIÓN ACTIVADA" or "PROTECCIÓN DESACTIVADA"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,255,100) or Color3.fromRGB(190,60,60)
        if enabled then blockRagdoll() else disconnectAll() end
    end)

    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, 0, 0, 15)
    info.Position = UDim2.new(0, 0, 0, 51)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Code
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(160, 200, 255)
    info.Text = "Ctrl+R: activar/desactivar | F4: mostrar/ocultar"
end

----------------------
-- Respawn y Hotkeys
----------------------
player.CharacterAdded:Connect(function()
    wait(1)
    if enabled then blockRagdoll() end
    createMiniGUI()
end)

if player.Character then blockRagdoll() end
createMiniGUI()

-- Hotkey Ctrl+R para activar/desactivar
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        enabled = not enabled
        print(enabled and "🟢 Anti-Ragdoll ACTIVADO" or "🔴 Anti-Ragdoll DESACTIVADO")
        if enabled then blockRagdoll() else disconnectAll() end
        createMiniGUI()
    end
    -- F4 para mostrar/ocultar GUI
    if input.KeyCode == Enum.KeyCode.F4 then
        guiVisible = not guiVisible
        local guiName = "AntiRagdollMiniGUI"
        local gui = game:GetService("CoreGui"):FindFirstChild(guiName) or player.PlayerGui:FindFirstChild(guiName)
        if gui then gui.Enabled = guiVisible end
    end
end)

print("🛡️ Anti-Ragdoll Ultra Robusto ACTIVADO: puedes ser golpeado pero jamás caerás ni entrarás en ragdoll.")
