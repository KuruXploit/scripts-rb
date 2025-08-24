-- BlueSpeed + Súper Salto ULTRA ROBUSTO (con GUI pequeña y discreta)
-- Español en la GUI y mensajes, variables en inglés

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración inicial
local desiredSpeed = 58
local desiredJump = 120
local speedOn = false
local jumpOn = false

local allConns = {}
local function disconnectAll()
    for _, c in pairs(allConns) do
        if c and c.Connected then pcall(function() c:Disconnect() end) end
    end
    table.clear(allConns)
end

local function forceValues()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    disconnectAll()

    -- Refuerzo cada frame y cada cambio de propiedad
    table.insert(allConns, RunService.Heartbeat:Connect(function()
        if speedOn then humanoid.WalkSpeed = desiredSpeed end
        if jumpOn then
            if humanoid.UseJumpPower then
                humanoid.JumpPower = desiredJump
            else
                humanoid.JumpHeight = desiredJump * 0.35
            end
        end
        -- Anti-stun
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if humanoid.Sit then humanoid.Sit = false end
        -- Anti-pull y anti-teleport
        local v = root.AssemblyLinearVelocity
        if v.Magnitude > 180 then root.AssemblyLinearVelocity = v * 0.5 end
        if math.abs(v.Y) > 120 and not jumpOn then root.AssemblyLinearVelocity = Vector3.new(v.X, v.Y * 0.5, v.Z) end
        local av = root.AssemblyAngularVelocity
        if av.Magnitude > 25 then root.AssemblyAngularVelocity = av * 0.2 end
    end))
    table.insert(allConns, RunService.Stepped:Connect(function()
        if speedOn then humanoid.WalkSpeed = desiredSpeed end
    end))
    table.insert(allConns, RunService.RenderStepped:Connect(function()
        if speedOn then humanoid.WalkSpeed = desiredSpeed end
    end))
    -- Reacción instantánea a cambios del servidor
    table.insert(allConns, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedOn and humanoid.WalkSpeed ~= desiredSpeed then
            humanoid.WalkSpeed = desiredSpeed
        end
    end))
    table.insert(allConns, humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if jumpOn and humanoid.UseJumpPower and humanoid.JumpPower ~= desiredJump then
            humanoid.JumpPower = desiredJump
        end
    end))
    table.insert(allConns, humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if jumpOn and not humanoid.UseJumpPower and math.abs(humanoid.JumpHeight - desiredJump*0.35) > 0.1 then
            humanoid.JumpHeight = desiredJump*0.35
        end
    end))
    -- Anti-kill
    table.insert(allConns, humanoid.HealthChanged:Connect(function(h)
        if h < humanoid.MaxHealth * 0.5 then
            humanoid.Health = humanoid.MaxHealth
        end
    end))
end

