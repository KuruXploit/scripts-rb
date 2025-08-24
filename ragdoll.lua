-- Blue Speed GUI + Súper Salto - Edición Dekta Executor (Ultra Robusto y Funcional)
-- Para: Roube um Brainrot
-- Hecho por: KuruXploit Copilot
-- Español neutro en GUI y mensajes, variables y lógica en inglés.

--// Servicios requeridos
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

--// Selección de padre para la GUI (CoreGui > PlayerGui)
local guiParent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or player:WaitForChild("PlayerGui")

--// Variables de control y presets
local speedEnabled, jumpEnabled, isProtected = false, false, false
local antiPullConnections, jumpConnections, bypassConnections = {}, {}, {}
local originalSpeed, originalJumpPower = 16, 50
local currentSpeedValue, currentJumpValue = 58, 120
local speedPresets = {16, 30, 45, 58, 75, 100, 150}
local jumpPresets = {50, 80, 100, 120, 150, 200, 300}

--// Imprime mensajes con formato
local function printESP(msg)
    print("💙[BLUE SPEED+JUMP] "..msg)
end

--// Limpieza de conexiones
local function disconnectAll(list)
    for _,conn in pairs(list) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    table.clear(list)
end

--// ANTI-PULL: Protección avanzada contra "jalones"
local function enableAntiPull()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    printESP("Anti-pull activado.")
    disconnectAll(antiPullConnections)
    
    -- Limita la velocidad lineal y vertical excesiva
    antiPullConnections[1] = RunService.Heartbeat:Connect(function()
        if not isProtected then return end
        local v = rootPart.AssemblyLinearVelocity
        if v.Magnitude > 180 then
            rootPart.AssemblyLinearVelocity = v * 0.65
            printESP("Velocidad sospechosa reducida: "..math.floor(v.Magnitude))
        end
        if math.abs(v.Y) > 120 and not jumpEnabled then
            rootPart.AssemblyLinearVelocity = Vector3.new(v.X, v.Y * 0.4, v.Z)
            printESP("Velocidad vertical sospechosa.")
        end
    end)
    -- Monitorea movimientos instantáneos (teleports)
    local posHistory = {}
    antiPullConnections[2] = RunService.Heartbeat:Connect(function()
        if not isProtected then return end
        table.insert(posHistory, {pos=rootPart.Position, t=tick()})
        if #posHistory > 8 then table.remove(posHistory,1) end
        if #posHistory >= 5 then
            local d = (posHistory[#posHistory].pos - posHistory[1].pos).Magnitude
            local dt = posHistory[#posHistory].t - posHistory[1].t
            if d > 80 and dt < 0.5 and not jumpEnabled then
                printESP("Movimiento instantáneo detectado.")
            end
        end
    end)
    -- Estabiliza rotación brusca
    antiPullConnections[3] = RunService.Heartbeat:Connect(function()
        if not isProtected then return end
        local av = rootPart.AssemblyAngularVelocity
        if av.Magnitude > 25 then
            rootPart.AssemblyAngularVelocity = av * 0.2
            printESP("Rotación estabilizada.")
        end
    end)
end

--// SUPER JUMP: Saltos personalizados y estables
local function enableSuperJump()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    disconnectAll(jumpConnections)
    printESP("Súper salto activado ("..currentJumpValue..")")
    -- Refuerza el valor de salto activamente
    jumpConnections[1] = RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.Parent and jumpEnabled then
            if humanoid.UseJumpPower then
                if humanoid.JumpPower ~= currentJumpValue then
                    humanoid.JumpPower = currentJumpValue
                end
            else
                local h = currentJumpValue * 0.35
                if humanoid.JumpHeight ~= h then
                    humanoid.JumpHeight = h
                end
            end
        end
    end)
    -- Previene estados que bloquean saltos
    jumpConnections[2] = humanoid.StateChanged:Connect(function(_, newState)
        if not jumpEnabled then return end
        if newState == Enum.HumanoidStateType.PlatformStand then
            task.wait(0.03)
            humanoid.PlatformStand = false
        end
    end)
    -- Protege contra reseteos ajenos de JumpPower/JumpHeight
    jumpConnections[3] = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if jumpEnabled and humanoid.UseJumpPower and humanoid.JumpPower < currentJumpValue*0.8 then
            humanoid.JumpPower = currentJumpValue
            printESP("JumpPower restaurado.")
        end
    end)
    jumpConnections[4] = humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if jumpEnabled and not humanoid.UseJumpPower then
            local h = currentJumpValue*0.35
            if humanoid.JumpHeight < h*0.8 then
                humanoid.JumpHeight = h
                printESP("JumpHeight restaurado.")
            end
        end
    end)
