local RunService = game:GetService("RunService")
local ts = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Constants)
local insideAmbient = Constants.Sounds.insideAmbient
local outsideAmbient = Constants.Sounds.outsideAmbient
local SoundService = game:GetService("SoundService")
local soundUtil = require(RS.Modules.SoundUtil)
local LightAvoidersFolder = workspace.LightAvoiders
local Lighting = game:GetService("Lighting")
local OUTSIDE_AMBIENT = Constants.Lighting.outsideAmbient
local INSIDE_AMBIENT = Constants.Lighting.insideAmbient
local TWEEN_SPEED = Constants.Lighting.tweenSpeed

local currentAmbientSound = nil
local isTransitioning = false -- prevent overlapping transitions

local function playAmbient(soundData)
	-- prevent stacking during transitions
	if isTransitioning then
		return currentAmbientSound
	end
	isTransitioning = true
	
	local oldSound = currentAmbientSound
	
	-- Create new sound first
	local newSound = soundUtil.playSound(
		soundData,
		SoundService,
		{looped = true}
	)
	
	-- Fade out old sound if it exists
	if oldSound and oldSound.Parent then
		local fadeOutIntro = TweenInfo.new(0.5)
		local fadeOut = ts:Create(oldSound, fadeOutIntro, {
			Volume = 0
		})
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			oldSound:Stop()
			oldSound:Destroy()
		end)
	end
	
	-- Set new sound as current
	currentAmbientSound = newSound
	
	-- Small delay before allowing next transition
	task.wait(0.6)
	isTransitioning = false
	
	return newSound
end

-- Start default ambient
currentAmbientSound = playAmbient(outsideAmbient)

local function updateLighting(isInside)
	local targetAmbient = isInside and INSIDE_AMBIENT or OUTSIDE_AMBIENT
	
	local tweenInfo = TweenInfo.new(TWEEN_SPEED, Enum.EasingStyle.Linear)
	local tween = ts:Create(Lighting, tweenInfo, {
		Ambient = targetAmbient,
		OutdoorAmbient = targetAmbient
	})
	tween:Play()
	
	-- Transition between ambient sounds
	if isInside then
		playAmbient(insideAmbient)
	else
		playAmbient(outsideAmbient)
	end
	
	for _, lightAvoider in pairs(LightAvoidersFolder:GetChildren()) do
		if lightAvoider:IsA("BasePart") then
			-- Make transparency 0 if inside, 1 if outside
			local tweenInfo2 = TweenInfo.new(TWEEN_SPEED, Enum.EasingStyle.Cubic)
			local tween = ts:Create(lightAvoider, tweenInfo2, {
				Transparency = isInside and 0 or 1
			})
			tween:Play()
			
			print("YES")
		end
	end
end

-- Checking every 60 times per second(1 per frame) to check if there is a roof above you
local wasInside = false
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")
RunService.Heartbeat:Connect(function()
	-- Check if character and head still exist
	if not character or not character.Parent then 
		character = player.Character	
		if not character then return end
		head = character:WaitForChild("Head")
	end
	
	if not head or not head.Parent then
		head = character:FindFirstChild("Head")
		if not head then return end
	end
	
	-- Shoot a "laser" 50 studs straight up from the player's head
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local raycastResult = workspace:Raycast(head.Position, Vector3.new(0, 120, 0), raycastParams)
	
	-- If the laser hits something, we are "Inside"
	local isInside = raycastResult ~= nil
	
	if isInside ~= wasInside then
		wasInside = isInside
		updateLighting(isInside)
	end
end)