local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services

local PlayerDataService = require(Services.PlayerDataService)
local PlayerSetupService = require(Services.PlayerSetupService)

local WorldService = require(Services.WorldService)
local DoorService = require(Services.DoorService)

local StateService = require(Services.StateService)
local BullyService = require(Services.BullyService)
local CutsceneService = require(Services.CutsceneService)
local ResourceService = require(Services.ResourceService)
local TrashCollectionService = require(Services.TrashCollectionService)
local JumpMinigameService = require(Services.JumpMinigameService)

local Constants = require(RS.Modules.Constants)
local SoundUtil = require(RS.Modules.SoundUtil)

-- Sound
local reviveSound = Constants.Sounds.reviveSound

-- Initialize services
TrashCollectionService:Init()
WorldService:Init()
DoorService:Init()
PlayerSetupService:Init()
BullyService:Init()
JumpMinigameService:Init()

-- Guide cutscene proximity detection
local GUIDE_TRIGGER_DISTANCE = Constants.TriggerDistance
local guideTriggerModel = workspace.alexs:WaitForChild("GUIDE")

local playersWhoSawGuide = {}

Players.PlayerAdded:Connect(function(player)
	-- wait for character to load
	player.CharacterAdded:Connect(function(character)
		task.wait(2) -- Give time for everything to load

		local data = PlayerDataService:GetData(player)
		print("Player data loaded:", data)
		
		local hrp = character and character:WaitForChild("HumanoidRootPart") or nil
		if not hrp then return end
		
		-- Play Revive sound
		SoundUtil.playSound(reviveSound, hrp)

		-- Play intro cutscene on first join
		--CutsceneService:PlayIntroCutscene(player)
	end)
end)

print("Server initialized")

-- Stats drain loop
task.spawn(function()
	while true do
		task.wait(1)

		for _, player in Players:GetPlayers() do
			local state = StateService:GetState(player)

			-- Don't drain during cutscenes or combat
			if state == "Idle" then
				local data = PlayerDataService:GetData(player)
				if data then
					-- Drain stats
					PlayerDataService:UpdateStat(player, "Thirst", data.Thirst - Constants.ThirstRate)
					PlayerDataService:UpdateStat(player, "Energy", data.Energy - Constants.EnergyRate)

					-- If energy hits 0, drain health
					if (data.Energy <= 0 or data.Thirst <= 0) and data.Health > 0 then
						PlayerDataService:UpdateStat(player, "Health", data.Health - 1)
						print(player.Name, "Losing health from exhaustion!")
					end
				end
			end
		end
	end
end)

-- Guide cutscene proximity check
task.spawn(function()
	while true do
		task.wait(0.5) -- Check twice per second

		for _, player in Players:GetPlayers() do
			-- Skip if already saw guide
			if playersWhoSawGuide[player] then continue end
			
			-- Check if player in correct state
			local state = StateService:GetState(player)
			if state ~= "Idle" then continue end
			
			local character = player.Character
			if not character then continue end

			local rootPart = character:WaitForChild("HumanoidRootPart")
			if not rootPart then continue end
			
			-- Use GetPivot() for Model distance
			local distance = (rootPart.Position - guideTriggerModel:GetPivot().Position).Magnitude

			if distance <= GUIDE_TRIGGER_DISTANCE then
				print(player.Name, "triggered GUIDE curscene")
				playersWhoSawGuide[player] = true
				--CutsceneService:PlayGuideCutscene(player)
			end
		end
	end
end)

--Find all the proximity prompts in a folder -> Goods
for _, station in workspace.Goods:GetChildren() do
	--local primaryPart = station.PrimaryPart
	--if primaryPart then
		--local prompt = primaryPart:FindFirstChild("ProximityPrompt", true)
	--end
	local prompt = station:FindFirstChild("ProximityPrompt", true)
	if prompt then
		prompt.Triggered:Connect(function(player)
			local tier = station:GetAttribute("Tier")
			local stationType = station:GetAttribute("StationType")
			ResourceService:UseStation(player, stationType, tier)
		end)
	end
end