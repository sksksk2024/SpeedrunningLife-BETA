local ResourceService = {}
local ServerScriptService = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Services = ServerScriptService.Services
local PlayerDataService = require(Services.PlayerDataService)
local StateService = require(Services.StateService)
local Constants = require(RS.Modules.Constants)
local SoundUtil = require(RS.Modules.SoundUtil)

-- Sound
local leveledUpSound = Constants.Sounds.leveledUpSound
local energySound = Constants.Sounds.energySound
local drinkSound = Constants.Sounds.drinkSound

-- Track who's recently used what
local cooldowns = {} -- structure: [player][stationName] = os.clock()

function ResourceService:UseStation(player, stationType, tier)
	-- Check player state first
	if StateService:GetState(player) ~= "Idle" then
		return false
	end
	
	-- Check cooldown
	if not cooldowns[player] then
		cooldowns[player] = {}
	end
	
	-- Create unique key for this station
	local stationKey = stationType .. tier -- "DrinkBronze", "WorkoutGold", ...
	
	-- Check if enough time has passed
	local lastUsed = cooldowns[player][stationKey] or 0
	local currentTime = os.clock()
	
	if currentTime - lastUsed < Constants.StationCooldown then
		print(player.Name, "is on cooldown for", stationKey)
		return false
	end
	
	-- Update cooldown
	cooldowns[player][stationKey] = currentTime
	
	-- Calculate the amount based on tier
	--put in constants
	local amounts = {
		bronze = Constants.Tiers.bronze,
		silver = Constants.Tiers.silver,
		golden = Constants.Tiers.golden,
	}
	
	-- Get the actual number for this tier
	local amount = amounts[tier]
	
	if not amount then
		warn("Invalid tier:", tier)
		return false
	end
	
	-- Get player data first
	local data = PlayerDataService:GetData(player)
	if not data then return false end
	
	-- Get hrp
	local character = player.Character
	local hrp = character and character:WaitForChild("HumanoidRootPart") or nil
	if not hrp then return end
	
	-- Determine which stat to update
	local statName
	if stationType == "Drink" then
		statName = "Thirst"
		
		-- Play drink sound
		SoundUtil.playSound(drinkSound, hrp)
	elseif stationType == "Workout" then
		statName = "Energy"
		
		-- Play energy sound
		SoundUtil.playSound(energySound, hrp)
		
	else
		warn("Unknown station type:", stationType)
		return false
	end
	
	-- Get current value and ADD to it
	local currentValue = data[statName]
	local newValue = currentValue + amount
	
	PlayerDataService:UpdateStat(player, statName, newValue)
	
	
	return true
end

return ResourceService
