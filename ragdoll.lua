--[[
    ANTI-RAGDOLL/ANTI-KNOCKBACK VIP para Steal a Brainrot/Da Hood y similares.
    - No te tumba ningún golpe, explosión ni stun.
    - Permite moverse, saltar y morir normalmente.
    - GUI pequeña, draggable, SIEMPRE funcional.
    - Ctrl+R activa/desactiva protección, F4 muestra/oculta GUI.
    - Respawn automático.
    - 100% compatible Synapse X, Fluxus, Hydrogen, Electron, etc.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local enabled = true
local guiVisible = true

-- Limpia conexiones previas
local allConns = {}
local function disconnectAll()
    for _,c in pairs(allConns) do
        if c and typeof(c)=="RBXScriptConnection" and c.Connected then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(allConns)
end

-- Protección anti-ragdoll/knockback
local function blockRagdoll()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid",3)
    local root = char:WaitForChild("HumanoidRootPart",3)
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

    -- Reparación cada frame (sin afectar movimiento normal)
    table.insert(allConns, RunService.Stepped:Connect(function()
        if not enabled then return end
        local state = humanoid:GetState()
        if blockStates[state] then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if humanoid.Sit then humanoid.Sit = false end
        -- Limita knockback físico sin quitar saltos ni el movimiento
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        -- Permite saltar y moverse, solo bloquea empuje excesivo:
        root.AssemblyLinearVelocity = Vector3.new(
            math.clamp(root.AssemblyLinearVelocity.X, -38, 38),
            root.AssemblyLinearVelocity.Y,
            math.clamp(root.AssemblyLinearVelocity.Z, -38, 38)
        )
    end))

    -- Reparación en eventos de cambio de estado
    table.insert(allConns, humanoid.StateChanged:Connect(function(_, newState)
        if not enabled then return end
        if blockStates[newState] then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end))
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
    local guiName = "AntiRagdollBrainrotMiniGUI"
    local gui = game:GetService("CoreGui"):FindFirstChild(guiName)
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = guiName
    gui.Parent = game:GetService("CoreGui")
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
    title.Text = "Anti-Ragdoll Brainrot VIP"

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
        local guiName = "AntiRagdollBrainrotMiniGUI"
        local gui = game:GetService("CoreGui"):FindFirstChild(guiName)
        if gui then gui.Enabled = guiVisible end
    end
end)

print("🛡️ Anti-Ragdoll/Knockback VIP para Steal a Brainrot/Da Hood ACTIVADO: no te pueden tumbar aunque te peguen.")
