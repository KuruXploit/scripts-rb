-- Anti-Ragdoll Roblox FULL ROBUSTO by Copilot
local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")

local function protectCharacter(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end

    -- Restaurar State si lo intentan poner en Physics o PlatformStand
    humanoid.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Ragdoll or humanoid.PlatformStand then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            humanoid.PlatformStand = false
        end
    end)

    -- Forzar PlatformStand a false siempre
    rs.RenderStepped:Connect(function()
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
    end)

    -- Elimina constraints y protege joints
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") or desc:IsA("RodConstraint") or desc:IsA("SpringConstraint") then
            desc:Destroy()
        end
        if desc:IsA("Motor6D") then
            desc.Changed:Connect(function(prop)
                if prop == "Part0" or prop == "Part1" then
                    -- Restaura la joint si la quieren eliminar
                    desc.Part0 = char:FindFirstChild(desc.Name:gsub("Joint", ""))
                    desc.Part1 = char:FindFirstChild(desc.Name:gsub("Joint", ""))
                end
            end)
        end
    end

    -- Monitorea nuevos descendants
    char.DescendantAdded:Connect(function(obj)
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") or obj:IsA("RodConstraint") or obj:IsA("SpringConstraint") then
            obj:Destroy()
        elseif obj:IsA("Motor6D") then
            obj.Changed:Connect(function(prop)
                if prop == "Part0" or prop == "Part1" then
                    obj.Part0 = char:FindFirstChild(obj.Name:gsub("Joint", ""))
                    obj.Part1 = char:FindFirstChild(obj.Name:gsub("Joint", ""))
                end
            end)
        end
    end)

    -- Si eliminan humanoid o joints, respawnea el character
    humanoid.AncestryChanged:Connect(function(_, parent)
        if not parent then
            lp:LoadCharacter()
        end
    end)
end

-- Hook para cualquier respawn
lp.CharacterAdded:Connect(function(char)
    task.wait(1)
    protectCharacter(char)
end)

if lp.Character then
    protectCharacter(lp.Character)
end

print("Anti-Ragdoll FULL ROBUSTO activado.")
