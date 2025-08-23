-- Script ROBUSTO: fuerza velocidad y salto, ignora cambios externos
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local SPEED = 32 -- Cambia a tu velocidad deseada
local JUMP = 100 -- Cambia a tu salto deseado

local function lockStats(hum)
    -- Bucle que fuerza velocidad y salto constante, y corrige estados
    RunService.Stepped:Connect(function()
        if hum and hum.Parent then
            -- Fuerza velocidad y salto
            if hum.WalkSpeed ~= SPEED then
                hum.WalkSpeed = SPEED
            end
            if hum.JumpPower ~= JUMP then
                hum.JumpPower = JUMP
            end
            -- Previene PlatformStand y estados no deseados
            if hum.PlatformStand then
                hum.PlatformStand = false
            end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

local function onChar(char)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    lockStats(hum)
end

if lp.Character then
    onChar(lp.Character)
end
lp.CharacterAdded:Connect(onChar)
