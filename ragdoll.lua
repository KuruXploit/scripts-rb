-- Super Anti-Ragdoll Agresivo para pruebas extremas
local lp = game:GetService("Players").LocalPlayer

function forceRestore(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    -- Elimina constraints al instante
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") or desc:IsA("RodConstraint")
        or desc:IsA("SpringConstraint") or desc:IsA("Constraint") then
            pcall(function() desc:Destroy() end)
        end
    end
    -- Restaura Motor6D si se destruyen
    for _,limb in ipairs({"Left Arm","Right Arm","Left Leg","Right Leg","Head","Torso","UpperTorso","LowerTorso"}) do
        local part = char:FindFirstChild(limb)
        if part and not part:FindFirstChildWhichIsA("Motor6D") then
            -- Intenta recrear la joint si es posible (solo si la parte y torso existen)
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if torso and part ~= torso then
                local mot = Instance.new("Motor6D")
                mot.Name = part.Name.."Joint"
                mot.Part0 = torso
                mot.Part1 = part
                mot.Parent = torso
            end
        end
    end
    -- Previene PlatformStand y Physics
    if hum then
        hum.PlatformStand = false
        if hum:GetState() == Enum.HumanoidStateType.Physics or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        -- Cura si está muerto
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
        end
    end
    -- Si caes bajo el mapa, te regresa arriba
    if root and root.Position.Y < -50 then
        root.Velocity = Vector3.new(0,0,0)
        root.CFrame = CFrame.new(0, 15, 0)
    end
    -- Si falta alguna parte crítica, respawnea (hard reset)
    if not root or not hum then
        lp:LoadCharacter()
    end
end

function aggressiveLoop(char)
    while char.Parent do
        forceRestore(char)
        task.wait(0.05) -- Muy rápido: 20 veces por segundo
    end
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    aggressiveLoop(char)
end)

if lp.Character then
    task.wait(0.5)
    aggressiveLoop(lp.Character)
end
