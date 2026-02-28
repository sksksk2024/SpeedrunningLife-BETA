local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Constants)

local PassService = {}
PassService.HasSpeedPass = {} -- [UserId] = true/false

function PassService:ApplySpeed(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	-- If has pass, the speed is 32
	local multiplier = self.HasSpeedPass[player.UserId] and 2 or 1
	humanoid.WalkSpeed = Constants.WalkSpeedDefault * multiplier
end

-- Tabel of functions for every step
local PassActions = {
	[Constants.Passes.DoubleSpeed] = function(player)
		PassService.HasSpeedPass[player.UserId] = true
		PassService:ApplySpeed(player)
		print("Viteza dubla activata pentru ", player.Name)
	end,
	[Constants.Passes.Teleportation] = function(player)
		-- Activation of a UI tool for teleportation
		print("Teleportare activata pentru ", player.Name)
	end,
}

function PassService:Init()
	-- Check the player if it's in the server
	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			local success, hasPass = pcall(function()
				return MarketPlaceService:UserOwnsGamePassAsync(player.UserId, Constants.Passes.DoubleSpeed)
			end)
			
			if success and hasPass then
				self.HasSpeedPass[player.UserId] = true
				self:ApplySpeed(player)
			end
		end)
		
		-- Reapply the speed at respawn if he has the pass
		player.CharacterAdded:Connect(function(character)
			task.wait(0.5)
			self:ApplySpeed(player)
		end)
	end)
	
	-- Listen when someone buys while in the server
	MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
		if wasPurchased and passId == Constants.Passes.DoubleSpeed then
			self.HasSpeedPass[player.UserId] = true
			self:ApplySpeed(player)
		end
	end)
end

return PassService