end

--// ANTI-DETECCIÓN: Protección extrema (salud, velocidad, teleports, bloqueos)
local function enableUltraBypass()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    disconnectAll(bypassConnections)
    isProtected = true
    printESP("Anti-detección extremo activado.")
    -- Refuerza velocidad
    bypassConnections[1] = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if isProtected and speedEnabled then
            task.wait(0.01)
            humanoid.WalkSpeed = currentSpeedValue
            printESP("Velocidad restaurada.")
        end
    end)
    -- Previene muerte forzada
    bypassConnections[2] = humanoid.HealthChanged:Connect(function(h)
        if isProtected and h <= 0 then
            humanoid.Health = humanoid.MaxHealth
            printESP("Intento de eliminación bloqueado.")
        elseif isProtected and h < humanoid.MaxHealth * 0.3 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
    -- Detecta teleport sospechoso
    local lastPos, lastTime = rootPart.Position, tick()
    bypassConnections[3] = rootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        local p, t = rootPart.Position, tick()
        local d, dt = (p-lastPos).Magnitude, t-lastTime
        if d > 100 and dt < 0.3 then
            printESP("Posible teleport bloqueado.")
        end
        lastPos, lastTime = p, t
    end)
    -- Refuerza PlatformStand/Sit
    bypassConnections[4] = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if isProtected and humanoid.PlatformStand then
            task.wait(0.03)
            humanoid.PlatformStand = false
            printESP("PlatformStand corregido.")
        end
    end)
    bypassConnections[5] = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if isProtected and humanoid.Sit then
            task.wait(0.03)
            humanoid.Sit = false
            printESP("Sentado corregido.")
        end
    end)
    -- Refuerza salud y valores clave en bucle
    bypassConnections[6] = RunService.Heartbeat:Connect(function()
        if not isProtected then return end
        if humanoid.Health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
        if speedEnabled and humanoid.WalkSpeed ~= currentSpeedValue then humanoid.WalkSpeed = currentSpeedValue end
        if jumpEnabled then
            if humanoid.UseJumpPower and humanoid.JumpPower ~= currentJumpValue then humanoid.JumpPower = currentJumpValue end
            if not humanoid.UseJumpPower and humanoid.JumpHeight ~= currentJumpValue*0.35 then humanoid.JumpHeight = currentJumpValue*0.35 end
        end
    end)
end

--// Alterna velocidad
local function toggleSpeed()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    speedEnabled = not speedEnabled
    if speedEnabled then
        printESP("Velocidad activada ("..currentSpeedValue.." studs/s)")
        if not isProtected then enableUltraBypass() enableAntiPull() end
        -- Animación progresiva
        local s, steps = humanoid.WalkSpeed, 22
        local inc = (currentSpeedValue - s)/steps
        task.spawn(function()
            for i=1,steps do
                if humanoid and humanoid.Parent and speedEnabled then
                    humanoid.WalkSpeed = s + inc*i
                    task.wait(0.015)
                else break end
            end
            if humanoid and humanoid.Parent and speedEnabled then humanoid.WalkSpeed = currentSpeedValue end
        end)
    else
        printESP("Velocidad desactivada.")
        local s, steps = humanoid.WalkSpeed, 18
        local dec = (s-originalSpeed)/steps
        task.spawn(function()
            for i=1,steps do
                if humanoid and humanoid.Parent and not speedEnabled then
                    humanoid.WalkSpeed = s - dec*i
                    task.wait(0.018)
                else break end
            end
            if humanoid and humanoid.Parent and not speedEnabled then humanoid.WalkSpeed = originalSpeed end
        end)
    end
