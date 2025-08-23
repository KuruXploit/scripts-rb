-- Script gigante robusto para Roblox - escala todo y corrige el movimiento
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local SCALE = 3 -- Cambia este número para el tamaño

local function scaleChar(char)
    -- Escala las partes físicas y sus accesorios
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * SCALE
            part.Massless = false
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5) -- Fricción normal
            -- Corrige el pivote si es RootPart para evitar bugs de físicas
            if part.Name == "HumanoidRootPart" then
                part.RootPriority = 127
            end
        elseif part:IsA("SpecialMesh") then
            part.Scale = part.Scale * SCALE
        end
    end

    -- Corrige la fricción para evitar que resbales
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
    end

    -- Ajusta el HipHeight del Humanoid para que no camines "hundido"
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.HipHeight = hum.HipHeight * SCALE
        -- Opcional: fuerza WalkSpeed normal
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    -- Sube al jugador para evitar que quede atrapado
    if root then
        root.CFrame = root.CFrame + Vector3.new(0, 10 * SCALE, 0)
    end
end

local function applyAlways()
    local char = lp.Character or lp.CharacterAdded:Wait()
    scaleChar(char)
    -- Mantén el tamaño tras respawn
    lp.CharacterAdded:Connect(function(c)
        wait(0.2)
        scaleChar(c)
    end)
end

applyAlways()
