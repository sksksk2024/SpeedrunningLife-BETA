local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

print("📷 Camera shake system loaded!")

-- STEP 2: Think about what makes a "shake"
-- A shake is basically: moving the camera randomly in small amounts
-- Question: What properties can we modify?
-- - camera.CFrame (position AND rotation)
-- - We want ROTATION shake (like an earthquake)

-- STEP 3: What makes it look natural?
-- - It should be RANDOM (not the same pattern)
-- - It should FADE OUT (start strong, get weaker)
-- - It should be SMOOTH (not teleport instantly)

-- 🤔 YOUR TASK: Before proceeding, answer these:
-- 1. How do you generate random rotation? (Hint: CFrame.Angles uses radians)
-- 2. How do you make something "fade out"? (Multiply by a decreasing value?)
-- 3. How often should we update? (Every frame? Once per second?)

-- STEP 4: Let's build a SIMPLE shake first
local isShaking = false
local shakeIntensity = 0
local shakeDuration = 0
local originalIntensity = 0

-- This runs 60x per second(60 frames)
RunService.RenderStepped:Connect(function(deltaTime)
	if isShaking then
		shakeDuration = shakeDuration - deltaTime

		if shakeDuration <= 0 then
			isShaking = false
			shakeIntensity = 0
		else
			-- Calculate fade out (gets weaker over time)
			local fadeProgress = shakeDuration / (originalIntensity / 5) -- adjust fade speed
			shakeIntensity = originalIntensity * fadeProgress
			
			-- generate random rotation
			local randomX = math.random(-100, 100) / 100 * shakeIntensity
			local randomY = math.random(-100, 100) / 100 * shakeIntensity
			local randomZ = math.random(-100, 100) / 100 * shakeIntensity

			-- apply shake to camera
			local shakeCFrame = CFrame.Angles(
				math.rad(randomX),
				math.rad(randomY),
				math.rad(randomZ)
			)

			camera.CFrame = camera.CFrame * shakeCFrame
		end
	end
end)

-- Public function: Call this to shake the camera
function ShakeCamera(intensity, duration)
	isShaking = true
	shakeIntensity = intensity
	shakeDuration = duration
	originalIntensity = intensity
	
	print("📷 Camera shake:", intensity, "for", duration, "seconds")
end

-- Make it globally accessible
_G.ShakeCamera = ShakeCamera

-- STEP 5: Trigger the shake
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.E then
		ShakeCamera(5, 0.5)
		print("🔥 CAMERA SHAKE TEST (Press E)")
	end
end)