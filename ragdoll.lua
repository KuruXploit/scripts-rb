--[[
    Anti-Knockback VIP Ultra Robusto
    Autor: KuruXploit Copilot
    Español en textos, variables en inglés.
    - No te deja rígido, puedes saltar y moverte.
    - Corrige empuje, stun, platformstand, ragdoll, freeze, despidos y más.
    - GUI pequeña para control visual.
    - Modular y auto-reparable.
    - Supera la mayoría de anticheats cliente.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local enabled = true
local softness = 0.50 -- 0 = muy firme, 1 = muy suave
local posTolerance = 2.5 -- máxima distancia permitida antes de reparar (studs)
local rotTolerance = 0.25 -- máxima diferencia de rotación antes de reparar
local repairTime = 0.12 -- segundos para suavizar la corrección
local guiEnabled = true

local allConns = {}
local function disconnectAll()
    for _,c in pairs(allConns) do
        if c and c.Connected then pcall(function() c:Disconnect() end) end
    end
    table.clear(allConns)
end

---------------------------
--   PROTECCIÓN FÍSICA   --
---------------------------
local function repairPhysics()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    disconnectAll()

    -- Historial para restaurar pose de emergencia
    local lastCFrame = root.CFrame
    local lastGoodCFrame = root.CFrame
    local lastGrounded = humanoid.FloorMaterial ~= Enum.Material.Air
    local repairing = false

    -- Reparador principal
    table.insert(allConns, RunService.Heartbeat:Connect(function(dt)
        if not enabled then return end

        -- Estados peligrosos
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
        if humanoid.Sit then
            humanoid.Sit = false
        end
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        if humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end

        -- Repara velocities físicas peligrosas (sin quitar saltos)
        if math.abs(root.AssemblyLinearVelocity.Y) < 0.2 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        else
            root.AssemblyLinearVelocity = Vector3.new(
                math.clamp(root.AssemblyLinearVelocity.X, -30, 30),
                root.AssemblyLinearVelocity.Y,
                math.clamp(root.AssemblyLinearVelocity.Z, -30, 30)
            )
        end
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        -- Si el jugador está saltando, actualizar historial pero no reparar
        if humanoid:GetState() == Enum.HumanoidStateType.Jumping or
           humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            lastCFrame = root.CFrame
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                lastGoodCFrame = root.CFrame
            end
            lastGrounded = (humanoid.FloorMaterial ~= Enum.Material.Air)
            return
        end

        -- Si está en el aire pero no saltando (ej: lo empujaron), repara a la posición válida anterior
        if not repairing then
            local posDiff = (root.Position - lastCFrame.Position).Magnitude
            local rotDiff = (root.CFrame.LookVector - lastCFrame.LookVector).Magnitude
            if posDiff > posTolerance or rotDiff > rotTolerance then
                repairing = true
                -- Repara suavemente a la posición anterior válida
                local startCF = root.CFrame
                local endCF = lastGoodCFrame
                local t = 0
                while t < repairTime do
                    if not enabled then break end
                    t = t + RunService.Heartbeat:Wait()
                    local alpha = math.min(t/repairTime, 1)
                    local cf = startCF:Lerp(endCF, alpha*softness)
                    root.CFrame = cf
                end
                repairing = false
            end
        end

        -- Actualiza historial solo si está en el suelo y no fue empujado
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            lastGoodCFrame = root.CFrame
            lastCFrame = root.CFrame
            lastGrounded = true
        else
            lastCFrame = root.CFrame
        end
    end))

    -- Protege cambios de estado
    table.insert(allConns, humanoid.StateChanged:Connect(function(old, new)
        if not enabled then return end
        if new == Enum.HumanoidStateType.PlatformStand or
           new == Enum.HumanoidStateType.Ragdoll or
           new == Enum.HumanoidStateType.Physics or
           new == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end))

    -- Protege propiedades
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
    table.insert(allConns, root:GetPropertyChangedSignal("CFrame"):Connect(function()
        if not enabled then return end
        -- Si el cambio es muy brusco, repara de inmediato
        if (root.Position - lastCFrame.Position).Magnitude > posTolerance*2 then
            root.CFrame = lastGoodCFrame
        end
    end))
end

-----------------------------------
--    GUI PEQUEÑA Y DISCRETA     --
-----------------------------------
local function createMiniGUI()
    if not guiEnabled then return end
    local guiName = "AntiKnockbackVIPMiniGUI"
    local old = game:GetService("CoreGui"):FindFirstChild(guiName) or player.PlayerGui:FindFirstChild(guiName)
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = guiName
    gui.Parent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or player.PlayerGui
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 230, 0, 110)
    frame.Position = UDim2.new(0, 25, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(22, 29, 39)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 26)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Text = "Anti-Knockback VIP"

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.95, 0, 0, 28)
    toggle.Position = UDim2.new(0.025, 0, 0, 32)
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,255,100) or Color3.fromRGB(180,60,60)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.Code
    toggle.TextSize = 16
    toggle.Text = enabled and "PROTECCIÓN ACTIVADA" or "PROTECCIÓN DESACTIVADA"
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "PROTECCIÓN ACTIVADA" or "PROTECCIÓN DESACTIVADA"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,255,100) or Color3.fromRGB(180,60,60)
        if enabled then repairPhysics() else disconnectAll() end
    end)

    -- Ajuste de suavidad
    local lblSoft = Instance.new("TextLabel", frame)
    lblSoft.Size = UDim2.new(0.52, 0, 0, 22)
    lblSoft.Position = UDim2.new(0.03, 0, 0, 70)
    lblSoft.Font = Enum.Font.Code
    lblSoft.TextSize = 13
    lblSoft.BackgroundTransparency = 1
    lblSoft.TextColor3 = Color3.fromRGB(180,200,240)
    lblSoft.Text = "Suavidad:"
    local softBox = Instance.new("TextBox", frame)
    softBox.Size = UDim2.new(0.23, 0, 0, 22)
    softBox.Position = UDim2.new(0.48, 0, 0, 70)
    softBox.BackgroundColor3 = Color3.fromRGB(30, 37, 50)
    softBox.TextColor3 = Color3.fromRGB(0,200,255)
    softBox.Text = tostring(softness)
    softBox.Font = Enum.Font.Code
    softBox.TextSize = 13
    softBox.PlaceholderText = "0-1"
    softBox.BorderSizePixel = 0
    Instance.new("UICorner", softBox).CornerRadius = UDim.new(0, 5)
    softBox.FocusLost:Connect(function()
        local v = tonumber(softBox.Text)
        if v and v >= 0 and v <= 1 then
            softness = v
            softBox.TextColor3 = Color3.fromRGB(0,255,100)
        else
            softBox.Text = tostring(softness)
            softBox.TextColor3 = Color3.fromRGB(255,50,50)
        end
    end)

    -- Cerrar GUI
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0, 22, 0, 22)
    close.Position = UDim2.new(1, -27, 0, 6)
    close.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.Code
    close.TextSize = 14
    close.BorderSizePixel = 0
    Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        guiEnabled = false
    end)
end

---------------------------------
--    RESPALDO Y HOTKEYS VIP   --
---------------------------------

-- Respawn handler
player.CharacterAdded:Connect(function()
    wait(1)
    if enabled then
        repairPhysics()
    end
    if guiEnabled then createMiniGUI() end
end)

if player.Character then repairPhysics() end
if guiEnabled then createMiniGUI() end

print("🎖️ Anti-Knockback VIP Ultra Robusto ACTIVADO - Tu cuerpo siempre firme y natural.")

-- Hotkey para activar/desactivar (Ctrl+K)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        enabled = not enabled
        print(enabled and "🟢 Anti-Knockback VIP ACTIVADO" or "🔴 Anti-Knockback VIP DESACTIVADO")
        if enabled then repairPhysics() else disconnectAll() end
        if guiEnabled then createMiniGUI() end
    end
end)
