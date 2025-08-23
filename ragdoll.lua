local player = game.Players.LocalPlayer
local function makeGiant()
    local char = player.Character or player.CharacterAdded:Wait()
    -- Cambia el tamaño de las partes
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * 3 -- ¡3 veces más grande!
        end
        if part:IsA("SpecialMesh") then
            part.Scale = part.Scale * 3
        end
    end
    -- Opcional: sube el personaje para que no se atasque en el suelo
    if char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0,10,0)
    end
end

makeGiant()
-- Si quieres que el efecto persista tras morir:
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(0.2)
    makeGiant()
end)
