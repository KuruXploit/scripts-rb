-- RemoteSpy GUI discreta y randomizada, para Roblox
-- By KuruXploit Copilot

local player = game:GetService("Players").LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local function rndStr(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local s = ""
    for i = 1, len do
        local idx = math.random(1, #chars)
        s = s .. chars:sub(idx, idx)
    end
    return s
end

local guiName = rndStr(10)
local frameName = rndStr(12)
local labelName = rndStr(12)
local boxName = rndStr(12)

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.Enabled = true

local frame = Instance.new("Frame")
frame.Name = frameName
frame.Size = UDim2.new(0, 380, 0, 200)
frame.Position = UDim2.new(0, 25, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(23,23,28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Name = labelName
label.Size = UDim2.new(1,0,0,26)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.TextColor3 = Color3.fromRGB(200,200,80)
label.Text = rndStr(6+math.random(2,3))
label.Parent = frame

local logs = Instance.new("TextBox")
logs.Name = boxName
logs.Size = UDim2.new(1,0,1,-26)
logs.Position = UDim2.new(0,0,0,26)
logs.BackgroundTransparency = 0.08
logs.BackgroundColor3 = Color3.fromRGB(28,28,32)
logs.TextColor3 = Color3.new(1,1,1)
logs.TextXAlignment = Enum.TextXAlignment.Left
logs.TextYAlignment = Enum.TextYAlignment.Top
logs.Font = Enum.Font.Code
logs.TextSize = 16
logs.Text = ""
logs.ClearTextOnFocus = false
logs.TextWrapped = false
logs.TextEditable = false
logs.MultiLine = true
logs.Parent = frame

-- Drag para la ventana
local drag, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                drag = false
            end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and drag then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Ocultar/mostrar con F4
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F4 then
        gui.Enabled = not gui.Enabled
    end
end)

-- Logging function
local function addLog(remote, method, ...)
    local args = {...}
    local msg = "["..os.date("%X").."] ["..remote.ClassName.."] "..remote.Name.." : "..method.."\n  Args: "
    for i,v in ipairs(args) do
        msg = msg .. "["..i.."]="..tostring(v).."  "
    end
    logs.Text = (logs.Text..msg.."\n"):sub(-3600) -- máx. 3600 chars
end

-- Espía remotos de ReplicatedStorage (no hooks peligrosos)
for _,desc in ipairs(replicated:GetDescendants()) do
    if desc:IsA("RemoteEvent") then
        desc.OnClientEvent:Connect(function(...)
            addLog(desc, "OnClientEvent", ...)
        end)
    elseif desc:IsA("RemoteFunction") then
        desc.OnClientInvoke = function(...)
            addLog(desc, "OnClientInvoke", ...)
        end
    end
end

logs.Text = logs.Text.."["..os.date("%X").."] Spy listo. Pulsa F4 para ocultar/mostrar.\n"

-- Elimina variables globales sospechosas
if getfenv then
    for k,v in pairs(getfenv()) do
        if tostring(k):lower():find("remotespy") then
            getfenv()[k] = nil
        end
    end
end
