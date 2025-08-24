--[[
    ANTI-RAGDOLL ANTI-KNOCKBACK VIP ULTRA ROBUSTO
    - Español en GUI y mensajes.
    - Evita 100% ragdoll, stun, knockback, física, platformstand, sit, gettingup, fallingdown.
    - Puedes recibir daño y moverte/jugar normal, pero JAMÁS te tumban.
    - Hotkey Ctrl+R para activar/desactivar. F4 para mostrar/ocultar GUI.
    - Auto-respawn compatible.
    - GUI pequeña, draggable y visualmente clara.
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
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    disconnectAll()

    -- Estados peligrosos a bloquear
    local blockStates = {
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.Physics] = true,
        [Enum.HumanoidStateType.PlatformStand] = true,
        [Enum.HumanoidStateType.FallingDown] = true,
        [Enum.HumanoidStateType.GettingUp] = true,
        [Enum.HumanoidStateType.Seated] = true
    }

    -- Reparación cada frame
    table.insert(allConns, RunService.Heartbeat:Connect(function()
        if not enabled then return end
        -- Forzar estado "Running" si intentan tumbarte
        local state = humanoid:GetState()
        if blockStates[state] then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if humanoid.Sit then humanoid.Sit = false end
        -- Limitar velocities físicas pero permitir saltos
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        root.AssemblyLinearVelocity = Vector3.new(
            math.clamp(root.AssemblyLinearVelocity.X, -35, 35),
            root.AssemblyLinearVelocity.Y, -- permite saltos normales
            math.clamp(root.AssemblyLinearVelocity.Z, -35, 35)
        )
    end))

    -- Reparación en cambios de estado
    table.insert(allConns, humanoid.StateChanged:Connect(function(_, newState)
        if not enabled then return end
        if blockStates[newState] then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end))

    -- Reparación en cambios de propiedades peligrosas
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
    frame.Size = UDim2.new(0, 210, 0, 65)
    frame.Position = UDim2.new(0, 38, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(32, 38, 54)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Text = "Anti-Ragdoll/Knock VIP"

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.9, 0, 0, 23)
    toggle.Position = UDim2.new(0.05, 0, 0, 29)
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
    info.Position = UDim2.new(0, 0, 0, 54)
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
        print(enabled and "🟢 Anti-Ragdoll/Knock ACTIVADO" or "🔴 Anti-Ragdoll/Knock DESACTIVADO")
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

print("🛡️ Anti-Ragdoll/Knockback VIP Ultra Robusto ACTIVADO: NO te pueden tumbar ni dejar ragdoll, aunque te peguen.")