end

--// Alterna salto
local function toggleJump()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        printESP("Súper salto activado ("..currentJumpValue..")")
        if not isProtected then enableUltraBypass() enableAntiPull() end
        enableSuperJump()
        task.delay(0.09,function()
            if humanoid and humanoid.Parent and jumpEnabled then
                if humanoid.UseJumpPower then humanoid.JumpPower = currentJumpValue else humanoid.JumpHeight = currentJumpValue*0.35 end
            end
        end)
    else
        printESP("Súper salto desactivado.")
        disconnectAll(jumpConnections)
        if humanoid and humanoid.Parent then
            if humanoid.UseJumpPower then humanoid.JumpPower = originalJumpPower else humanoid.JumpHeight = originalJumpPower*0.35 end
        end
    end
end

--// GUI: Interfaz moderna, feedback visual y controles intuitivos
local function createTechGUI()
    printESP("Creando interfaz visual avanzada...")
    -- Limpia GUI previa
    local existing = guiParent:FindFirstChild("BlueSpeedTech")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name, screenGui.Parent, screenGui.ResetOnSpawn = "BlueSpeedTech", guiParent, false
    local mainFrame = Instance.new("Frame")
    mainFrame.Size, mainFrame.Position, mainFrame.BackgroundColor3 = UDim2.new(0,320,0,280), UDim2.new(0,40,0,40), Color3.fromRGB(8,12,20)
    mainFrame.BorderSizePixel, mainFrame.Active, mainFrame.Draggable, mainFrame.Parent = 0, true, true, screenGui
    Instance.new("UICorner",mainFrame).CornerRadius = UDim.new(0,15)
    local stroke = Instance.new("UIStroke",mainFrame)
    stroke.Color,stroke.Thickness = Color3.fromRGB(0,162,255),2
    local gradient = Instance.new("UIGradient",mainFrame)
    gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(8,12,20)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(12,20,35)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,8,15))} gradient.Rotation = 135
    -- Título
    local title = Instance.new("TextLabel",mainFrame)
    title.Size,title.Position,title.BackgroundTransparency = UDim2.new(1,0,0,35),UDim2.new(0,0,0,5),1
    title.Text,title.TextColor3,title.TextSize,title.Font,title.TextStrokeTransparency = "BLUE SPEED + SÚPER SALTO",Color3.fromRGB(0,220,255),18,Enum.Font.Code,0.5
    title.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    -- Indicadores de estado
    local speedInd,jumpInd = Instance.new("Frame",mainFrame),Instance.new("Frame",mainFrame)
    speedInd.Size,speedInd.Position,speedInd.BackgroundColor3,speedInd.BorderSizePixel = UDim2.new(0,8,0,8),UDim2.new(0,10,0,12),Color3.fromRGB(255,0,0),0
    jumpInd.Size,jumpInd.Position,jumpInd.BackgroundColor3,jumpInd.BorderSizePixel = UDim2.new(0,8,0,8),UDim2.new(0,25,0,12),Color3.fromRGB(255,0,0),0
    Instance.new("UICorner",speedInd).CornerRadius = UDim.new(1,0) Instance.new("UICorner",jumpInd).CornerRadius = UDim.new(1,0)
    -- Sección SPEED
    local speedSection = Instance.new("Frame",mainFrame)
    speedSection.Size,speedSection.Position,speedSection.BackgroundColor3,speedSection.BorderSizePixel = UDim2.new(1,-20,0,80),UDim2.new(0,10,0,45),Color3.fromRGB(15,22,35),0
    Instance.new("UICorner",speedSection).CornerRadius = UDim.new(0,10)
    local speedTitle = Instance.new("TextLabel",speedSection)
    speedTitle.Size,speedTitle.Position,speedTitle.BackgroundTransparency,speedTitle.Text,speedTitle.TextColor3 = UDim2.new(1,0,0,25),UDim2.new(0,0,0,5),1,"🏃 VELOCIDAD",Color3.fromRGB(0,200,255)
    speedTitle.TextSize,speedTitle.Font = 14,Enum.Font.Code
    -- Presets de velocidad
    local speedPresetFrame = Instance.new("Frame",speedSection)
    speedPresetFrame.Size,speedPresetFrame.Position,speedPresetFrame.BackgroundTransparency = UDim2.new(1,-10,0,25),UDim2.new(0,5,0,30),1
    local speedLayout = Instance.new("UIListLayout",speedPresetFrame)
    speedLayout.FillDirection,speedLayout.HorizontalAlignment,speedLayout.SortOrder,speedLayout.Padding = Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Center,Enum.SortOrder.LayoutOrder,UDim.new(0,3)
    for _,speed in ipairs(speedPresets) do
        local speedBtn = Instance.new("TextButton",speedPresetFrame)
        speedBtn.Size,speedBtn.BackgroundColor3,speedBtn.Text,speedBtn.TextColor3 = UDim2.new(0,35,0,25),Color3.fromRGB(20,30,45),tostring(speed),Color3.new(1,1,1)
        speedBtn.TextSize,speedBtn.Font,speedBtn.BorderSizePixel = 11,Enum.Font.Code,0
        Instance.new("UICorner",speedBtn).CornerRadius = UDim.new(0,6)
        speedBtn.MouseButton1Click:Connect(function()
            currentSpeedValue = speed
            printESP("Velocidad cambiada a "..speed)
            for _,c in pairs(speedPresetFrame:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(20,30,45) c.TextColor3 = Color3.new(1,1,1) end end
            speedBtn.BackgroundColor3,speedBtn.TextColor3 = Color3.fromRGB(0,162,255),Color3.new(0,0,0)
            if speedEnabled then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.WalkSpeed = speed end
                end
            end
        end)
        if speed == 58 then speedBtn.BackgroundColor3,speedBtn.TextColor3 = Color3.fromRGB(0,162,255),Color3.new(0,0,0) end
    end
    -- Botón toggle speed
    local speedToggle = Instance.new("TextButton",speedSection)
    speedToggle.Size,speedToggle.Position,speedToggle.BackgroundColor3 = UDim2.new(0.6,0,0,20),UDim2.new(0.2,0,0,55),Color3.fromRGB(25,35,55)
    speedToggle.Text,speedToggle.TextColor3,speedToggle.TextSize,speedToggle.Font,speedToggle.BorderSizePixel = "DESACTIVAR VELOCIDAD",Color3.fromRGB(0,200,255),12,Enum.Font.Code,0
    Instance.new("UICorner",speedToggle).CornerRadius = UDim.new(0,6)
    -- Sección JUMP
    local jumpSection = Instance.new("Frame",mainFrame)
    jumpSection.Size,jumpSection.Position,jumpSection.BackgroundColor3,jumpSection.BorderSizePixel = UDim2.new(1,-20,0,80),UDim2.new(0,10,0,135),Color3.fromRGB(15,22,35),0
    Instance.new("UICorner",jumpSection).CornerRadius = UDim.new(0,10)
    local jumpTitle = Instance.new("TextLabel",jumpSection)
    jumpTitle.Size,jumpTitle.Position,jumpTitle.BackgroundTransparency,jumpTitle.Text,jumpTitle.TextColor3 = UDim2.new(1,0,0,25),UDim2.new(0,0,0,5),1,"🚀 SÚPER SALTO",Color3.fromRGB(0,255,150)
    jumpTitle.TextSize,jumpTitle.Font = 14,Enum.Font.Code
    -- Presets salto
    local jumpPresetFrame = Instance.new("Frame",jumpSection)
    jumpPresetFrame.Size,jumpPresetFrame.Position,jumpPresetFrame.BackgroundTransparency = UDim2.new(1,-10,0,25),UDim2.new(0,5,0,30),1
    local jumpLayout = Instance.new("UIListLayout",jumpPresetFrame)
    jumpLayout.FillDirection,jumpLayout.HorizontalAlignment,jumpLayout.SortOrder,jumpLayout.Padding = Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Center,Enum.SortOrder.LayoutOrder,UDim.new(0,3)
    for _,jump in ipairs(jumpPresets) do
        local jumpBtn = Instance.new("TextButton",jumpPresetFrame)
        jumpBtn.Size,jumpBtn.BackgroundColor3,jumpBtn.Text,jumpBtn.TextColor3 = UDim2.new(0,35,0,25),Color3.fromRGB(20,45,30),tostring(jump),Color3.new(1,1,1)
        jumpBtn.TextSize,jumpBtn.Font,jumpBtn.BorderSizePixel = 11,Enum.Font.Code,0
        Instance.new("UICorner",jumpBtn).CornerRadius = UDim.new(0,6)
        jumpBtn.MouseButton1Click:Connect(function()
            currentJumpValue = jump
            printESP("Súper salto cambiado a "..jump)
            for _,c in pairs(jumpPresetFrame:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(20,45,30) c.TextColor3 = Color3.new(1,1,1) end end
            jumpBtn.BackgroundColor3,jumpBtn.TextColor3 = Color3.fromRGB(0,255,150),Color3.new(0,0,0)
            if jumpEnabled then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        if humanoid.UseJumpPower then humanoid.JumpPower = jump else humanoid.JumpHeight = jump*0.35 end
                    end
                end
            end
        end)
        if jump == 120 then jumpBtn.BackgroundColor3,jumpBtn.TextColor3 = Color3.fromRGB(0,255,150),Color3.new(0,0,0) end
    end
    -- Botón toggle jump
    local jumpToggle = Instance.new("TextButton",jumpSection)
    jumpToggle.Size,jumpToggle.Position,jumpToggle.BackgroundColor3 = UDim2.new(0.6,0,0,20),UDim2.new(0.2,0,0,55),Color3.fromRGB(25,55,35)
    jumpToggle.Text,jumpToggle.TextColor3,jumpToggle.TextSize,jumpToggle.Font,jumpToggle.BorderSizePixel = "DESACTIVAR SALTO",Color3.fromRGB(0,255,150),12,Enum.Font.Code,0
    Instance.new("UICorner",jumpToggle).CornerRadius = UDim.new(0,6)
    -- Info final
    local infoLabel = Instance.new("TextLabel",mainFrame)
    infoLabel.Size,infoLabel.Position,infoLabel.BackgroundTransparency = UDim2.new(1,0,0,25),UDim2.new(0,0,0,225),1
    infoLabel.Text,infoLabel.TextColor3,infoLabel.TextSize,infoLabel.Font = "🟢 ANTI-PULL Y ANTI-DETECCIÓN ACTIVOS",Color3.fromRGB(100,150,200),12,Enum.Font.Code
    -- Botón cerrar
    local closeButton = Instance.new("TextButton",mainFrame)
    closeButton.Size,closeButton.Position,closeButton.BackgroundColor3 = UDim2.new(0,20,0,20),UDim2.new(1,-25,0,5),Color3.fromRGB(255,50,50)
    closeButton.Text,closeButton.TextColor3,closeButton.TextSize,closeButton.Font,closeButton.BorderSizePixel = "✕",Color3.new(1,1,1),14,Enum.Font.Code,0
    Instance.new("UICorner",closeButton).CornerRadius = UDim.new(0,10)
    closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() printESP("Interfaz cerrada.") end)
    -- Funciones de los toggles
    speedToggle.MouseButton1Click:Connect(function()
        toggleSpeed()
        if speedEnabled then
            speedToggle.Text = "VELOCIDAD ACTIVADA ⚡" speedToggle.TextColor3 = Color3.fromRGB(0,255,100) speedToggle.BackgroundColor3 = Color3.fromRGB(25,55,25)
            TweenService:Create(speedInd,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(0,255,0)}):Play()
        else
            speedToggle.Text = "DESACTIVAR VELOCIDAD" speedToggle.TextColor3 = Color3.fromRGB(0,200,255) speedToggle.BackgroundColor3 = Color3.fromRGB(25,35,55)
            TweenService:Create(speedInd,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(255,0,0)}):Play()
        end
    end)
    jumpToggle.MouseButton1Click:Connect(function()
        toggleJump()
        if jumpEnabled then
            jumpToggle.Text = "SÚPER SALTO ACTIVADO 🚀" jumpToggle.TextColor3 = Color3.fromRGB(0,255,100) jumpToggle.BackgroundColor3 = Color3.fromRGB(25,55,25)
            TweenService:Create(jumpInd,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(0,255,0)}):Play()
        else
            jumpToggle.Text = "DESACTIVAR SALTO" jumpToggle.TextColor3 = Color3.fromRGB(0,255,150) jumpToggle.BackgroundColor3 = Color3.fromRGB(25,55,35)
            TweenService:Create(jumpInd,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(255,0,0)}):Play()
        end
    end)
    -- Animación de entrada
    mainFrame.Size = UDim2.new(0,0,0,0)
    TweenService:Create(mainFrame,TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,320,0,280)}):Play()
    -- Efecto pulsante
    task.spawn(function()
        while screenGui and screenGui.Parent do
            if speedEnabled or jumpEnabled then
                TweenService:Create(stroke,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Color=Color3.fromRGB(50,255,150)}):Play()
                task.wait(1.5)
                TweenService:Create(stroke,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Color=Color3.fromRGB(0,162,255)}):Play()
                task.wait(1.5)
            else
                task.wait(2)
            end
        end
    end)
    printESP("Interfaz visual lista.")
