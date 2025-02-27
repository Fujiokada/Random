local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")
local httpService = game:GetService("HttpService")
local starterGui = game:GetService("StarterGui")

local webhookURL = "https://discord.com/api/webhooks/1339427763555270718/5KBiqurMM4ct8Z73J4DNKGjsd_NfCFygM8RVPkiy-uEg5WfbkC0wlFvJNqGDnH_h-2aw"
local merchantFolder = workspace:WaitForChild("Merchant")
local merchantGuiPath = player.PlayerGui:WaitForChild("VioletBuyGUI").Merchant.Items

local merchantPosition = nil -- Store merchant position globally

-- Function to fetch item names properly
local function getMerchantItems()
    local itemList = {}

    -- Wait for GUI elements to be fully created
    task.wait(1)

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
            ["footer"] = {
                ["text"] = "Roblox Merchant Notifier",
                ["icon_url"] = "https://i.imgur.com/yqbGJC3.png"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local jsonData = httpService:JSONEncode(data)

    local success, err = pcall(function()
        httpService:PostAsync(webhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("✅ Merchant notification sent!")
    else
        warn("❌ Failed to send merchant notification: " .. tostring(err))
    end
end

-- Find any valid teleport part inside the MerchantModel
local function getTeleportPart(merchantModel)
    for _, part in ipairs(merchantModel:GetDescendants()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

-- Teleport function
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
    warn("❌ Failed to teleport: No valid part found in MerchantModel.")
end

-- Custom GUI for teleport decision
local function createTeleportGui()
    if player.PlayerGui:FindFirstChild("MerchantTeleportGui") then
        player.PlayerGui.MerchantTeleportGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MerchantTeleportGui"
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.6, -75)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "A merchant has appeared! Teleport?"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.Pixelify
    textLabel.TextScaled = true
    textLabel.Parent = frame

    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.4, 0, 0.3, 0)
    yesButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    yesButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.Text = "Yes"
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.Font = Enum.Font.Pixelify
    yesButton.TextScaled = true
    yesButton.Parent = frame

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.4, 0, 0.3, 0)
    noButton.Position = UDim2.new(0.5, 0, 0.6, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    noButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
    noButton.Text = "No"
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.Font = Enum.Font.Pixelify
    noButton.TextScaled = true
    noButton.Parent = frame

    yesButton.MouseButton1Click:Connect(function()
        teleportToMerchant()
        screenGui:Destroy()
    end)

    noButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    task.delay(180, function()
        if screenGui then
            screenGui:Destroy()
        end
    end)
end

-- Monitor merchant folder
merchantFolder.ChildAdded:Connect(function(newFolder)
    if newFolder:IsA("Folder") and newFolder.Name == "Violet" then
        task.wait(1)
        local merchantModel = newFolder:FindFirstChild("MerchantModel")
        if merchantModel then
            merchantPosition = getTeleportPart(merchantModel) and getTeleportPart(merchantModel).Position
            sendDiscordNotification()
            createTeleportGui()
        end
    end
end)

print("🚀 Merchant spawn detector is now running!")
