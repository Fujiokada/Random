-- Toggle the script on or off
local scriptEnabled = true

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remotes
local spawnTowerRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnTowerServer")
local upgradeTowerRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeTowerServer")
local voteDifficultyRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VoteDifficulty")
local restartRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VoteRestart")

-- Configurations
local towersToPlace = {
    {id = "0aab7263-d40f-4d78-9e9d-e03ffd172234", position = Vector3.new(2489.9009, 123.997, -3216.7412), param3 = 0, param4 = "{a96dfb66-7683-44ed-9958-a2ab26749d2e}"},
    {id = "0ff6b18d-ea72-4468-a7c3-a99ade5ec4a3", position = Vector3.new(2484.0676, 123.997, -3246.5415), param3 = 0, param4 = "{98a1bde7-1b9e-466a-95c3-9f1f9f3c1037}"},
    {id = "71923f34-850b-442a-8305-3e4d3cf2f6f0", position = Vector3.new(2492.5356, 120.997, -3301.3604), param3 = 0, param4 = "{918fc065-2722-4c55-9dbe-143dd5283315}"},
    {id = "79931fab-e2fa-44e0-8d10-e6d8c2b52488", position = Vector3.new(2483.9197, 120.997, -3301.2424), param3 = 0, param4 = "{c4f3ef97-ea97-4f2e-a329-9be3710d5ef8}"}
}

local upgradeLevels = 6 -- Number of upgrades to apply to each tower
local upgradeInterval = 1 -- Time between upgrades in seconds
local voteDifficulty = "Expert" -- Difficulty level to vote for
local towersPlaced = false -- Tracks if towers have already been placed this match

-- Helper function to check if the match has ended
local function isMatchOver()
    local mainGui = PlayerGui:FindFirstChild("MainGui")
    return mainGui and mainGui:FindFirstChild("Retry") ~= nil
end

-- Function to place towers
local function placeTowers()
    if towersPlaced then return end -- Prevent duplicate placement
    print("Placing towers...")
    for _, tower in ipairs(towersToPlace) do
        spawnTowerRemote:FireServer(tower.id, tower.position, tower.param3, tower.param4)
        task.wait(0.5) -- Delay between placing towers
    end
    towersPlaced = true
end

-- Function to upgrade towers
local function upgradeTowers()
    local sizeColliders = workspace:WaitForChild("SizeColliders")
    for _, collider in ipairs(sizeColliders:GetChildren()) do
        local entityId = collider:GetAttribute("EntityID") -- Fetching EntityID from Attributes
        if entityId then
            for level = 2, upgradeLevels + 1 do
                if not scriptEnabled then return end
                print("Upgrading tower with EntityID:", entityId, "to level:", level)
                upgradeTowerRemote:FireServer(tonumber(entityId), level)
                task.wait(upgradeInterval)
            end
        else
            print("Warning: Missing EntityID for collider:", collider.Name)
        end
    end
end

-- Function to restart the match
local function restartMatch()
    print("Restarting match...")
    restartRemote:FireServer() -- Restart the match
    task.wait(1)
    voteDifficultyRemote:FireServer(voteDifficulty) -- Vote for difficulty
    task.wait(1)
    towersPlaced = false -- Reset placement flag for the new match
end

-- Main loop
while scriptEnabled do
    if isMatchOver() then
        -- If the match is over, restart and place towers again
        restartMatch()
    else
        -- If the match is ongoing, place towers and upgrade them
        placeTowers()
        upgradeTowers()
    end
    task.wait(10) -- Delay to prevent excessive checks
end
