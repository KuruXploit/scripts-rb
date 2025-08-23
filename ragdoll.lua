-- RemoteSpy seguro, sin hooks peligrosos ni LogService

local player = game:GetService("Players").LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local remoteTypes = {"RemoteEvent", "RemoteFunction"}
local foundRemotes = {}

-- Crea una GUI discreta con nombre aleatorio
local guiName = "Gui" .. math.random(100000,999999)
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,350,0,250)
frame.Position = UDim2.new(0,35,0,75)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,0,25)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextSize = 22
label.TextColor3 = Color3.fromRGB(255,200,60)
label.Text = "RSpy"
label.Parent = frame

local logs = Instance.new("TextBox")
logs.Size = UDim2.new(1,0,1,-25)
logs.Position = UDim2.new(0,0,0,25)
logs.BackgroundTransparency = 0.2
logs.BackgroundColor3 = Color3.fromRGB(30,30,30)
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

-- Función para registrar el evento
local function logRemote(remote, method, ...)
    local args = {...}
    local msg = "["..os.date("%X").."] ["..remote.ClassName.."] "..remote:GetFullName().." : "..method.."\n  Args: "
    for i,v in ipairs(args) do
        msg = msg .. "["..i.."]="..tostring(v).."  "
    end
    msg = msg .. "\n"
    logs.Text = logs.Text .. msg
end

-- Espía solo los remotos ya existentes
for _,desc in ipairs(replicated:GetDescendants()) do
    if table.find(remoteTypes, desc.ClassName) then
        if not foundRemotes[desc] then
            foundRemotes[desc] = true
            -- Eventos
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...) logRemote(desc, "OnClientEvent", ...) end)
                desc.OnClientInvoke = function(...) logRemote(desc, "OnClientInvoke", ...); return nil end
            end
            -- Funciones
            if desc:IsA("RemoteFunction") then
                desc.OnClientInvoke = function(...) logRemote(desc, "OnClientInvoke", ...); return nil end
            end
        end
    end
end

-- Espía solo tus llamadas (esto es seguro)
for _,desc in ipairs(replicated:GetDescendants()) do
    if table.find(remoteTypes, desc.ClassName) then
        if not foundRemotes[desc.."spy"] then
            foundRemotes[desc.."spy"] = true
            if desc:IsA("RemoteEvent") then
                desc.FakeFireServer = function(self, ...)
                    logRemote(self, "FireServer", ...)
                end
            elseif desc:IsA("RemoteFunction") then
                desc.FakeInvokeServer = function(self, ...)
                    logRemote(self, "InvokeServer", ...)
                end
            end
        end
    end
end

-- Opcional: Oculta la GUI con F4
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F4 then
        gui.Enabled = not gui.Enabled
    end
end)

logs.Text = logs.Text .. "[INFO] RemoteSpy seguro iniciado. Presiona F4 para ocultar/mostrar la ventana.\n"
