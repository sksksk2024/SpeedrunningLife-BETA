local ts = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes
local CutsceneData = require(RS.Modules.CutsceneData)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local Areas = workspace.Areas

local PlayCutscene = Remotes:WaitForChild("PlayCutscene")
local EndCutscene = Remotes:WaitForChild("EndCutscene")

local gui = script.Parent
local cutsceneFrame = gui:WaitForChild("CutsceneFrame")
local subtitleLabel = cutsceneFrame:WaitForChild("SubtitleLabel")

local activeAnimationTracks = {} -- Table for multiple animations
local subtitleConnection = nil
local animationCache = {} -- Cache preloaded animations

local camera = workspace.CurrentCamera

-- Camera parts
local currentCameraIndexIntro = 1
local currentCameraIndexGuide = 1
local cutsceneStartTime = nil

local cameraCutsceneFolder = workspace:WaitForChild("CameraCutscene", 10)

-- Store original camera settings (we'll set these when cutscene starts)
local originalCameraType = nil
local originalCameraSubject = nil

-- For tracking active camera tween
local activeCameraTween = nil

-- Helper function to safely get camera parts with timeout
local function getCameraPart(partName, timeout)
	timeout = timeout or 5
	
	if not cameraCutsceneFolder then
		warn("CameraCutscene folder not found in workspace")
		return nil
	end
	
	local cameraPart = cameraCutsceneFolder:WaitForChild(partName, timeout)
	
	if not cameraPart then
		warn(string.format("Camera part '%s' not found after %d seconds", partName, timeout))
	end
	
	return cameraPart
end

-- Function to set the cameras
local function setupCutsceneCamera(cutsceneName)
	-- 1. Store the ORIGINAL settings (before we change them)
	originalCameraType = camera.CameraType
	originalCameraSubject = camera.CameraSubject
	
	-- 2. Take control of the camera
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- 3. Position at the FIRST camera
	local firstCameraPart
	if cutsceneName == "Intro" then
		firstCameraPart = getCameraPart("CamIntro1")
	elseif cutsceneName == "Guide" then
		firstCameraPart = getCameraPart("CamGuide1")
	end
	
	-- Position at the first camera (if it exists)
	if firstCameraPart then
		camera.CFrame = firstCameraPart.CFrame
		print("Camera positioned at:", firstCameraPart.Name)
	else
		warn("Could not position camera - first camera part not found for:", cutsceneName)
	end
end

-- Function to restore the camera
local function restoreCameraControl()
	print("Restoring camera control...")
	print("Original type:", originalCameraType)
	print("Original subject:", originalCameraSubject)
	-- 1. Cancel any active tween
	
	if activeCameraTween then
		activeCameraTween:Cancel()
		activeCameraTween = nil
	end
	
	-- 2. Restore original settings
	camera.CameraType = originalCameraType
	camera.CameraSubject = originalCameraSubject
	
	print("Camera restored!")
end

-- Transition between cameras
local function transitionCamera(targetCFrame, duration)
	-- Cancel previous tween if one is running
	if activeCameraTween then
		activeCameraTween:Cancel()
	end
	
	-- Create tween info
	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut
	)
	
	-- Create the tween
	local tween = ts:Create(camera, tweenInfo, {
		CFrame = targetCFrame
	})
	activeCameraTween = tween
	
	-- Play it
	tween:Play()
end

-- Preload all cutscene animations when player spawns
local function preloadCutsceneAnimations()
	local character = player.Character
	if not character then 
		warn("Character doesn't exist")
		return 
	end

	local humanoid = character:WaitForChild("Humanoid")
	if not humanoid then 
		warn("Humanoid doesn't exist")
		return 
	end
	
	-- Preload animations
	for animName, animId in pairs(CutsceneData.Animations) do
		-- Validate the animation ID before trying to use it
		if animId == "" or not animId:match("rbxassetid://%d+") then
			warn("Invalid animation ID for", animName, ":", animId)
			continue -- Skip this animation
		end
		
		if not animationCache[animId] then
			local animation = Instance.new("Animation")
			animation.AnimationId = animId
			animation.Name = animName
			
			local track = humanoid:LoadAnimation(animation)
			animationCache[animId] = track
			
			print("Preloaded cutscene animation:", animName)
		end
	end
end

-- Call preload when character spawns
player.CharacterAdded:Connect(function(character)
	task.wait(0.5)
	animationCache = {} -- Clear cache
	preloadCutsceneAnimations()
end)

-- Also preload immediately if character already exists
if player.Character then
	preloadCutsceneAnimations()
end

local function clearSubtitles()
	if subtitleConnection then
		subtitleConnection:Disconnect()
		subtitleConnection = nil
	end
	subtitleLabel.Visible = false
	subtitleLabel.Text = ""
end

local function stopAllActiveTracks()
	for _, track in pairs(activeAnimationTracks) do
		if track and track.IsPlaying then
			track:Stop()
		end
	end
	activeAnimationTracks = {}
end

local function findCurrentSubtitle(subtitles, currentTime)
	for i = #subtitles, 1, -1 do -- Go backwards to find the most recent subtitle
		local subtitle = subtitles[i]
		if currentTime >= subtitle.time and currentTime < (subtitle.time + subtitle.duration) then
			return subtitle.text
		end
	end
	return nil
end

