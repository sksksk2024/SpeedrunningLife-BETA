local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Constants)
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)
local SoundUtil = require(RS.Modules.SoundUtil)

local Remotes = RS.Remotes
local StartMinigameTimer = Remotes:WaitForChild("StartMinigameTimer")
local CompleteMinigameTimer = Remotes:WaitForChild("CompleteMinigameTimer")
local TriggerHitObjectVFX = Remotes:WaitForChild("TriggerHitObjectVFX")

 local JumpMinigameService = {}
JumpMinigameService.ActivePlayers = {} -- [player] = {startTime = os.clock()}

-- Get the minigame folder
local minigameFolder = workspace:WaitForChild("JumpMinigame")
local awardGiver = minigameFolder.AwardGiver.JumpLikeMario
local jumper = minigameFolder.Jumper -- Entry point
local jumperTop = minigameFolder.JumperTop
local endPosition = workspace.Spawns.EndPosition
local jumpPads = minigameFolder.JumpPads

-- Constants
local JUMP_POWER_PLAYER = Constants.JumpPowerPlayer
local JUMP_POWER_PAD = Constants.JumpPowerPad
local GRAVITY_SCALE = Constants.GravityScale
local WALK_SPEED = Constants.WalkSpeedMinigame

-- Sounds
local defeatJumpSound = Constants.Sounds.defeatJumpSound
local airSound = Constants.Sounds.airSound
local hitObjectSound = Constants.Sounds.jumpPadHitSound
local winJumpSound = Constants.Sounds.winJumpSound

-- Cooldown tracking
local recentlyTouched = {}
local recentlyCompleted = {}

-- Track air state for sound
local isPlayingAirSound = false
local airSoundInstance = nil

function JumpMinigameService:Init()
	-- Set entry point
	-- when player touches jumper, start their minigame
	jumper.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			warn("No character to START in JUMP MINIGAME")
			return
		end
		
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			warn("No player to START in JUMP MINIGAME")
			return
		end
		
		-- Check if this is the player's CURRENT character
		if player.Character ~= character then
			print("Dead character touched jumper - ignoring")
			return
		end
		
		local humanoid = character and character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			print("Dead character touched jumper - ignoring")
			return
		end
		
		-- Check if player is already in a minigame
		if recentlyTouched[player] then
			return
		end
		
		recentlyTouched[player] = true
		task.delay(2, function()
			recentlyTouched[player] = nil
		end)
		
		self:StartMinigame(player)
		
	end)
	
	-- Initialize all jump pads
	for _, jumpPad in jumpPads:GetChildren() do
		jumpPad.Touched:Connect(function(hit)
			local character = hit.Parent
			if not character then
				warn("No character to JUMP in JUMP MINIGAME")
				return
			end
			
			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				warn("No player to JUMP in JUMP MINIGAME")
				return
			end
			
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid then
				warn("No humanoid to JUMP in JUMP MINIGAME")
				return
			end
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			-- Play touched sound and VFX
			SoundUtil.playSound(hitObjectSound, hrp)
			TriggerHitObjectVFX:FireClient(player)
			
			-- Apply upward velocity to character
			-- Find HumanoidRootPart and set its AssemblyLinearVelocity
			-- or use BodyVelocity for a brief boost
			task.delay(0.1, function()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new(0, JUMP_POWER_PAD, 0)
				bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0) -- Allow full upward force
				bodyVelocity.P = 10000 -- Adjust for responsiveness
				bodyVelocity.Parent = hrp
				game.Debris:AddItem(bodyVelocity, 0.1) -- Clean up after 0.1s
			end)
		end)
	end
	
	-- Set up goal
	-- when player touches goal, end their minigame
	awardGiver.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			warn("No character to WIN in JUMP MINIGAME")
			return
		end
		
		local player = Players:GetPlayerFromCharacter(character)
		
		if not player then
			warn("No player to WIN in JUMP MINIGAME")
			return
		end
		
		-- Prevent multiple completions
		if recentlyCompleted[player] then return end
		
		recentlyCompleted[player] = true
		task.delay(2, function()
			recentlyCompleted[player] = nil
		end)
		
		self:CompleteMinigame(player)
	end)
	
	-- Handle player leaving game
	Players.PlayerRemoving:Connect(function(player)
		if self.ActivePlayers[player] then
			local data = self.ActivePlayers[player]
			
			-- Disconnect connections
			if data.deathConnection then
				data.deathConnection:Disconnect()
			end
			if data.airCheckConnection then
				data.airCheckConnection:Disconnect()
			end
			
			-- Clean up
			self.ActivePlayers[player] = nil
		end
	end)
	
	print("JumpMinigameService initialized")