-- GUI pequeña y discreta
local function createMiniGUI()
    -- Limpia GUI previa
    local guiName = "BlueSpeedMiniGUI"
    local existing = (game:GetService("CoreGui"):FindFirstChild(guiName) or player.PlayerGui:FindFirstChild(guiName))
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = guiName
    gui.Parent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or player.PlayerGui
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 210, 0, 135)
    frame.Position = UDim2.new(0, 25, 0, 75)
    frame.BackgroundColor3 = Color3.fromRGB(19, 23, 29)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Text = "BlueSpeed+Salto (Ultra)"

    -- Botón velocidad
    local speedBtn = Instance.new("TextButton", frame)
    speedBtn.Size = UDim2.new(0.47, 0, 0, 32)
    speedBtn.Position = UDim2.new(0.025, 0, 0, 36)
    speedBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
    speedBtn.Font = Enum.Font.Code
    speedBtn.TextSize = 15
    speedBtn.Text = "Velocidad: OFF"
    speedBtn.BorderSizePixel = 0
    Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 7)

    -- Botón salto
    local jumpBtn = Instance.new("TextButton", frame)
    jumpBtn.Size = UDim2.new(0.47, 0, 0, 32)
    jumpBtn.Position = UDim2.new(0.505, 0, 0, 36)
    jumpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    jumpBtn.Font = Enum.Font.Code
    jumpBtn.TextSize = 15
    jumpBtn.Text = "Salto: OFF"
    jumpBtn.BorderSizePixel = 0
    Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(0, 7)

    -- Selector velocidad
    local speedBox = Instance.new("TextBox", frame)
    speedBox.Size = UDim2.new(0.47, 0, 0, 28)
    speedBox.Position = UDim2.new(0.025, 0, 0, 75)
    speedBox.BackgroundColor3 = Color3.fromRGB(30, 37, 50)
    speedBox.TextColor3 = Color3.fromRGB(0,200,255)
    speedBox.Text = tostring(desiredSpeed)
    speedBox.Font = Enum.Font.Code
    speedBox.TextSize = 15
    speedBox.PlaceholderText = "Velocidad"
    speedBox.BorderSizePixel = 0
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

    -- Selector salto
    local jumpBox = Instance.new("TextBox", frame)
    jumpBox.Size = UDim2.new(0.47, 0, 0, 28)
    jumpBox.Position = UDim2.new(0.505, 0, 0, 75)
    jumpBox.BackgroundColor3 = Color3.fromRGB(32, 46, 38)
    jumpBox.TextColor3 = Color3.fromRGB(0,255,150)
    jumpBox.Text = tostring(desiredJump)
    jumpBox.Font = Enum.Font.Code
    jumpBox.TextSize = 15
    jumpBox.PlaceholderText = "Salto"
    jumpBox.BorderSizePixel = 0
    Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)

    -- Info/hotkeys
    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, 0, 0, 25)
    info.Position = UDim2.new(0, 0, 0, 110)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Code
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(160, 200, 255)
    info.Text = "Ctrl+Q velocidad | Ctrl+E salto | Arrastra GUI"

    -- Funciones de los botones
    local function refreshButtons()
        speedBtn.Text = "Velocidad: "..(speedOn and "ON" or "OFF")
        jumpBtn.Text = "Salto: "..(jumpOn and "ON" or "OFF")
        speedBtn.BackgroundColor3 = speedOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(0,180,255)
        jumpBtn.BackgroundColor3 = jumpOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(0,255,150)
    end

    speedBtn.MouseButton1Click:Connect(function()
        speedOn = not speedOn
        forceValues()
        refreshButtons()
    end)
    jumpBtn.MouseButton1Click:Connect(function()
        jumpOn = not jumpOn
        forceValues()
        refreshButtons()
    end)
    speedBox.FocusLost:Connect(function(enter)
        local v = tonumber(speedBox.Text)
        if v and v > 0 and v < 1000 then
            desiredSpeed = v
            if speedOn then forceValues() end
            speedBox.TextColor3 = Color3.fromRGB(0,255,100)
        else
            speedBox.Text = tostring(desiredSpeed)
            speedBox.TextColor3 = Color3.fromRGB(255,50,50)
        end
    end)
    jumpBox.FocusLost:Connect(function(enter)
        local v = tonumber(jumpBox.Text)
        if v and v > 0 and v < 1000 then
            desiredJump = v
            if jumpOn then forceValues() end
            jumpBox.TextColor3 = Color3.fromRGB(0,255,100)
        else
            jumpBox.Text = tostring(desiredJump)
            jumpBox.TextColor3 = Color3.fromRGB(255,50,50)
        end
    end)
    refreshButtons()
end

-- Hotkeys globales
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Q and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        speedOn = not speedOn
        print(speedOn and "⚡ Velocidad ultra robusta ACTIVADA" or "⚡ Velocidad desactivada")
        forceValues()
        createMiniGUI()
    end
    if input.KeyCode == Enum.KeyCode.E and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        jumpOn = not jumpOn
        print(jumpOn and "🚀 Súper salto ultra robusto ACTIVADO" or "🚀 Súper salto desactivado")
        forceValues()
        createMiniGUI()
    end
end)

-- Respawn handler
Players.PlayerAdded:Connect(function()
    wait(1)
    if speedOn or jumpOn then forceValues() end
end)
player.CharacterAdded:Connect(function()
    wait(1)
    if speedOn or jumpOn then forceValues() end
end)

-- Inicialización
createMiniGUI()
print("💙 BlueSpeed + Súper Salto ULTRA ROBUSTO listo con GUI discreta.")
print("Hotkeys: Ctrl+Q velocidad, Ctrl+E salto.")
