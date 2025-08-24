-- Ultra Anti-Knockback/Anti-Retroceso extremo para Roblox
-- Español en textos, variables en inglés

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local enabled = true

local allConns = {}

local function disconnectAll()
    for _,c in pairs(allConns) do
        if c and c.Connected then pcall(function() c:Disconnect() end) end
    end
    table.clear(allConns)
end

local function ultraAntiKnockback()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    disconnectAll()

    -- Guarda la orientación y posición cada frame
    local lastCFrame = root.CFrame

    -- Refuerza el estado físico y la posición constantemente
    table.insert(allConns, RunService.Heartbeat:Connect(function()
        if not enabled then return end

        -- Repara PlatformStand y Sit (anti stun, anti ragdoll)
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
        if humanoid.Sit then
            humanoid.Sit = false
        end

        -- Anti Knockback: Repara la posición si hay un retroceso grande o rotación
        local posDiff = (root.Position - lastCFrame.Position).Magnitude
        local lookDiff = (root.CFrame.LookVector - lastCFrame.LookVector).Magnitude
        if posDiff > 1.5 or lookDiff > 0.2 then
            root.CFrame = CFrame.new(lastCFrame.Position, lastCFrame.Position + lastCFrame.LookVector)
        end

        -- Elimina toda aceleración y velocidad física
        root.AssemblyLinearVelocity = Vector3.new(0,root.AssemblyLinearVelocity.Y,0) -- Conserva el salto natural
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)

        -- Opcional: Si el juego fuerza Y, puedes poner Y=0 para ser ultra firme (pero puede impedir saltar)
        -- root.AssemblyLinearVelocity = Vector3.new(0,0,0)

        lastCFrame = root.CFrame
    end))

    -- Evita estados de físico peligrosos
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

-- Respawn handler
player.CharacterAdded:Connect(function()
    wait(1)
    if enabled then
        ultraAntiKnockback()
    end
end)

if player.Character then ultraAntiKnockback() end

print("🛡️ Ultra Anti-Knockback activado (cuerpo siempre firme, sin retroceso ni tambaleos).")

-- Hotkey para activar/desactivar (Ctrl+K)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        enabled = not enabled
        print(enabled and "🟢 Ultra Anti-Knockback ACTIVADO" or "🔴 Ultra Anti-Knockback DESACTIVADO")
        if enabled then ultraAntiKnockback() else disconnectAll() end
    end
end)
