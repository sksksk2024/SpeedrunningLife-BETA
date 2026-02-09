// Inside Animate2, as a MODULE SCRIPT!!!
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")
local footprintFolder = ReplicatedStorage:WaitForChild("Footprints")

local footsteps = require(script:WaitForChild("Footsteps"))
local lastFootstepSound = nil
local animTracks = {}
local transitionTime = 0.2
local jumpAnimTime = 0
local holdingTool = false

local function StopAllAnimations(ignoreName)
	for i, animTrack in pairs(animator:GetPlayingAnimationTracks()) do
		-- Dacă animația care rulează este de tip Action, nu o opri!
		if (animTrack.Priority == Enum.AnimationPriority.Action or animTrack.Priority == Enum.AnimationPriority.Action2
			or animTrack.Priority == Enum.AnimationPriority.Action3 or animTrack.Priority == Enum.AnimationPriority.Action4) and animTrack.Name ~= "Jump" then
			continue
		end

		-- Restul logicii tale...
		if animTrack.Name == ignoreName then continue end
		animTrack:Stop(transitionTime)
	end
end

local function AdjustAnimation(name, speed, weight)
	animTracks[name]:AdjustSpeed(speed)
	animTracks[name]:AdjustWeight(weight)
end

local function PlayAnimation(name, speed, weight)
	animTracks[name]:Play(transitionTime)
	AdjustAnimation(name, speed, weight)
	StopAllAnimations(name)
end

local function Running(speed)
	if speed > 0.5 then	
		
		local relativeSpeed = speed / 16
		local runAnimWeight, walkAnimWeight = 0.001, 0.001

		if relativeSpeed < 0.5 then 
			-- Walking speed
			walkAnimWeight = 1	
		elseif relativeSpeed < 0.9 then
			-- Blend run and walk
			local fadeInRun = (relativeSpeed - 0.5)/(1 - relativeSpeed)
			walkAnimWeight = 1 - fadeInRun
			runAnimWeight  = fadeInRun
			relativeSpeed = 1
		else 
			-- Simply run
			runAnimWeight = 1
		end
		
		if animTracks["Run"].IsPlaying then
			if speed > 0.5 then
				AdjustAnimation("Walk", relativeSpeed, walkAnimWeight)
				AdjustAnimation("Run", relativeSpeed, runAnimWeight)	
			end
		else
			PlayAnimation("Walk", relativeSpeed, walkAnimWeight)
			PlayAnimation("Run", relativeSpeed, runAnimWeight)
		end
	else
		PlayAnimation("Idle")
	end
end

local function Jumping()
	jumpAnimTime = 0.31
	PlayAnimation("Jump")
end

local function Falling()
	if (jumpAnimTime <= 0) then
		PlayAnimation("Fall")
	end
end

local function Climbing(speed)
	if speed == 0 then
		if not animTracks["Run"].IsPlaying then
			AdjustAnimation("Climb", 0, 1)
		end
	else
		local relativeSpeed = speed / 5
		if animTracks["Climb"].IsPlaying then
			AdjustAnimation("Climb", relativeSpeed, 1)
		else
			PlayAnimation("Climb", relativeSpeed)
		end
		
	end
end

local function Swimming(speed)
	if speed > 1 then
		local relativeSpeed = speed / 10
		if animTracks["Swim"].IsPlaying then
			AdjustAnimation("Swim", relativeSpeed, 1)
		else
			PlayAnimation("Swim", relativeSpeed)
		end
	elseif not animTracks["SwimIdle"].IsPlaying then
		PlayAnimation("SwimIdle", 1)
	end
end

local function PlayFootstepSound(foot, material)
	if not foot then return end

	local sounds = footsteps.sounds[material]
	if not sounds then return end

	local random = Random.new()
	local soundId = sounds[random:NextInteger(1, #sounds)]

	if soundId and soundId ~= lastFootstepSound then
		lastFootstepSound = soundId
		local sfx = Instance.new("Sound")
		sfx.SoundId = soundId
		sfx.RollOffMaxDistance = 100
		sfx.RollOffMinDistance = 10
		sfx.Volume = footsteps.volume[material] or 0.5
		sfx.Parent = foot
		sfx:Play()
		task.spawn(function()
			sfx.Ended:Wait()
			sfx:Destroy()
		end)
	else
		PlayFootstepSound(foot, material)
	end
end

local function OnFootStep(side)
	local foot = character:FindFirstChild(side.."Foot")
	local floorMaterial = humanoid.FloorMaterial
	local material = footsteps.materialMap[floorMaterial]

	PlayFootstepSound(foot, material)

	if material then
		local footprint = footprintFolder:FindFirstChild(material)
		if footprint then
			footprint = footprint:Clone()
			footprint:PivotTo(foot.CFrame * CFrame.new(0, -footprint.PrimaryPart.Size.Y, 0))
			footprint.Parent = workspace
			Debris:AddItem(footprint, footsteps.decay[material] or 3)
		end
	end
end

function LoadAnimations()
	local animationIDs = {
		Climb = "rbxassetid://10921257536",
		Fall = "rbxassetid://10921262864",
		Idle = "rbxassetid://10921258489",
		Jump = "rbxassetid://10921263860",
		Run = "rbxassetid://126901379250953", -- My custom anim: 11096667011
		Walk = "rbxassetid://10921269718",
		Swim = "rbxassetid://10921264784",
		SwimIdle = "rbxassetid://10921265698",
		Tool = "rbxassetid://507768375"
	}

	local defaultAnimateScript = character:WaitForChild("Animate", 3)
	if defaultAnimateScript then
		defaultAnimateScript:Destroy()
	end

	for name, id in pairs(animationIDs) do
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local track = animator:LoadAnimation(animation)
		animTracks[name] = track
		animTracks[name].Name = name
		if name == "Idle" then
			animTracks[name].Priority = Enum.AnimationPriority.Idle
		elseif name == "Run" or name == "Walk" or name == "Climb" then
			animTracks[name].Priority = Enum.AnimationPriority.Movement
		elseif name == "Tool" or name == "Jump" --[[or name == "Fall"]] then
			animTracks[name].Priority = Enum.AnimationPriority.Action
		end

	end

	animTracks["Idle"]:Play()

	humanoid.Running:Connect(Running)
	humanoid.Jumping:Connect(Jumping)
	humanoid.FallingDown:Connect(Jumping)
	humanoid.FreeFalling:Connect(Falling)
	humanoid.Climbing:Connect(Climbing)
	humanoid.Swimming:Connect(Swimming)

	-- Custom animation with keyframe marker required for this to work
	if animationIDs.Run ~= "rbxassetid://10921261968" then
		local oldRunSound = root:WaitForChild("Running")
		oldRunSound:Destroy()
		animTracks["Run"]:GetMarkerReachedSignal("Footstep"):Connect(OnFootStep)
	end
end

LoadAnimations()

RunService.Heartbeat:Connect(function(deltaTime)
	if (jumpAnimTime > 0) then
		jumpAnimTime = jumpAnimTime - deltaTime
	end
	
	local tool = character:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		holdingTool = true
		if not animTracks["Tool"].IsPlaying then
			animTracks["Tool"]:Play(transitionTime)
		end
	else
		holdingTool = false
		animTracks["Tool"]:Stop(transitionTime)
	end
end)