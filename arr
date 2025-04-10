-- Define keybinds
local recordKey = Enum.KeyCode.P
local replayKey = Enum.KeyCode.L

-- Variables for tracking state
local isRecording = false
local isReplaying = false
local recordedRemotes = {}

-- Variable to stop replaying
local replayLoop

-- Hook into remotes using getrawmetatable
local mt = getrawmetatable(game)
setreadonly(mt, false)

-- Store the original __namecall method
local oldNamecall = mt.__namecall

-- Overwrite __namecall to hook into remote firing
mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        -- Record the remote call if recording is active
        if isRecording then
            table.insert(recordedRemotes, {remote = self, args = {...}})
            print("Recorded remote:", self.Name)
        end
    end
    return oldNamecall(self, ...)
end

setreadonly(mt, true)

-- Function to start replaying recorded remotes
local function startReplay()
    if #recordedRemotes == 0 then
        print("No remotes to replay!")
        return
    end

    isReplaying = true
    replayLoop = task.spawn(function()
        while isReplaying do
            for _, data in ipairs(recordedRemotes) do
                local remote = data.remote
                local args = data.args
                remote:FireServer(unpack(args))
                print("Replayed remote:", remote.Name)
                task.wait(2) -- Replay interval
            end
        end
    end)
end

-- Function to stop replaying
local function stopReplay()
    isReplaying = false
    if replayLoop then
        task.cancel(replayLoop)
        replayLoop = nil
    end
    print("Stopped replaying remotes.")
end

-- Keybind handling
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Toggle recording
    if input.KeyCode == recordKey then
        isRecording = not isRecording
        if isRecording then
            print("Started recording remotes.")
            recordedRemotes = {} -- Clear previous recordings
        else
            print("Stopped recording remotes. Total recorded:", #recordedRemotes)
        end
    end

    -- Toggle replay
    if input.KeyCode == replayKey then
        if not isReplaying then
            print("Started replaying remotes.")
            startReplay()
        else
            print("Stopping replaying remotes.")
            stopReplay()
        end
    end
end)
