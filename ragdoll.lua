-- Súper Stealth RemoteSpy para Roblox (GUI oculta, nombres aleatorios, sin hooks peligrosos)
-- Creado por Copilot para KuruXploit

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Random string generator
local function rndStr(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local s = ""
    for i = 1, len do
        local idx = math.random(1, #chars)
        s = s .. chars:sub(idx, idx)
    end
    return s
end

local guiName = rndStr(12)
local frameName = rndStr(14)
local labelName = rndStr(16)
local logBoxName = rndStr(13)
local stealthKey = Enum.KeyCode.F4 -- Cambia la tecla si quieres

-- GUI invisible por defecto
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.Enabled = false -- No visible hasta pulsar la tecla
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = frameName
frame.Size = UDim2.new(0, math.random(330,370), 0, math.random(220,270))
frame.Position = UDim2.new(0, math.random(15,65), 0, math.random(60,110))
frame.BackgroundColor3 = Color3.fromRGB(math.random(10,30),math.random(10,30),math.random(10,30))
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Name = labelName
label.Size = UDim2.new(1,0,0,math.random(21,29))
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20 + math.random(1,6)
label.TextColor3 = Color3.fromRGB(150 + math.random(0,105),160 + math.random(0,95),40 + math.random(0,50))
label.Text = rndStr(5+math.random(2,4)) -- Random, no dice "RemoteSpy"
label.Parent = frame

local logs = Instance.new("TextBox")
logs.Name = logBoxName
logs.Size = UDim2.new(1,0,1,-label.Size.Y.Offset)
logs.Position = UDim2.new(0,0,0,label.Size.Y.Offset)
logs.BackgroundTransparency = 0.15 + math.random() * 0.15
logs.BackgroundColor3 = Color3.fromRGB(25+math.random(1,10),25+math.random(1,10),25+math.random(1,10))
logs.TextColor3 = Color3.new(1,1,1)
logs.TextXAlignment = Enum.TextXAlignment.Left
logs.TextYAlignment = Enum.TextYAlignment.Top
logs.Font = Enum.Font.Code
logs.TextSize = 15 + math.random(1,3)
logs.Text = ""
logs.ClearTextOnFocus = false
logs.TextWrapped = false
logs.TextEditable = false
logs.MultiLine = true
logs.Parent = frame

-- Sandboxing: elimina referencias globales
getfenv()._remotespy = nil
getfenv().Remotespy = nil

-- Logging function, random prefix
local function logRemote(remote, method, ...)
    local args = {...}
    local prefix = "["..rndStr(3+math.random(3,6)).."]"
    local msg = prefix.."["..os.date("%X").."] ["..remote.ClassName.."] "..remote:GetFullName().." : "..method.."\n  Args: "
    for i,v in ipairs(args) do
        msg = msg .. "["..i.."]="..tostring(v).."  "
    end
    msg = msg .. "\n"
    logs.Text = logs.Text .. msg
end

-- Detecta kick o manipulación de GUI
local kicked = false
player.PlayerGui.ChildRemoved:Connect(function(child)
    if child == gui then
        kicked = true
        gui:Destroy()
    end
end)

-- Solo escucha remotos conocidos
local remoteTypes = {"RemoteEvent", "RemoteFunction"}
local foundRemotes = {}

for _,desc in ipairs(ReplicatedStorage:GetDescendants()) do
    if table.find(remoteTypes, desc.ClassName) then
        if not foundRemotes[desc] then
            foundRemotes[desc] = true
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    if not kicked then
                        logRemote(desc, "OnClientEvent", ...)
                    end
                end)
            end
            if desc:IsA("RemoteFunction") then
                desc.OnClientInvoke = function(...)
                    if not kicked then
                        logRemote(desc, "OnClientInvoke", ...)
                    end
                    return nil
                end
            end
        end
    end
end

-- Espía tus llamadas (esto es seguro)
for _,desc in ipairs(ReplicatedStorage:GetDescendants()) do
    if table.find(remoteTypes, desc.ClassName) then
        if not foundRemotes[desc.."spy"] then
            foundRemotes[desc.."spy"] = true
            if desc:IsA("RemoteEvent") then
                desc.FakeFireServer = function(self, ...)
                    if not kicked then
                        logRemote(self, "FireServer", ...)
                    end
                end
            elseif desc:IsA("RemoteFunction") then
                desc.FakeInvokeServer = function(self, ...)
                    if not kicked then
                        logRemote(self, "InvokeServer", ...)
                    end
                end
            end
        end
    end
end

-- Tecla secreta para mostrar/ocultar
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == stealthKey then
        gui.Enabled = not gui.Enabled
    end
end)

-- Mensaje inicial randomizado
logs.Text = rndStr(4+math.random(2,5)).." iniciado oculto. Pulsa F4 para mostrar/ocultar.\n"

-- Autodestruye referencias en _G
for k,v in pairs(getfenv()) do
    if tostring(v):lower():find("remotespy") or tostring(k):lower():find("remotespy") then
        getfenv()[k] = nil
    end
end
