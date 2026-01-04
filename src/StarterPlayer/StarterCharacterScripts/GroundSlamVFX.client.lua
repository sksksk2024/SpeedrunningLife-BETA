-- Ground Slam Effect
local RS = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remotes
local Remotes = RS.Remotes
local TriggerTeleportVFX = Remotes:WaitForChild("TriggerTeleportVFX")

-- 🔧 PART 1: Impact Shockwave
local function createShockwave(position)
	-- Create flat disk
	local shockwave = Instance.new("Part")
	shockwave.Name = "Shockwave"
	shockwave.Shape = Enum.PartType.Cylinder
	shockwave.Size = Vector3.new(0.2, 1, 1)
	shockwave.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	shockwave.Anchored = true
	shockwave.CanCollide = false
	shockwave.Material = Enum.Material.Neon
	shockwave.Color = Color3.fromRGB(255, 255, 200)
	shockwave.Transparency = 0.5
	shockwave.Parent = workspace

	-- Add particle ring
	local attachement = Instance.new("Attachment")
	attachement.Parent = shockwave

	local ringParticles = Instance.new("ParticleEmitter")
	ringParticles.Parent = attachement
	ringParticles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	ringParticles.Color = ColorSequence.new(Color3.fromRGB(200, 200, 150))
	ringParticles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 3)
	})
	ringParticles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	ringParticles.Lifetime = NumberRange.new(4)
	ringParticles.Rate = 100
	ringParticles.Speed = NumberRange.new(0)
	ringParticles.SpreadAngle = Vector2.new(0, 0)
	ringParticles.Enabled = true

	-- Animate: Expand and fade
	local expandTween = ts:Create(
		shockwave,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = Vector3.new(0.2, 15, 15), -- expand to 15 studs
			Transparency = 1
		}
	)
	expandTween:Play()

	-- Clean up
	task.delay(0.35, function()
		ringParticles.Enabled = false
	end)
	Debris:AddItem(shockwave, 1)
end

-- 🔧 PART 2: Dust Burst
local function createDustBurst(position)
	local dustPart = Instance.new("Part")
	dustPart.Name = "DustEffect"
	dustPart.Size = Vector3.new(1, 1, 1)
	dustPart.CFrame = CFrame.new(position)
	dustPart.Transparency = 1
	dustPart.Anchored = true
	dustPart.CanCollide = false
	dustPart.Parent = workspace

	local attachement = Instance.new("Attachment")
	attachement.Parent = dustPart

	-- LAYER 1: Ground dust (outward)
	local groundDust = Instance.new("ParticleEmitter")
	groundDust.Parent = attachement
	groundDust.Texture = "rbxasset://textures/particles/smoke_main.dds"
	groundDust.Color = ColorSequence.new(Color3.fromRGB(150, 130, 100))
	groundDust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(0.5, 4),
		NumberSequenceKeypoint.new(1, 6)
	})
	groundDust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.7, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	groundDust.Lifetime = NumberRange.new(1.5, 2.5)
	groundDust.Rate = 0
	groundDust.Speed = NumberRange.new(15, 25)
	groundDust.SpreadAngle = Vector2.new(80, 10)
	groundDust.Acceleration = Vector3.new(0, 3, 0)
	groundDust.Drag = 5

	-- Layer 2: Impact debris (small rocks/chunks)
	local debris = Instance.new("ParticleEmitter")
	debris.Parent = attachement
	debris.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	debris.Color = ColorSequence.new(Color3.fromRGB(100, 80, 60))
	debris.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	debris.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	debris.Lifetime = NumberRange.new(1, 1.5)
	debris.Rate = 0
	debris.Speed = NumberRange.new(20, 35)
	debris.SpreadAngle = Vector2.new(180, 60)
	debris.Acceleration = Vector3.new(0, -20, 0)
	debris.Rotation = NumberRange.new(-180, 180)
	debris.RotSpeed = NumberRange.new(-200, 200)

	-- Emit!
	groundDust:Emit(60)
	debris:Emit(40)

	Debris:AddItem(dustPart, 3)