end

-- Helper function to get model mass
local function GetModelMass(model)
	local totalMass = 0
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			totalMass = totalMass + part:GetMass()
		end
	end
	return totalMass
end

function JumpMinigameService:StartMinigame(player)
	
	-- Check if player already playing
	if self.ActivePlayers[player] then
		warn(player.Name, "already in minigame!")
		return
	end
	
	print(player.Name, "started jump minigame")
	
	-- Get character and change physics
	local character = player.Character
	if not character then
		warn("There is no character for JUMP MINIGAME")
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		warn("There is no humanoid for JUMP MINIGAME")
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn("There is no humanoid root part for JUMP MINIGAME")
		return
	end
	
	-- Store start time
	self.ActivePlayers[player] = {
		startTime = os.clock()
	}
	
	-- Check if player is in air every frame
	local airCheckConnection
	airCheckConnection = RunService.Heartbeat:Connect(function()
		if not character or not character.Parent then
			if airCheckConnection then airCheckConnection:Disconnect() end
			if airSoundInstance then airSoundInstance:Stop() end
			return
		end
		
		humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			if airCheckConnection then airCheckConnection:Disconnect() end
			if airSoundInstance then airSoundInstance:Stop() end
			return
		end
		
		-- Check if player left the minigame area
		local playerPos = hrp.Position
		local jumperPos = jumper.Position
		local distance = (jumperPos - playerPos).Magnitude
		
		-- If player is more than 300 studs away, they left - clean up
		if distance > Constants.DistanceLeaveGame then
			print(player.Name, "left minigame area - cleaning up")
			
			-- Stop air sound
			if airSoundInstance then
				airSoundInstance:Stop()
				airSoundInstance = nil
				isPlayingAirSound = false
			end
		
			-- Disconnect connections
			if airCheckConnection then
				airCheckConnection:Disconnect()
			end
			
			-- Reset physics
			humanoid.JumpPower = Constants.JumpPowerDefault
			humanoid.WalkSpeed = Constants.WalkSpeedDefault
			
			-- Remove BodyForce
			local gravityForce = hrp:FindFirstChild("GravityForce")
			if gravityForce then
				gravityForce:Destroy()
			end
			
			-- Remove from active players
			self.ActivePlayers[player] = nil
			
			CompleteMinigameTimer:FireClient(player, -1)
			
			return
		end
		
		-- Check if in air
		local isInAir = humanoid.FloorMaterial == Enum.Material.Air
		
		if isInAir and not isPlayingAirSound then
			-- Just started being in air - play sound
			isPlayingAirSound = true
			airSoundInstance = SoundUtil.playSound(airSound, hrp, {looped = true})
			self.ActivePlayers[player].airSoundInstance = airSoundInstance
		elseif not isInAir and isPlayingAirSound then
			-- Just landed - stop sound
			isPlayingAirSound = false
			if airSoundInstance then
				airSoundInstance:Stop()
				airSoundInstance = nil
				self.ActivePlayers[player].airSoundInstance = nil
			end
		end
	end)
	
	-- Store connection to disconnect later
	self.ActivePlayers[player].airCheckConnection = airCheckConnection
	

	humanoid.JumpPower = JUMP_POWER_PLAYER
	humanoid.WalkSpeed = WALK_SPEED
	--humanoid.GravityScale = GRAVITY_SCALE
	
	local bodyForce = Instance.new("BodyForce")
	local mass = GetModelMass(character)
	bodyForce.Force = Vector3.new(0, workspace.Gravity * mass * 0.95 + 10, 0)  -- Added +500 boost!
	bodyForce.Name = "GravityForce"
	bodyForce.Parent = character.HumanoidRootPart  -- Put in HumanoidRootPart, not character!
	
	-- Handle death during minigame
	local deathConnection
	deathConnection = humanoid.Died:Connect(function()
		print(player.Name, "died during minigame - cleaning up")
		
		-- Get player data before clearning
		local data = self.ActivePlayers[player]
		
		-- Play defeat sound
		if hrp and hrp.Parent then
			pcall(function()
				SoundUtil.playSound(defeatJumpSound, hrp)
			end)
		end
		
		-- Stop air sound if playing
		if data and data.airSoundInstance then
			pcall(function()
				data.airSoundInstance:Stop()
			end)
		end
		
		-- Disconnect air check
		if data and data.airCheckConnection then
			data.airCheckConnection:Disconnect()
		end
		
		-- Remove BodyForce if it still exists
		if hrp and hrp.Parent then
			local gravityForce = hrp:FindFirstChild("GravityForce")
			if gravityForce then
				gravityForce:Destroy()
			end
		end
		
		-- Remove from active players
		self.ActivePlayers[player] = nil
		
		-- Disconnect this event
		if deathConnection then
			deathConnection:Disconnect()
		end
		
		print(player.Name, "cleanup complete - removed from ActivePlayers")
	end)
	
	-- Store the connection so we can disconnect it later
	self.ActivePlayers[player].deathConnection = deathConnection
	
	-- Start UI timer
	StartMinigameTimer:FireClient(player)