PlayCutscene.OnClientEvent:Connect(function(cutsceneName, cloneName)
	clearSubtitles()
	stopAllActiveTracks()
	
	local Guide1Area = nil
	local Sound = nil
	
	local subtitles = CutsceneData.Subtitles[cutsceneName]
	if not subtitles then
		warn("No subtitles found for:", cutsceneName)
		return
	end
	
	cutsceneFrame.Visible = true
	subtitleLabel.Visible = true
	
	-- Load and play your animations here
	local character = player.Character
	if not character then 
		warn("Character doesn't exist")
		return 
	end

	local humanoid = character:WaitForChild("Humanoid")
	if not humanoid then 
		warn("Humanoid doesn't exist")
		return 
	end
	
	-- Play ALL animations for this cutscene
	if cutsceneName == "Intro" then
		setupCutsceneCamera("Intro")
		currentCameraIndexIntro = 1
		
		local clone = workspace.GYMCutscene:WaitForChild(cloneName)
		if not clone then
			warn("Clone not found")
			return
		end
		
		local cloneHumanoid = clone:WaitForChild("Humanoid")
		if not cloneHumanoid then 
			warn("Clone humanoid not found")	
			return
		end
		
		-- Setup clone animator
		local cloneAnimator = cloneHumanoid:FindFirstChild("Animator")
		if not cloneAnimator then
			cloneAnimator = Instance.new("Animator")
			cloneAnimator.Parent = cloneHumanoid
		end
		
		-- Load clone animation
		local cloneAnimation = Instance.new("Animation")
		cloneAnimation.AnimationId = CutsceneData.Animations.CutscneIntroPlayerV1
		local cloneAnimTrack = cloneAnimator:LoadAnimation(cloneAnimation)
		
		-- Play and insert clone animation
		cloneAnimTrack:Play()
		table.insert(activeAnimationTracks, cloneAnimTrack)
		print("Clone animation started")
		
		
		local bully = workspace.GYMCutscene:WaitForChild("bully3")
		if bully then
			local bullyHumanoid = bully:WaitForChild("Humanoid")
			if not bullyHumanoid then return end

			local bullyAnimator = bullyHumanoid:FindFirstChild("Animator")
			if not bullyAnimator then
				bullyAnimator = Instance.new("Animator")
				bullyAnimator.Parent = bullyHumanoid
			end
			
			local bullyAnimation = Instance.new("Animation")
			bullyAnimation.AnimationId = CutsceneData.Animations.CutsceneIntroBully1V1
			--local bullyAnimTrack = bullyHumanoid:LoadAnimation(bullyAnimation)
			local bullyAnimTrack = bullyAnimator:LoadAnimation(bullyAnimation)

			bullyAnimTrack:Play()
			table.insert(activeAnimationTracks, bullyAnimTrack)
		else
			warn("Bully not found")
		end
	elseif cutsceneName == "Guide" then
		Guide1Area = Areas:WaitForChild("Guide1Area")
		Sound = Guide1Area.Sound
		setupCutsceneCamera("Guide")
		currentCameraIndexGuide = 1
		print("Guide cutscene started")
		
		-- No animation, just a timer
	end
	
	-- Track the main animation (first one) for timing, OR use timer for Guide
	local mainTrack = activeAnimationTracks[1]
	cutsceneStartTime = os.clock()
	
	-- This is the magic: continuously check animation time OR timer and update subtitles
	subtitleConnection = RunService.Heartbeat:Connect(function()
		local currentTime
		
		-- Determine how to track time based on cutscene type
		if cutsceneName == "Guide" then
			-- Use timer for Guide (16 sec)
			currentTime = os.clock() - cutsceneStartTime
			
			-- End Guide cutscene after 16 seconds
			if currentTime >= 16 then
				clearSubtitles()
				stopAllActiveTracks()
				cutsceneFrame.Visible = false
				EndCutscene:FireServer(cutsceneName)
				restoreCameraControl()
				
				if Guide1Area then
					Guide1Area:Destroy()
				end
				return
			end
		else
			-- Use animation timing for other cutscenes
			if not mainTrack or not mainTrack.IsPlaying then
				clearSubtitles()
				stopAllActiveTracks()
				cutsceneFrame.Visible = false
				EndCutscene:FireServer(cutsceneName)
				restoreCameraControl()
				return
			end
			currentTime = mainTrack.TimePosition or 0
		end
		
		-- Handle subtitles (works for both)
		local currentText = findCurrentSubtitle(subtitles, currentTime)
		
		if currentText then
			subtitleLabel.Text = currentText
			subtitleLabel.Visible = true
		else
			subtitleLabel.Visible = false
		end
		
		-- Handle camera transitions for Intro cutscene
		if cutsceneName == "Intro" then
			if currentTime >= 7 and currentCameraIndexIntro == 1 then
				local cam2 = getCameraPart("CamIntro2")
				if cam2 then
					transitionCamera(cam2.CFrame, 1)
					currentCameraIndexIntro = 2
				end
			elseif currentTime >= 10 and currentCameraIndexIntro == 2 then
				-- Transition to camera 3
				local cam3 = getCameraPart("CamIntro3")
				if cam3 then
					transitionCamera(cam3.CFrame, 0.5)
					currentCameraIndexIntro = 3
				end
			end
		elseif cutsceneName == "Guide" then
			if currentTime >= 5 and currentCameraIndexGuide == 1 then
				print("Switching to Guide Camera 2 at time:", currentTime)  -- ✓ Add this
				local cam2 = getCameraPart("CamGuide2")
				if cam2 then
					transitionCamera(cam2.CFrame, 0.5)
					currentCameraIndexGuide = 2
				end
			elseif currentTime >= 11 and currentCameraIndexGuide == 2 then
				print("Switching to Guide Camera 3 at time:", currentTime)  -- ✓ Add this
				local cam3 = getCameraPart("CamGuide3")
				if cam3 then
					transitionCamera(cam3.CFrame, 0.5)
					currentCameraIndexGuide = 3
				end
			end
		end
	end)
end)