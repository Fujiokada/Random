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

local merchantPosition = nil

-- Fetch item names
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

-- Send Discord Webhook Notification
local function sendDiscordNotification()
    if not merchantPosition then return end

    local itemNames = getMerchantItems()
    local itemText = #itemNames > 0 and table.concat(itemNames, "\n") or "Unknown"

    local data = {
        ["username"] = "Merchant Notifier",
        ["content"] = "@everyone 🚨 **A Merchant has spawned!** 🚨",
        ["embeds"] = { {
            ["title"] = "**Merchant Spawned!**",
            ["description"] = "A new **Merchant** has appeared in the world!",
            ["color"] = 16755200, -- Orange
            ["fields"] = {
                { ["name"] = "Position", ["value"] = string.format("X: %.2f, Y: %.2f, Z: %.2f", merchantPosition.X, merchantPosition.Y, merchantPosition.Z), ["inline"] = true },
                { ["name"] = "Items for Sale", ["value"] = itemText, ["inline"] = false },
                { ["name"] = "Timestamp", ["value"] = "<t:" .. os.time() .. ":R>", ["inline"] = true }
            },
            ["footer"] = { ["text"] = "Roblox Merchant Notifier", ["icon_url"] = "https://i.imgur.com/yqbGJC3.png" },
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
        warn("❌ Failed to send merchant notification: " .. tostring(err))
    end
end

-- Find a valid teleport part in MerchantModel
local function getTeleportPart(merchantModel)
    for _, part in ipairs(merchantModel:GetChildren()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

-- Teleport to Merchant
local function teleportToMerchant()
    local merchantRoot = workspace:FindFirstChild("Merchant")
    if merchantRoot then
        local violetFolder = merchantRoot:FindFirstChild("Violet")
        if violetFolder then
            local merchantModel = violetFolder:FindFirstChild("MerchantModel")
            if merchantModel then
                local teleportPart = getTeleportPart(merchantModel)
                if teleportPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = teleportPart.CFrame
                    print("✅ Teleported to Merchant at:", teleportPart.Position)
                    return
                end
            end
        end
    end
    warn("❌ Failed to teleport: No valid teleport part found.")
end

-- Custom Highlight (Outline for Entire Model)
local function highlightMerchant(merchantModel)
    for _, part in ipairs(merchantModel:GetChildren()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("SelectionBox")
            highlight.Adornee = part
            highlight.Color3 = Color3.fromRGB(255, 215, 0) -- Gold
            highlight.SurfaceColor3 = Color3.fromRGB(255, 255, 255)
            highlight.SurfaceTransparency = 0.2
            highlight.LineThickness = 0.05
            highlight.Parent = part
        end
    end
    print("✨ Custom highlight added to Merchant")
end

-- Custom GUI for Teleport
local function createTeleportGUI()
    local screenGui = Instance.new("ScreenGui", player.PlayerGui)
    screenGui.Name = "MerchantTeleportGUI"
    
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 250, 0, 100)
    frame.Position = UDim2.new(0.5, -125, 0.65, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 1, 1)

    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.Text = "A Merchant has spawned! Teleport?"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.Arcade -- Pixel font
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 1

    local yesButton = Instance.new("TextButton", frame)
    yesButton.Size = UDim2.new(0.5, -5, 0.4, 0)
    yesButton.Position = UDim2.new(0, 5, 0.6, 0)
    yesButton.Text = "Yes"
    yesButton.TextColor3 = Color3.new(1, 1, 1)
    yesButton.Font = Enum.Font.Arcade
    yesButton.TextScaled = true
    yesButton.BackgroundColor3 = Color3.new(0, 0, 0)
    yesButton.BorderSizePixel = 2
    yesButton.BorderColor3 = Color3.new(1, 1, 1)

    local noButton = Instance.new("TextButton", frame)
    noButton.Size = UDim2.new(0.5, -5, 0.4, 0)
    noButton.Position = UDim2.new(0.5, 5, 0.6, 0)
    noButton.Text = "No"
    noButton.TextColor3 = Color3.new(1, 1, 1)
    noButton.Font = Enum.Font.Arcade
    noButton.TextScaled = true
    noButton.BackgroundColor3 = Color3.new(0, 0, 0)
    noButton.BorderSizePixel = 2
    noButton.BorderColor3 = Color3.new(1, 1, 1)

    local function closeGUI()
        screenGui:Destroy()
    end

    yesButton.MouseButton1Click:Connect(function()
        teleportToMerchant()
        closeGUI()
    end)

    noButton.MouseButton1Click:Connect(closeGUI)

    task.delay(180, closeGUI)
end

local function checkForMerchant(folder)
    folder.ChildAdded:Connect(function(merchant)
        if merchant:IsA("Model") and merchant.Name == "MerchantModel" then
            task.wait(1.5)
            merchantPosition = getTeleportPart(merchant).Position
            highlightMerchant(merchant)
            sendDiscordNotification()
            createTeleportGUI()
        end
    end)
end

merchantFolder.ChildAdded:Connect(function(newFolder)
    if newFolder:IsA("Folder") and newFolder.Name == "Violet" then
        task.wait(1)
        checkForMerchant(newFolder)
    end
end)

print("🚀 Merchant spawn detector is now running!")
