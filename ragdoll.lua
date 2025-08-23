-- Ultra Anti-Ragdoll Robusto
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local function restoreMotors(char)
    -- Intenta recrear Motor6D entre partes principales si se destruyen
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    local limbs = {"Left Arm", "Right Arm", "Left Leg", "Right Leg", "Head", "LowerTorso"}
    if torso then
        for _, limbName in ipairs(limbs) do
            local limb = char:FindFirstChild(limbName)
            if limb and not limb:FindFirstChildWhichIsA("Motor6D") then
                local m = Instance.new("Motor6D")
                m.Name = limbName.."Joint"
                m.Part0 = torso
                m.Part1 = limb
                m.Parent = torso
            end
        end
    end
end

local function antiRagdoll(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    -- Destruye constraints ragdoll constantemente
    char.DescendantAdded:Connect(function(obj)
        if obj:IsA("Constraint") then
            pcall(function() obj:Destroy() end)
        end
    end)
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Constraint") then
            pcall(function() desc:Destroy() end)
        end
    end

    -- Previene PlatformStand/Physics
    if hum then
        hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end

    -- Bucle super agresivo
    RunService.Stepped:Connect(function()
        if not char or not char.Parent then return end

        -- Elimina constraints
        for _,desc in ipairs(char:GetDescendants()) do
            if desc:IsA("Constraint") then
                pcall(function() desc:Destroy() end)
            end
        end

        -- Restaura motors
        restoreMotors(char)

        -- Previene PlatformStand, Physics, y revive si es necesario
        if hum then
            hum.PlatformStand = false
            if hum:GetState() == Enum.HumanoidStateType.Physics or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            if hum.Health <= 0 then
                hum.Health = hum.MaxHealth
            end
        end

        -- Teleport si caes muy abajo
        if root and root.Position.Y < -50 then
            root.CFrame = CFrame.new(0, 15, 0)
            root.Velocity = Vector3.new(0,0,0)
        end

        -- Respawnea si falta algo crítico
        if not root or not hum then
            lp:LoadCharacter()
        end
    end)
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    antiRagdoll(char)
end)
if lp.Character then
    task.wait(0.2)
    antiRagdoll(lp.Character)
end
