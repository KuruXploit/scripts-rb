--[[
Anti-Knockback VIP Ultra Robusto y Suave
- Español en textos, variables en inglés
- Corrige knockback, stun, platformstand, freeze y ragdoll SIN dejarte rígido ni impedir movimiento natural
- GUI pequeña, draggable, siempre visible
- Hotkey F4 para mostrar/ocultar GUI, Ctrl+K para activar/desactivar
- Mantiene saltos, caídas y animaciones normales
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Configuración
local enabled = true
local guiVisible = true
local repairSoftness = 0.33  -- 0 = instantáneo, 1 = ultra suave
local posTolerance = 2.1     -- Distancia máxima permitida antes de reparar (studs)
local rotTolerance = 0.22    -- Diferencia máxima de rotación antes de reparar
local repairTime = 0.10      -- Segundos para corregir suavemente

local allConns = {}
local function disconnectAll()
    for _,c in pairs(allConns) do
        if c and c.Connected then pcall(function() c:Disconnect() end) end
    end
    table.clear(allConns)
end

---------------------
-- Protección Física
---------------------
local function repairPhysics()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    disconnectAll()

    -- Historial de CFrame válido
    local lastGoodCFrame = root.CFrame
    local lastCFrame = root.CFrame
    local repairing = false

    table.insert(allConns, RunService.Heartbeat:Connect(function(dt)
        if not enabled then return end

        -- Elimina PlatformStand y Sit si aparecen (anti stun, anti ragdoll)
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if humanoid.Sit then humanoid.Sit = false end
        if humanoid:GetState() == Enum.HumanoidStateType.Physics or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        -- No reparar si saltas o caes
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
            lastCFrame = root.CFrame
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                lastGoodCFrame = root.CFrame
            end
            return
        end

        -- Si hubo un empuje grande, repara suavemente posición y rotación
        if not repairing then
            local posDiff = (root.Position - lastCFrame.Position).Magnitude
            local rotDiff = (root.CFrame.LookVector - lastCFrame.LookVector).Magnitude
            if posDiff > posTolerance or rotDiff > rotTolerance then
                repairing = true
                local startCF = root.CFrame
                local endCF = lastGoodCFrame
                local t = 0
                while t < repairTime do
                    if not enabled then break end
                    t = t + RunService.Heartbeat:Wait()
                    local alpha = math.min(t/repairTime, 1) * repairSoftness
                    root.CFrame = startCF:Lerp(endCF, alpha)
                end
                repairing = false
            end
        end

        -- Guarda último CFrame válido solo si en el suelo
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            lastGoodCFrame = root.CFrame
            lastCFrame = root.CFrame
        else
            lastCFrame = root.CFrame
        end

        -- Elimina knockback físico suave (pero deja saltos)
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        root.AssemblyLinearVelocity = Vector3.new(
            math.clamp(root.AssemblyLinearVelocity.X, -30, 30),
            root.AssemblyLinearVelocity.Y,
            math.clamp(root.AssemblyLinearVelocity.Z, -30, 30)
        )
    end))

    -- Reparar PlatformStand/Sit instantáneo
    table.insert(allConns, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if enabled and humanoid.PlatformStand then humanoid.PlatformStand = false end
    end))
    table.insert(allConns, humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if enabled and humanoid.Sit then humanoid.Sit = false end
    end))
end

------------------
-- GUI Minimalista
------------------
local function createMiniGUI()
    local guiName = "AntiKnockbackVIPMiniGUI"
    local gui = game:GetService("CoreGui"):FindFirstChild(guiName) or player.PlayerGui:FindFirstChild(guiName)
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = guiName
    gui.Parent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or player.PlayerGui
    gui.ResetOnSpawn = false
    gui.Enabled = guiVisible

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 220, 0, 85)
    frame.Position = UDim2.new(0, 30, 0, 90)
    frame.BackgroundColor3 = Color3.fromRGB(25, 32, 46)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 17
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Text = "Anti-Knockback VIP"

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.93, 0, 0, 26)
    toggle.Position = UDim2.new(0.035, 0, 0, 30)
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,255,100) or Color3.fromRGB(190,60,60)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.Code
    toggle.TextSize = 15
    toggle.Text = enabled and "PROTECCIÓN ACTIVADA" or "PROTECCIÓN DESACTIVADA"
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "PROTECCIÓN ACTIVADA" or "PROTECCIÓN DESACTIVADA"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,255,100) or Color3.fromRGB(190,60,60)
        if enabled then repairPhysics() else disconnectAll() end
    end)

    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, 0, 0, 20)
    info.Position = UDim2.new(0, 0, 0, 62)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Code
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(160, 200, 255)
    info.Text = "F4: ocultar/mostrar GUI | Ctrl+K: activar/desactivar"

    -- Hotkey para ocultar/mostrar GUI
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F4 then
            guiVisible = not guiVisible
            gui.Enabled = guiVisible
        end
    end)
end

--------------------
-- Respawn y Hotkeys
--------------------
player.CharacterAdded:Connect(function()
    wait(1)
    if enabled then repairPhysics() end
    createMiniGUI()
end)

if player.Character then
    repairPhysics()
end
createMiniGUI()

-- Hotkey VIP Ctrl+K para activar/desactivar protección
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        enabled = not enabled
        print(enabled and "🟢 Anti-Knockback VIP ACTIVADO" or "🔴 Anti-Knockback VIP DESACTIVADO")
        if enabled then repairPhysics() else disconnectAll() end
        createMiniGUI()
    end
end)

print("🎖️ Anti-Knockback VIP Ultra Robusto y Suave ACTIVADO - Puedes moverte y saltar normalmente, cero retroceso ni stun.")
