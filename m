local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")
local httpService = game:GetService("HttpService")
local starterGui = game:GetService("StarterGui")

local webhookURL = "https://discord.com/api/webhooks/1339427763555270718/5KBiqurMM4ct8Z73J4DNKGjsd_NfCFygM8RVPkiy-uEg5WfbkC0wlFvJNqGDnH_h-2aw"
local merchantFolder = workspace:WaitForChild("Merchant")
local merchantGuiPath = player.PlayerGui:WaitForChild("VioletBuyGUI").Merchant.Items

local httpRequest = syn and syn.request or request or http_request or fluxus.request
if not httpRequest then
    error("Your executor does not support HTTP requests.")
end

local merchantPosition = nil -- Store merchant position globally

-- Function to fetch item names properly
local function getMerchantItems()
    local itemList = {}

    task.wait(1) -- Ensure GUI loads

    for _, frame in pairs(merchantGuiPath:GetChildren()) do
        if frame:IsA("Frame") then
            local itemTitle = frame:FindFirstChild("ItemTitle")
            if itemTitle and itemTitle:IsA("TextLabel") and itemTitle.Text ~= "" then
                table.insert(itemList, itemTitle.Text)
            end
        end
    end

    return itemList
end

-- Send Discord Notification
local function sendDiscordNotification()
    if not merchantPosition then return end

    local itemNames = getMerchantItems()
    local itemText = #itemNames > 0 and table.concat(itemNames, "\n") or "Unknown"

    local data = {
        ["username"] = "Merchant Notifier",
        ["content"] = "@everyone 🚨 **A Merchant has spawned!** 🚨",
        ["embeds"] = {{
            ["title"] = "**Merchant Spawned!**",
            ["description"] = "A new **Merchant** has appeared in the world!",
            ["color"] = 16755200, -- Orange
            ["fields"] = {
                {
                    ["name"] = "Position",
                    ["value"] = string.format("X: %.2f, Y: %.2f, Z: %.2f", merchantPosition.X, merchantPosition.Y, merchantPosition.Z),
                    ["inline"] = true
                },
                {
                    ["name"] = "Items for Sale",
                    ["value"] = itemText,
                    ["inline"] = false
                },
                {
                    ["name"] = "Timestamp",
                    ["value"] = "<t:" .. os.time() .. ":R>",
                    ["inline"] = true
                }
            },
            ["footer"] = { ["text"] = "Roblox Merchant Notifier" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local jsonData = httpService:JSONEncode(data)

    local success, err = pcall(function()
        httpRequest({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)

    if success then
        print("✅ Merchant notification sent!")
    else
        warn("❌ Failed to send merchant notification:", err)
    end
end

-- Teleport to the stored merchant position
local function teleportToMerchant()
    if merchantPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(merchantPosition)
        print("✅ Teleported to Merchant at:", merchantPosition)
    else
        warn("❌ Failed to teleport: Merchant position not set.")
    end
end

-- Show Teleport Prompt
local function showTeleportNotification()
    starterGui:SetCore("SendNotification", {
        Title = "Merchant Spawned!",
        Text = "A merchant has appeared! Teleport?",
        Duration = 999999, -- Stays until interacted with
        Button1 = "Yes",
        Button2 = "No",
        Callback = function(response)
            if response == "Yes" then
                teleportToMerchant()
            end
        end
    })
end

-- Detect and store merchant position
local function checkForMerchant(folder)
    folder.ChildAdded:Connect(function(merchant)
        if merchant:IsA("Model") and merchant.Name == "MerchantModel" then
            task.wait(1.5) -- Wait for full loading
            local rootPart = merchant:FindFirstChild("HumanoidRootPart")
            if rootPart then
                merchantPosition = rootPart.Position
                print("🔔 Merchant detected at:", merchantPosition)
                sendDiscordNotification()
                showTeleportNotification()
            end
        end
    end)

    for _, merchant in ipairs(folder:GetChildren()) do
        if merchant:IsA("Model") and merchant.Name == "MerchantModel" then
            task.wait(1.5) -- Wait for full loading
            local rootPart = merchant:FindFirstChild("HumanoidRootPart")
            if rootPart then
                merchantPosition = rootPart.Position
                print("🔔 Existing Merchant detected at:", merchantPosition)
                sendDiscordNotification()
                showTeleportNotification()
                break
            end
        end
    end
end

local function monitorMerchantFolder()
    merchantFolder.ChildAdded:Connect(function(newFolder)
        if newFolder:IsA("Folder") and newFolder.Name == "Violet" then
            print("📂 New merchant folder detected:", newFolder.Name)

            task.wait(1) -- Wait for merchant model to be added
            checkForMerchant(newFolder)
        end
    end)
end

monitorMerchantFolder()

print("🚀 Merchant spawn detector is now running!")
