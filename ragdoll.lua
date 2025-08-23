-- Súper agresivo anti-ragdoll para pruebas extremas
local lp = game:GetService("Players").LocalPlayer

function superAggressiveRestore(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    -- Elimina constraints
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Constraint") or desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") or desc:IsA("RodConstraint") or desc:IsA("SpringConstraint") then
            pcall(function() desc:Destroy() end)
        end
    end
    -- Rehace joints básicos si no existen
    for _,limb in ipairs({"Left Arm","Right Arm","Left Leg","Right Leg","Head","Torso","UpperTorso","LowerTorso"}) do
        local part = char:FindFirstChild(limb)
        if part and not part:FindFirstChildWhichIsA("Motor6D") then
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
    -- Prevenir estados físicos y PlatformStand
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
    -- Si falta alguna parte crítica, respawnea
    if not root or not hum then
        lp:LoadCharacter()
    end
end

function ultraLoop(char)
    while char.Parent do
        superAggressiveRestore(char)
        task.wait(0.03) -- ¡Ultra rápido!
    end
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    ultraLoop(char)
end)

if lp.Character then
    task.wait(0.3)
    ultraLoop(lp.Character)
end
