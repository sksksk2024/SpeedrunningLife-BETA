local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local isShaking = false
local shakeIntensity = 0
local shakeDuration = 0

-- This runs 60x per second(60 frames)
RunService.RenderStepped:Connect(function(deltaTime)
	if isShaking then
		shakeDuration = shakeDuration - deltaTime
		
		if shakeDuration <= 0 then
			isShaking = false
			shakeIntensity = 0
		else
			local randomX = math.random(-100, 100) / 100 * shakeIntensity
			local randomY = math.random(-100, 100) / 100 * shakeIntensity
			local randomZ = math.random(-100, 100) / 100 * shakeIntensity
			
			local shakeCFrame = CFrame.Angles(
				math.rad(randomX),
				math.rad(randomY),
				math.rad(randomZ)
			)
			
			camera.CFrame = camera.CFrame * shakeCFrame
		end
	end
end)

-- STEP 5: Trigger the shake
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.Q then
		-- Start shaking
		isShaking = true
		shakeIntensity = 5 -- how strong (in degrees)
		shakeDuration = 0.5 -- how long (in seconds)
		
		print("SHAKE ACTIVATED")
	end
end)