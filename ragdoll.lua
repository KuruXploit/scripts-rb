-- Ultra Anti-Override Speed Script (Velocidad 100, inmune a cualquier cambio externo)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local VELOCIDAD = 100

local function fuerzaVelocidad(hum)
    -- El bucle mantiene la velocidad a 100 todo el tiempo, sin importar lo que pase
    RunService.RenderStepped:Connect(function()
        if hum and hum.Parent then
            -- Borra cualquier estado que limite la movilidad
            pcall(function()
                if hum.WalkSpeed ~= VELOCIDAD then
                    hum.WalkSpeed = VELOCIDAD
                end
                hum.PlatformStand = false
                if hum:GetState() ~= Enum.HumanoidStateType.Running then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                -- Corrige si algún script te detiene
                if hum.JumpPower < 50 then
                    hum.JumpPower = 100
                end
                if hum.AutoRotate == false then
                    hum.AutoRotate = true
                end
                if hum.SeatPart then
                    hum.Sit = false
                end
            end)
        end
    end)
end

local function aplicar()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    fuerzaVelocidad(hum)
end

aplicar()
lp.CharacterAdded:Connect(function()
    wait(0.1)
    aplicar()
end)
