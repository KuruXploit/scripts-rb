local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Size = part.Size * 0.3 -- te vuelves 3 veces más pequeño
    end
    if part:IsA("SpecialMesh") then
        part.Scale = part.Scale * 0.3 -- por si tienes mesh
    end
end
