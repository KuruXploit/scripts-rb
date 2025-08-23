local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
local function antiRagdoll(char)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    -- Restaurar PlatformStand y evitar Physics
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
    rs.RenderStepped:Connect(function()
        hum.PlatformStand = false
        if root and root.Position.Y < -50 then -- Si se va bajo tierra
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = CFrame.new(0, 10, 0) -- Teleport a zona segura
        end
    end)
    -- Elimina constraints y joints ragdoll
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") or desc:IsA("RodConstraint") or desc:IsA("SpringConstraint") then
            desc:Destroy()
        end
    end
    char.DescendantAdded:Connect(function(obj)
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") or obj:IsA("RodConstraint") or obj:IsA("SpringConstraint") then
            obj:Destroy()
        end
    end)
    -- Si eliminan RootPart o Humanoid, respawnea
    root.AncestryChanged:Connect(function(_, parent)
        if not parent then
            lp:LoadCharacter()
        end
    end)
    hum.AncestryChanged:Connect(function(_, parent)
        if not parent then
            lp:LoadCharacter()
        end
    end)
end

lp.CharacterAdded:Connect(function(c)
    task.wait(1)
    antiRagdoll(c)
end)
if lp.Character then
    task.wait(1)
    antiRagdoll(lp.Character)
end
