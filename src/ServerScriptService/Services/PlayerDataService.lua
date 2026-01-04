local DEFAULT_DATA = {
	Thirst = 100,
	Energy = 100,
	Level = 1,
	XP = 0,
	Health = 100,
	Damage = 10,
	MaxHealth = 100,
	CompletedLevels = {},
	DefeatedBullies = {},
	HasSeenIntroCutscene = false,
	HasSeenTutorial = false,
}

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Constants = require(RS.Modules.Constants)
local Remotes = RS.Remotes
local Constants = require(RS.Modules.Constants)
local SoundUtil = require(RS.Modules.SoundUtil)

-- Sound
local reviveSound = Constants.Sounds.reviveSound
local leveledUpSound = Constants.Sounds.leveledUpSound

local PlayerDataService = {}
PlayerDataService.Data = {} -- [player.UserId] = {stats table}

local store = DataStoreService:GetDataStore("PlayerData_V1")

local function deepCopy(tbl)
	local copy = {}
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

function PlayerDataService:Load(player)
	local data
	local success, err = pcall(function()
		--data = store:GetAsync(player.UserId)
		print("Doesn't load")
	end)

	if not success or not data then
		warn("Loading default data for:", player.Name)
		data = deepCopy(DEFAULT_DATA)
	end

	-- Calculate max health based on level
	data.MaxHealth = Constants.BaseHealth + (data.Level - 1) * Constants.HealthPerLevel
	data.Damage = Constants.PlayerBaseDamage + (data.Level - 1) * Constants.DamagePerLevel

	if not data.Health or data.Health > data.MaxHealth then
		data.Health = data.MaxHealth
	end

	self.Data[player.UserId] = data

	-- Fire to client so UI can update
	Remotes.UpdateAllStats:FireClient(player, data)

	return data
end

function PlayerDataService:GetData(player)
	return self.Data[player.UserId]
end

function PlayerDataService:UpdateStat(player, statName, value)
	local data = self:GetData(player)
	if not data then return end

	-- Update the stat
	data[statName] = value

	-- Clamp values
	if statName == "Thirst" or statName == "Energy" then
		data[statName] = math.clamp(value, 0, 100)
	end

	-- Notify client
	Remotes.UpdateStat:FireClient(player, statName, data[statName])
end

function PlayerDataService:AddXP(player, amount)
	local data = self:GetData(player)
	if not data then return end

	data.XP += amount

	-- Check for level up
	while true do
		local xpNeeded = Constants.XPToLevelUp[data.Level]
		if not xpNeeded or data.XP < xpNeeded then
			break
		end
		
		-- Level up
		data.XP -= xpNeeded
		data.Level += 1
		
		-- Increase max health
		data.MaxHealth = Constants.BaseHealth + (data.Level - 1) * Constants.HealthPerLevel
		data.Health = data.MaxHealth
		data.Damage = Constants.PlayerBaseDamage + (data.Level - 1) * Constants.DamagePerLevel
		
		-- Get hrp
		local character = player.Character
		local hrp = character and character:WaitForChild("HumanoidRootPart") or nil
		if hrp then 
			-- Play leveled up sound
			SoundUtil.playSound(leveledUpSound, hrp)
		end

		-- Notify client with celebration
		print("🔔 Firing LevelUp remote to", player.Name, "- Level:", data.Level)
		Remotes.LevelUp:FireClient(player, data.Level)
	end

	-- Send ALL stats at once using UpdateAllStats instead of individual updates
	Remotes.UpdateAllStats:FireClient(player, data)
end

function PlayerDataService:DefeatBully(player, bullyLevel)
	local data = self:GetData(player)
	if not data then return end

	-- Award XP
	local xpGain = Constants.XPPerBully["Level" .. bullyLevel]
	self:AddXP(player, xpGain)

	-- Mark bully as defeated (you'll pass bully name later)
	table.insert(data.DefeatedBullies, bullyLevel)
end

--function PlayerDataService:CompleteQuest(player, questName)

--end

-- Initialize
Players.PlayerAdded:Connect(function(player)
	-- Get hrp
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character and character:WaitForChild("HumanoidRootPart") or nil
	if not hrp then return end
	
	PlayerDataService:Load(player)
	
	
	-- Re-send stats when character respawns
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)

		local data = PlayerDataService:GetData(player)
		if data then
			Remotes.UpdateAllStats:FireClient(player, data)
		end
	end)
end)

-- Update data when player leaves, and clean up the data table
Players.PlayerRemoving:Connect(function(player)
	local data = PlayerDataService:GetData(player)
	if not data then return end

	-- Save data here
	local success, err = pcall(function()
		--store:SetAsync(player.UserId, data)
		print("Doesn't saves")
	end)

	if not success then
		warn("Failed to save data for:", player.Name, ":", err)
	end

	PlayerDataService.Data[player.UserId] = nil
end)

return PlayerDataService