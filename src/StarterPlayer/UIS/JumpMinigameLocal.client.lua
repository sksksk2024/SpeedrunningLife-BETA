local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes

local StartMinigameTimer = Remotes:WaitForChild("StartMinigameTimer")
local CompleteMinigameTimer = Remotes:WaitForChild("CompleteMinigameTimer")

local gui = script.Parent
local timerFrame = gui:WaitForChild("timerFrame")
local timerLabel = timerFrame:WaitForChild("timerLabel")

local startTime = nil
local running = false

-- Listen for start signal
StartMinigameTimer.OnClientEvent:Connect(function()
	startTime = os.clock()
	running = true
	timerFrame.Visible = true
end)

-- Listhen for completion
CompleteMinigameTimer.OnClientEvent:Connect(function(completionTime)
	running = false

	-- Show final time
	timerLabel.Text = string.format("Completed: %.3fs!", completionTime)
	
	-- Wait 3 seconds to show result, then hide
	task.wait(1.2)
	timerFrame.Visible = false
	timerLabel.Text = "Time: 0.00s" -- Reset for next time
end)

-- Update loop
task.spawn(function()
	while true do
		task.wait(0.1) -- update 10 times per second
		
		if running and startTime then
			local elapsed = os.clock() - startTime
			timerLabel.Text = string.format("Time: %.3fs", elapsed)
		end
	end
end)