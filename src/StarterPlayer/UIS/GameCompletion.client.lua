local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes

local StartCity = Remotes:WaitForChild("StartCity")
local CompleteCity = Remotes:WaitForChild("CompleteCity")

-- UI elements
local gui = script.Parent
local timerFrame = gui:WaitForChild("timerFrame")
local timerLabel = timerFrame:WaitForChild("timerLabel")

-- Hide frame initially
--timerFrame.Visible = false

-- Variable for tracking time until the CompleteCity is fired
local startTime = nil
local trackingTime = false

-- Listen for start signal
StartCity.OnClientEvent:Connect(function()
	startTime = os.clock()
	trackingTime = true
	timerFrame.Visible = true
end)

-- Listen for completion
CompleteCity.OnClientEvent:Connect(function(completeCityTimer)
	trackingTime = false
	
	print("Received completion time:", completeCityTimer)
	
	-- Format time
	timerLabel.Text = string.format("City: %.3fs", completeCityTimer)
end)


-- Update loop
task.spawn(function()
	while true do
		task.wait(0.1) -- update 10 times per second

		if trackingTime and startTime then
			local elapsed = os.clock() - startTime
			timerLabel.Text = string.format("Time: %.3fs", elapsed)
		end
	end
end)