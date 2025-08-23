local function esPuerta(obj)
    -- Devuelve true si el nombre contiene "door" (no importa mayúsculas o minúsculas)
    return obj:IsA("BasePart") and string.lower(obj.Name):find("door")
end

local function volverNoColision(parte)
    if parte and parte:IsA("BasePart") then
        parte.CanCollide = false
        -- Opcional: también puedes hacerla transparente visualmente
        -- parte.LocalTransparencyModifier = 0.5
    end
end

-- Busca todas las puertas existentes
for _, obj in ipairs(workspace:GetDescendants()) do
    if esPuerta(obj) then
        volverNoColision(obj)
    end
end

-- Detecta puertas nuevas que aparezcan después
workspace.DescendantAdded:Connect(function(obj)
    if esPuerta(obj) then
        volverNoColision(obj)
    end
end)
