local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PassService = require(ServerScriptService.Services.PassService)

local Constants = require(RS.Modules.Constants)
local Remotes = RS.Remotes
local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)
local StateService = require(ServerScriptService.Services.StateService)
local SoundUtil = require(RS.Modules.SoundUtil)

-- Remotes
local FightEndWin = Remotes:WaitForChild("FightEndWin")
local StartFight = Remotes:WaitForChild("StartFight")
local FightEndDefeat = Remotes:WaitForChild("FightEndDefeat")
local UpdateBullyHealth = Remotes:WaitForChild("UpdateBullyHealth")
local UpdatePlayerHealth = Remotes:WaitForChild("UpdatePlayerHealth")
local PlayerAttack = Remotes:WaitForChild("PlayerAttack")

-- VFX Remotes
local TriggerPunchPlayerVFX = Remotes:WaitForChild("TriggerPunchPlayerVFX")
local TriggerPunchBullyVFX = Remotes:WaitForChild("TriggerPunchBullyVFX")
local TriggerKickPlayerVFX = Remotes:WaitForChild("TriggerKickPlayerVFX")

local BullyService = {}
local animationCache = {} -- [animationId] = Animation instance
BullyService.ActiveFights = {} -- [player] = {bully = model, bullyHealth = 100, playerHealth = 100}

-- Sounds
local winSound = Constants.Sounds.winFightSound
local defeatSound = Constants.Sounds.defeatFightSound
local punchPlayerSound = Constants.Sounds.playerPunch
local kickPlayerSound = Constants.Sounds.playerKick
local punchBullySound = Constants.Sounds.bullyPunchSound

-- Configuration
local ATTACK_DAMAGE = Constants.PlayerBaseDamage -- Player damage per E press
local PLAYER_ATTACK_INTERVAL = 0.3
local BULLY_ATTACK_INTERVAL = 0.3
local VICTORY_XP_MULTIPLIER = 1.5

-- Helper function to play animations
local function playAnimation(character, animationId, speed)
	-- If not speed, default to 1
	speed = speed or 1

	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Create Animation instance
	local anim = Instance.new("Animation")
	anim.AnimationId = animationId
	animationCache[animationId] = anim -- Cache it for next time
	print("Animation not preloaded:", animationId)

	-- Load it into the humanoid
	local track = humanoid:LoadAnimation(anim)

	if speed then
		track:AdjustSpeed(speed)
	end

	-- Play it
	track:Play()

	-- Clean up after animation finishes
	track.Stopped:Connect(function()
		-- animation doesn't need to be destroyed, animator handles it
		--anim:Destroy()
	end)

	return track
end

-- Helper function to stop all animations on a character
local function stopAllAnimations(character)
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Get all animation tracks
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			track:Stop()
		end
	end
end

function BullyService:Init()
	local Players = game:GetService("Players")

	-- Hide defeated bullies when player joins
	Players.PlayerAdded:Connect(function(player)
		-- Wait for data to load
		task.wait(1)

		local playerData = PlayerDataService:GetData(player)


		if playerData then
			-- Hide all defeated bullies for this player
			for _, bullyName in playerData.DefeatedBullies do
				local bully = workspace:FindFirstChild(bullyName)
				if bully then
					-- Make invisible to this player only
					-- For now, just destroy it server-side
					print("Hiding defeated bully:", bullyName, "for", player.Name)
					task.delay(1, function()
						bully:Destroy()
					end)
				end
			end
		end

		-- Handle character spawning
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			if not humanoid then return end
			local hrp = character:WaitForChild("HumanoidRootPart")
			if not hrp then return end

			-- Clean up fights when player dies
			humanoid.Died:Connect(function()
				-- If player was in a fight, end it
				if self.ActiveFights[player] then
					-- Mark as defeat for player
					BullyService:EndFight(player, "Defeat")

					print(player.Name, "died during fight - cleanning up")
					self.ActiveFights[player] = nil
					StateService:SetState(player, "Idle")
				end
			end)

			task.wait(0.5)

			-- Preload and Cache all player animations
			for animName, animId in pairs(Constants.Animations.Player) do
				if animId ~= "" and not animationCache[animId] then
					local anim = animationCache[animId]
					if not anim then
						anim = Instance.new("Animation")
						anim.AnimationId = animId
						animationCache[animId] = anim
					end

					-- Cache it
					animationCache[animId] = anim

					-- Preload it
					humanoid:LoadAnimation(anim)
					print("Preloaded:", animName, animId)
				end
			end
		end)
	end)