end

-- 🔧 PART 3: Screen Flash
local function createFlashEffect()
	local Lighting = game:GetService("Lighting")

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Brightness = 0.3
	colorCorrection.Contrast = 0.5
	colorCorrection.Saturation = -0.5
	colorCorrection.Parent = Lighting

	-- Quick flash
	task.delay(0.05, function()
		local tween = ts:Create(
			colorCorrection,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Contrast = 0, 
				Saturation = 0
			}
		)
		tween:Play()
		tween.Completed:Wait()
		colorCorrection:Destroy()
	end)
end

-- 🔧 PART 4: Simple Rock Crater
local function createRockCrater(centerPosition, numRocks, radius)
	local angleStep = 360 / numRocks
	local currentAngle = 0

	for i = 1, numRocks do
		local rock = Instance.new("Part")
		rock.Name = "DebrisRock"
		rock.Size = Vector3.new(
			math.random(2, 4),
			math.random(2, 3),
			math.random(2, 3)
		)
		rock.Material = Enum.Material.Rock
		rock.Color = Color3.fromRGB(80, 70, 60)
		rock.Anchored = true
		rock.CanCollide = true
		
		rock.CollisionGroup = "RockDebris"
		
		rock.Parent = workspace

		-- Position in circle
		local rockCFrame = CFrame.new(centerPosition) *
			CFrame.Angles(0, math.rad(currentAngle), 0) *
			CFrame.new(0, 0, -radius)

		-- Start below ground
		rock.CFrame = rockCFrame * CFrame.new(0, -5, 0)
		rock.CFrame = CFrame.lookAt(rock.Position, centerPosition)

		-- Animate up
		local tweenUp = ts:Create(
			rock,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{CFrame = rockCFrame * CFrame.new(0, 2, 0)}
		)
		tweenUp:Play()

		-- Sink back down after delay
		task.delay(1.5, function()
			local tweenDown = ts:Create(
				rock,
				TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					CFrame = rockCFrame * CFrame.new(0, -5, 0),
					Size = Vector3.new(0.5, 0.5, 0.5)
				}
			)
			tweenDown:Play()
		end)

		Debris:AddItem(rock, 5)
		currentAngle = currentAngle + angleStep
	end
end

-- 🎬 FINAL: Orchestrate Everything!
local function playGroundSlamEffect(position)
	-- Instant effects
	createFlashEffect()
	createShockwave(position)
	
	-- ADD CAMERA SHAKE!
	if _G.ShakeCamera then
		_G.ShakeCamera(4, 0.6)
	end

	-- 50ns delay: Dust
	task.delay(0.05, function()
		createDustBurst(position)
	end)

	-- 100ms delay: Rocks
	task.delay(0.1, function()
		createRockCrater(position, 8, 6)
		createRockCrater(position, 12, 10)
	end)

	print("GROUND SLAM at", position)
end

-- TEST
--local testPart = workspace:FindFirstChild("Main")
--	or Instance.new("Part", workspace)
--testPart.Name = "Main"
--testPart.Size = Vector3.new(4, 1, 4)
--testPart.Position = Vector3.new(0, 10, 0)
--testPart.Anchored = true

--UIS.InputBegan:Connect(function(input, processed)
--	if processed then return end

--	if input.KeyCode == Enum.KeyCode.Q then
--		playGroundSlamEffect(testPart.Position)
--	end
--end)

-- Listen to remote events
TriggerTeleportVFX.OnClientEvent:Connect(function()
	-- Take the player's hrp position
	local character = player and player.Character
	local hrp = character and character:WaitForChild("HumanoidRootPart")
	
	playGroundSlamEffect(hrp.Position - Vector3.new(0, 5, 0))
end)