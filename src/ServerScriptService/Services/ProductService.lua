local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local MapResetEvent = ServerStorage.Bindables:WaitForChild("MapResetEvent")

local Constants = require(RS.Modules.Constants)
local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)

local ProductService = {}

-- Table of functions for dev products
local ProductActions = {
	[Constants.DevProducts.RechargeResources] = function(player)
		PlayerDataService:UpdateStat(player, "Thirst", 100)
		PlayerDataService:UpdateStat(player, "Energy", 100)
		print("Recharged resources")
		return true
	end,
	
	[Constants.DevProducts.LevelUp] = function(player)
		local data = PlayerDataService:GetData(player)
		if data then
			-- Calculat how much XP is needed until leveling up
			local xpNeeded = Constants.XPToLevelUp[data.Level] or 0
			local xpToGive = xpNeeded - data.XP
			PlayerDataService:AddXP(player, xpToGive)
			print("Level up bought by ", player.Name)
			return true
		end
		return false
	end,
	
	[Constants.DevProducts.RechargeMap] = function(player)
		-- Respawn Trash
		local lakeMinigame = workspace:FindFirstChild("LakeMinigame")
		if lakeMinigame and lakeMinigame:FindFirstChild("Trash") then
			lakeMinigame.Trash:Destroy()
			local backupTrash = ServerStorage.MapBackups.Trash:Clone()
			backupTrash.Parent = lakeMinigame
		end
		
		-- Respawn Bullies (Level 1-5)
		local alexs = workspace:FindFirstChild("alexs")
		if alexs then
			for i = 1, 5 do
				local folderName = "Level" .. i
				if alexs:FindFirstChild(folderName) then
					alexs[folderName]:Destroy()
					local backupBully = ServerStorage.MapBackups[folderName]:Clone()
					backupBully.Parent = alexs
				end
			end
		end
		
		-- Reset the bully list
		local data = PlayerDataService:GetData(player)
		if data then
			data.DefeatedBullies = {}
			RS.Remotes.UpdateAllStats:FireClient(player, data)
		end
		
		if MapResetEvent then
			MapResetEvent:Fire()
		end
		
		return true
	end,
	
	[Constants.DevProducts.BadDeath] = function(player)
		local data = PlayerDataService:GetData(player)
		if data then
			PlayerDataService:UpdateStat(player, "Health", data.MaxHealth)
			PlayerDataService:UpdateStat(player, "Thirst", 100)
			PlayerDataService:UpdateStat(player, "Energy", 100)
			
			player:LoadCharacter()
			return true
		end
		return false
	end,
}

function ProductService:Init()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		local action = ProductActions[receiptInfo.ProductId]
		if action then
			local success = action(player)
			if success then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end


return ProductService
