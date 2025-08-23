-- CONFIG
getgenv().webhookHigh = "https://discord.com/api/webhooks/1406981313847890074/vauBXZdz-kN4Dz52PSVVAtBFgN6xOUv9KlllGWRK-IYtbf3BZPL2hbOOrjb4YiI15aTz"

-- Target pets
getgenv().TargetPetNames = {
    "Graipuss Medussi",
    "La Grande Combinasion",
    "Garama and Madundung",
    "Sammyni Spyderini",
    "Pot Hotspot",
    "Nuclearo Dinossauro",
    "Chicleteira Bicicleteira",
    "Los Combinasionas",
    "Dragon Cannelloni",
    "Unclito Samito"
}

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- PRIVATE SERVER CHECK
local function isPrivateServer()
    return (game.PrivateServerId and game.PrivateServerId ~= "")
        or (game.VIPServerId and game.VIPServerId ~= "")
end

local function buildJoinLink(placeId, jobId)
    return string.format(
        "https://chillihub1.github.io/chillihub-joiner/?placeId=%d&gameInstanceId=%s",
        placeId,
        jobId
    )
end

-- KICK CHECK
if isPrivateServer() then
    LocalPlayer:Kick("Kicked because in private server")
    return
end

-- WEBHOOK SEND
local function sendWebhook(foundPets, jobId)
    local formattedPets = table.concat(foundPets, ", ")
    local joinLink = buildJoinLink(game.PlaceId, jobId)

    local embedData = {
        username = "UCT Hub Pet Finder",
        embeds = { {
            title = "🐾 Pet(s) Found!",
            description = "**Pet(s):**\n" .. formattedPets,
            color = 65280,
            fields = {
                {
                    name = "Job ID",
                    value = jobId,
                    inline = true
                },
                {
                    name = "Join Link",
                    value = string.format("[Click to join server](%s)", joinLink),
                    inline = false
                }
            },
            footer = { text = "Made by UCTHub" },
            timestamp = DateTime.now():ToIsoDate()
        } }
    }

    local jsonData = HttpService:JSONEncode(embedData)
    local req = http_request or request or (syn and syn.request)
    if req then
        local success, err = pcall(function()
            req({
                Url = getgenv().webhookHigh,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
        if success then
            print("✅ Webhook sent")
        else
            warn("❌ Webhook failed:", err)
        end
    else
        warn("❌ No HTTP request function available")
    end
end

-- PET CHECK
local function checkForPets()
    local found = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            for _, target in ipairs(getgenv().TargetPetNames) do
                if obj.Name == target then
                    table.insert(found, obj.Name)
                    break
                end
            end
        end
    end
    return found
end

-- MAIN LOOP
task.spawn(function()
    while true do
        local petsFound = checkForPets()

        if #petsFound > 0 then
            print("✅ Pets found:", table.concat(petsFound, ", "))
            sendWebhook(petsFound, game.JobId)
        else
            print("🔍 No pets found")
        end

        task.wait(15)
    end
end)
