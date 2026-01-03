local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes
local StartFight = Remotes:WaitForChild("StartFight")

local bullyModule = {}

local bully = script.Parent
local prompt = bully:FindFirstChild("ProximityPrompt")

prompt.Triggered:Connect(function(player)
	-- Tell server to start fight
	StartFight:FireServer(bully)
end)


return bullyModule