end

--// Respawn handler
player.CharacterAdded:Connect(function()
    printESP("Respawn detectado, restaurando estado...")
    task.wait(2)
    local prevSpeed, prevJump = speedEnabled, jumpEnabled
    speedEnabled, jumpEnabled, isProtected = false, false, false
    disconnectAll(antiPullConnections) disconnectAll(bypassConnections) disconnectAll(jumpConnections)
    task.wait(0.7)
    if prevSpeed then toggleSpeed() end
    if prevJump then toggleJump() end
    printESP("Estado restaurado tras respawn.")
end)

--// Limpieza extrema
Players.PlayerRemoving:Connect(function(leaving)
    if leaving==player then
        isProtected=false
        disconnectAll(antiPullConnections) disconnectAll(bypassConnections) disconnectAll(jumpConnections)
        printESP("Limpieza completa tras salir.")
    end
end)

--// Hotkeys
UserInputService.InputBegan:Connect(function(input,gameProcessed)
    if gameProcessed then return end
    if input.KeyCode==Enum.KeyCode.Q and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then toggleSpeed() printESP("Velocidad alternada con Ctrl+Q") end
    if input.KeyCode==Enum.KeyCode.E and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then toggleJump() printESP("Súper salto alternado con Ctrl+E") end
    if input.KeyCode==Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then createTechGUI() printESP("GUI recreada con Ctrl+R") end
end)

--// Inicialización
printESP("Cargando Blue Speed + Súper Salto para Dekta Executor...")
if not player.Character then player.CharacterAdded:Wait() end
task.wait(1.2)
local character = player.Character
if character then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        originalSpeed = humanoid.WalkSpeed
        originalJumpPower = humanoid.UseJumpPower and humanoid.JumpPower or humanoid.JumpHeight/0.35
    end
end
createTechGUI()
printESP("¡GUI lista y funcional!")
printESP("Comandos rápidos: Ctrl+Q velocidad | Ctrl+E salto | Ctrl+R GUI")
printESP("Valores por defecto -> Velocidad: "..currentSpeedValue.." | Salto: "..currentJumpValue)
