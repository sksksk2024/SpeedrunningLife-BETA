-- LocalScript in StarterCharacterScripts
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Constants)

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local lastSavedHealth = 100

RS.Remotes.UpdateAllStats.OnClientEvent:Connect(function(data)
	if data and data.Health then
		lastSavedHealth = data.Health
	end
end)

humanoid.Died:Connect(function()
	-- Așteptăm puțin să se actualizeze stats-urile de la server
	task.wait(0.7) 

	if lastSavedHealth <= 0 then
		MarketplaceService:PromptProductPurchase(player, Constants.DevProducts.BadDeath)
	end
end)