end

function JumpMinigameService:CompleteMinigame(player)
	local data = self.ActivePlayers[player]
	if not data then
		warn(player.Name, "not in minigame!")
		return
	end
	
	-- Calculate time taken
	local completionTime = os.clock() - data.startTime
	print(player.Name, "completed in", completionTime, "seconds")
	
	local character = player.Character
	if not character then
		warn("There is no character for JUMP MINIGAME")
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		warn("There is no humanoid for JUMP MINIGAME")
		return
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then 
		warn("There is no hrp for JUMP MINIGAME")
		return 
	end
	
	-- Play win sound
	SoundUtil.playSound(winJumpSound, hrp)
	
	-- reset player physics
	humanoid.JumpPower = Constants.JumpPowerDefault
	--humanoid.GravityScale = Constants.GravityScaleDefault
	humanoid.WalkSpeed = Constants.WalkSpeedDefault
	
	-- Remove the BodyForce
	local gravityForce = hrp:FindFirstChild("GravityForce")
	if gravityForce then
		gravityForce:Destroy()
	end
	
	-- Disconnect death event
	if data.deathConnection then
		data.deathConnection:Disconnect()	
	end
	if data.airCheckConnection then
		data.airCheckConnection:Disconnect()
	end
	
	-- Remove air sound
	if airSoundInstance then
		airSoundInstance:Stop()
		airSoundInstance = nil
		self.ActivePlayers[player].airSoundInstance = nil
	end
	
	-- Remove player from playing list
	if self.ActivePlayers[player] then
		self.ActivePlayers[player] = nil
	end
		
	-- Teleport player back
	local finishPos = endPosition.CFrame * CFrame.new(0, 5, 0)
	if finishPos then
		hrp.CFrame = finishPos
	else
		warn("No finish position for JUMP MINIGAME")
		hrp.CFrame = CFrame.new(0, 0, 0)
	end
	
	-- End UI timer
	CompleteMinigameTimer:FireClient(player, completionTime)
	
	-- Award 100 XP
	PlayerDataService:AddXP(player, Constants.XPPerJumpWin)
end


return JumpMinigameService