end




function BullyService:StartFight(player, bully)
	local playerData = PlayerDataService:GetData(player)

	if not playerData then return end

	-- Check if player already in an active fight
	if self.ActiveFights[player] then
		print(player.Name, "is already in a fight")
		return
	end

	-- If player is dead, no fight
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid or player.Character.Humanoid.Health <= 0 then
		print(player.Name, "is dead")
		return
	end

	local bullyName = bully.Name

	if table.find(playerData.DefeatedBullies, bullyName) then
		print(player.Name, "already defeated", bullyName)
		return -- NO fight
	end

	-- Check if player already in combat
	if StateService:GetState(player) ~= "Idle" then return end

	-- Get bully level from model
	local bullyLevel = bully:GetAttribute("Level") or 1
	local bullyMaxHealth = Constants.BullyDamage["Level" .. bullyLevel] * 10 -- Scale health to damage

	-- Get player data
	local playerData = PlayerDataService:GetData(player)
	if not playerData then return end

	-- Lock player state
	StateService:SetState(player, "InCombat")
	local prompt = bully:FindFirstChild("ProximityPrompt")
	if prompt then
		prompt.Enabled = false
	end

	-- Setup fight data
	self.ActiveFights[player] = {
		bully = bully,
		bullyLevel = bullyLevel,
		bullyHealth = bullyMaxHealth,
		bullyMaxHealth = bullyMaxHealth,
		playerHealth = playerData.Health,
		playerMaxHealth = playerData.MaxHealth,
		lastPlayerAttack = os.clock(),
		bullyLoopRunning = false,
	}


	-- Fire remote to client to show fight UI
	StartFight:FireClient(player, bullyLevel, bullyMaxHealth, playerData.MaxHealth)

	-- Start bully attack loop
	task.spawn(function()
		self:BullyAttackLoop(player)
	end)

	print(player.Name, "started fight with Level", bullyLevel, "bully")
end

function BullyService:PlayerAttack(player)
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")

	local fight = self.ActiveFights[player]
	if not fight then return end

	--task.wait(PLAYER_ATTACK_INTERVAL)
	if os.clock() - fight.lastPlayerAttack < PLAYER_ATTACK_INTERVAL then return end
	fight.lastPlayerAttack = os.clock()

	-- Play player's punch animation
	-- Generate a random number between 1 and 2
	local random = math.random(1, 2)
	if random == 1 then
		playAnimation(player.Character, Constants.Animations.Player.Punch, 1)
		-- Play player's punch sound
		SoundUtil.playSound(punchPlayerSound, hrp)
		-- Trigger punch VFX on player
		TriggerPunchPlayerVFX:FireClient(player)
	else
		playAnimation(player.Character, Constants.Animations.Player.Kick, 1)
		-- Play player's kick sound
		SoundUtil.playSound(kickPlayerSound, hrp)
		-- Trigger kick VFX on player
		TriggerKickPlayerVFX:FireClient(player)
	end

	-- Play bully's hurt animation
	playAnimation(fight.bully, Constants.Animations.Bully.Hurt)

	-- Calculate damage
	local playerData = PlayerDataService:GetData(player)
	local damage = playerData.Damage

	if fight.bullyHealth <= 0 then return end
	fight.bullyHealth -= damage
	print("Bully health:", fight.bullyHealth)

	-- Update UI
	UpdateBullyHealth:FireClient(player, fight.bullyHealth)

	-- Check victory
	if fight.bullyHealth <= 0 then
		self:EndFight(player, "Victory")
	end
end

