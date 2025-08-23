-- Súper Stealth RemoteSpy: Solo consola, sin GUI, sin hooks peligrosos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteTypes = {"RemoteEvent", "RemoteFunction"}
local foundRemotes = {}

local function safeLog(remote, method, ...)
    local args = {...}
    local msg = "[RemoteSpy] ["..remote.ClassName.."] "..remote:GetFullName().." : "..method.."\n  Args: "
    for i,v in ipairs(args) do
        msg = msg .. "["..i.."]="..tostring(v).."  "
    end
    print(msg)
end

-- Espía solo los remotos ya existentes en ReplicatedStorage
for _,desc in ipairs(ReplicatedStorage:GetDescendants()) do
    if table.find(remoteTypes, desc.ClassName) then
        if not foundRemotes[desc] then
            foundRemotes[desc] = true
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    safeLog(desc, "OnClientEvent", ...)
                end)
            end
            if desc:IsA("RemoteFunction") then
                desc.OnClientInvoke = function(...)
                    safeLog(desc, "OnClientInvoke", ...)
                    return nil
                end
            end
        end
    end
end

print("[RemoteSpy] Solo consola listo. Cambia print() por appendfile() si tu exploit lo soporta para guardar logs en archivo.")
