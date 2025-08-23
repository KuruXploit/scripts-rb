-- Este script te permite atravesar todas las partes cuyo nombre contenga "wall" (insensible a mayúsculas)

local function esPared(obj)
    -- Devuelve true si el nombre contiene "wall" (no importa mayúsculas o minúsculas)
    return obj:IsA("BasePart") and string.lower(obj.Name):find("wall")
end

local function volverNoColision(parte)
    if parte and parte:IsA("BasePart") then
        parte.CanCollide = false
        -- Opcional: también puedes hacerla parcialmente transparente solo para ti
        -- parte.LocalTransparencyModifier = 0.5
    end
end

-- Busca todas las paredes existentes
for _, obj in ipairs(workspace:GetDescendants()) do
    if esPared(obj) then
        volverNoColision(obj)
    end
end

-- Detecta paredes nuevas que aparezcan después
workspace.DescendantAdded:Connect(function(obj)
    if esPared(obj) then
        volverNoColision(obj)
    end
end)
