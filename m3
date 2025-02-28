local player = game:GetService("Players").LocalPlayer

-- Remove existing GUI if already present
local existingGui = player.PlayerGui:FindFirstChild("TeleportPreviewGui")
if existingGui then existingGui:Destroy() end

-- Create ScreenGui
local teleportGui = Instance.new("ScreenGui")
teleportGui.Name = "TeleportPreviewGui"
teleportGui.Parent = player.PlayerGui

-- Create Main Frame (Rounded + Semi-transparent)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100) -- Smaller Size
frame.Position = UDim2.new(0.5, -125, 0.05, 0) -- Pops up at the top
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black Background
frame.BackgroundTransparency = 0.3 -- Semi-transparent
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255) -- White Outline
frame.Parent = teleportGui

-- Apply UI Corner (Rounded edges)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15) -- Smooth rounded edges
corner.Parent = frame

-- Background Texture (White Stripes)
local texture = Instance.new("ImageLabel")
texture.Size = UDim2.new(1, 0, 1, 0)
texture.BackgroundTransparency = 1
texture.Image = "rbxassetid://10921993419" -- Sample diagonal stripe texture
texture.ImageTransparency = 0.7 -- Light stripes
texture.Parent = frame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Merchant Spawned!"
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.TextScaled = true
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White Text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = frame

-- Yes Button (Rounded + White Outline)
local yesButton = Instance.new("TextButton")
yesButton.Text = "Yes"
yesButton.Size = UDim2.new(0.4, 0, 0.4, 0)
yesButton.Position = UDim2.new(0.05, 0, 0.5, 0)
yesButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black Button
yesButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White Text
yesButton.Font = Enum.Font.GothamBold
yesButton.TextScaled = true
yesButton.BorderSizePixel = 2
yesButton.BorderColor3 = Color3.fromRGB(255, 255, 255) -- White Outline
yesButton.Parent = frame

local yesCorner = Instance.new("UICorner")
yesCorner.CornerRadius = UDim.new(0, 10)
yesCorner.Parent = yesButton

-- No Button (Rounded + White Outline)
local noButton = Instance.new("TextButton")
noButton.Text = "No"
noButton.Size = UDim2.new(0.4, 0, 0.4, 0)
noButton.Position = UDim2.new(0.55, 0, 0.5, 0)
noButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black Button
noButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White Text
noButton.Font = Enum.Font.GothamBold
noButton.TextScaled = true
noButton.BorderSizePixel = 2
noButton.BorderColor3 = Color3.fromRGB(255, 255, 255) -- White Outline
noButton.Parent = frame

local noCorner = Instance.new("UICorner")
noCorner.CornerRadius = UDim.new(0, 10)
noCorner.Parent = noButton

-- Button Click Event (Destroys GUI)
local function removeGui()
    if teleportGui then teleportGui:Destroy() end
end

yesButton.MouseButton1Click:Connect(removeGui)
noButton.MouseButton1Click:Connect(removeGui)

-- Auto-remove GUI after 300 seconds (5 minutes)
task.delay(300, removeGui)
