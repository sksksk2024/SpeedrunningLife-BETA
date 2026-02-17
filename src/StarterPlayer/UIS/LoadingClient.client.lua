local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes

local ShowLoadingScreen = Remotes:WaitForChild("ShowLoadingScreen")

local gui = script.Parent
local loadingFrame = gui:WaitForChild("LoadingFrame")

ShowLoadingScreen.OnClientEvent:Connect(function()
	-- Show loading screen
	loadingFrame.Visible = true
	
	-- Wait a bit
	task.wait(2)
	
	-- Hide loading screen
	loadingFrame.Visible = false
end)