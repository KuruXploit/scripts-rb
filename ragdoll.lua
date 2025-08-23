local player = game.Players.LocalPlayer

-- Prueba los métodos comunes de VIP en el cliente
pcall(function() player.IsVIP = true end)
pcall(function() player.VIP = true end)
if player:FindFirstChild("IsVIP") then
    pcall(function() player.IsVIP.Value = true end)
end
if player:FindFirstChild("VIP") then
    pcall(function() player.VIP.Value = true end)
end

-- También fuerza variables VIP en la GUI
local plrGui = player:FindFirstChildOfClass("PlayerGui")
if plrGui then
    for _, obj in ipairs(plrGui:GetDescendants()) do
        if string.lower(obj.Name):find("vip") and obj:IsA("GuiObject") then
            obj.Visible = true
        end
    end
end

-- Si hay puertas u objetos ocultos, los vuelve visibles y usables
for _, obj in ipairs(workspace:GetDescendants()) do
    if string.lower(obj.Name):find("vip") then
        if obj:IsA("BasePart") then
            obj.Transparency = 0
            obj.CanCollide = true
        end
        obj.Parent = workspace -- Por si están en una carpeta oculta
    end
end