function BullyService:BullyAttackLoop(player)
	-- get bully's hrp
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	while self.ActiveFights[player] do
		local fight = self.ActiveFights[player]

		-- Wait for attack interval
		task.wait(BULLY_ATTACK_INTERVAL)

		-- Check if fight still active
		if not self.ActiveFights[player] then return end

		-- Play bully's punch animation
		playAnimation(fight.bully, Constants.Animations.Bully.Punch, 2)

		-- Play player's hurt animation
		playAnimation(player.Character, Constants.Animations.Player.Hurt)

		-- Play bully's punch sound
		SoundUtil.playSound(punchBullySound, hrp)

		-- Trigger punch VFX on bully
		TriggerPunchBullyVFX:FireClient(player, fight.bully)

		-- Calculate damage
		local bullyDamage = Constants.BullyDamage["Level" .. fight.bullyLevel]
		fight.playerHealth -= bullyDamage

		-- Update UI
		UpdatePlayerHealth:FireClient(player, fight.playerHealth)

		print("Player took", bullyDamage, "damage. Health:", fight.playerHealth)

		-- Check if player defeated
		if fight.playerHealth <= 0 then
			self:EndFight(player, "Defeat")
			break
		end
	end
end

function BullyService:EndFight(player, result)
	local hrp = player.Character:WaitForChild("HumanoidRootPart")
	if not hrp then return end

	local fight = self.ActiveFights[player]
	if not fight then return end

	-- Stop all animations first
	stopAllAnimations(player.Character)
	stopAllAnimations(fight.bully)

	if result == "Victory" then
		-- Play victory animation
		local track = playAnimation(player.Character, Constants.Animations.Player.Victory)
		-- Wait for animation to finish before destroying bully
		if track then
			track.Stopped:Wait()
		end

		-- Play bully defeat animation
		local bullyDefeatTrack = playAnimation(fight.bully, Constants.Animations.Bully.Defeat)

		-- Wait for defeat animation to finish
		if bullyDefeatTrack then
			bullyDefeatTrack.Stopped:Wait()
		end

		-- Award XP
		local xpGain = Constants.XPPerBully["Level" .. fight.bullyLevel]
		PlayerDataService:AddXP(player, xpGain)

		-- Mark bully as defeated (add to DefeatedBullies table later)
		local bullyName = fight.bully.Name
		table.insert(PlayerDataService:GetData(player).DefeatedBullies, bullyName)

		print(player.Name, "VICTORY! Gained", xpGain, "XP")

		-- Get player's current stats
		local data = PlayerDataService:GetData(player)
		if not data then return end

		-- Drain both stats by 10
		PlayerDataService:UpdateStat(player, "Thirst", data.Thirst - 10)
		PlayerDataService:UpdateStat(player, "Energy", data.Energy - 10)

		-- Fire victory celebration to client
		FightEndWin:FireClient(player, "Victory", xpGain)

		-- Win Sound
		--task.delay(3, function()
		--	winSound:Play()
		--	winSound.Volume = Constants.Sounds.winFightSound
		--end)
		SoundUtil.playSound(winSound, hrp, {duration = 3})

		-- Remove bully AFTER animations and UI
		task.delay(1, function()
			fight.bully:Destroy()
		end)
	elseif result == "Defeat" then
		-- Play player's defeat animation
		playAnimation(player.Character, Constants.Animations.Player.Defeat)

		-- Re-enable prompt for retry
		local prompt = fight.bully:FindFirstChild("ProximityPrompt")
		if prompt then
			prompt.Enabled = true
		end

		local data = PlayerDataService:GetData(player)
		if not data then return end

		-- Drain both stats by 25 when defeated
		PlayerDataService:UpdateStat(player, "Thirst", data.Thirst - 25)
		PlayerDataService:UpdateStat(player, "Energy", data.Energy - 25)

		-- Play defeat sound
		SoundUtil.playSound(defeatSound, hrp)

		-- Player lost, show defeat UI
		FightEndDefeat:FireClient(player, "Defeat")
		print(player.Name, "DEFEAT!")
	end
	
	PassService:ApplySpeed(player)

	-- Clean up
	self.ActiveFights[player] = nil
	StateService:SetState(player, "Idle")
end

-- Connect remote for player attacks
PlayerAttack.OnServerEvent:Connect(function(player)
	BullyService:PlayerAttack(player)
end)

return BullyService