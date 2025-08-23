-- RemoteSpy básico con Interfaz Visual
-- Crea una ventana flotante mostrando los RemoteEvents y RemoteFunctions llamados desde el cliente

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteSpyGui"
ScreenGui.ResetOnSpawn = false

-- Crea la ventana principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 300)
main.Position = UDim2.new(0, 100, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Text = "RemoteSpy"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255,170,0)
title.Parent = main

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1,0,1,-30)
scrolling.Position = UDim2.new(0,0,0,30)
scrolling.BackgroundTransparency = 0.2
scrolling.BackgroundColor3 = Color3.fromRGB(40,40,40)
scrolling.CanvasSize = UDim2.new(0,0,10,0)
scrolling.ScrollBarThickness = 10
scrolling.Parent = main

ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function addLog(txt)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 16
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = txt
    label.Parent = scrolling
    label.Position = UDim2.new(0,0,0,#scrolling:GetChildren()*0.04)
    scrolling.CanvasSize = UDim2.new(0,0,0,20 * #scrolling:GetChildren())
end

-- Hook RemoteEvent/RemoteFunction
local mt = getrawmetatable(game)
if setreadonly then setreadonly(mt, false) end
local oldNamecall = mt.__namecall

mt.__namecall = function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) and (method == "FireServer" or method == "InvokeServer") then
        local str = "["..tostring(self.ClassName).."] "..self:GetFullName().." : "..method.."\n  Args: "
        for i,v in ipairs(args) do
            str = str .. "["..i.."]="..tostring(v).."  "
        end
        addLog(str)
    end
    return oldNamecall(self, ...)
end

addLog("RemoteSpy iniciado (solo tú ves esto).")
