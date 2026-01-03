local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Main setup function - called for each player
local function setupReviveVFX(character)
	print("Setting up speed VFX for", player.Name)

	-- Wait for Humanoid and HumanoidRootPart
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")

	local att0 = Instance.new("Attachment")
	att0.Name = "ReviveAttachment"
	att0.Parent = hrp
	att0.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	att0.Position = Vector3.new(0, 0, 0)

	-- Create orangeBulb
	local orangeBulb = Instance.new("ParticleEmitter")
	orangeBulb.Parent = att0
	orangeBulb.Color = ColorSequence.new(Color3.fromRGB(255, 130, 67))
	orangeBulb.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.299, 10),
		NumberSequenceKeypoint.new(1, 4)
	})
	orangeBulb.LightEmission = 1
	orangeBulb.Squash = NumberSequence.new(0)
	orangeBulb.Texture = "rbxassetid://107119990151551"
	orangeBulb.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.344, 1),
		NumberSequenceKeypoint.new(0.484, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	orangeBulb.EmissionDirection = Enum.NormalId.Left
	orangeBulb.Enabled = false
	orangeBulb.Lifetime = NumberRange.new(1)
	orangeBulb.Rate = 1
	orangeBulb.Speed = NumberRange.new(0)
	orangeBulb.SpreadAngle = Vector2.new(0, 0)
	orangeBulb.Acceleration = Vector3.new(1, 0, 0)

	-- Create greenBulb particle
	local greenBulb = Instance.new("ParticleEmitter")
	greenBulb.Parent = att0
	greenBulb.Color = ColorSequence.new(Color3.fromRGB(0, 166, 86))
	greenBulb.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.299, 10),
		NumberSequenceKeypoint.new(1, 4)
	})
	greenBulb.LightEmission = 1
	greenBulb.Squash = NumberSequence.new(0)
	greenBulb.Texture = "rbxassetid://107119990151551"
	greenBulb.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.344, 1),
		NumberSequenceKeypoint.new(0.484, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	greenBulb.EmissionDirection = Enum.NormalId.Left
	greenBulb.Enabled = false
	greenBulb.Lifetime = NumberRange.new(0.5)
	greenBulb.Rate = 2
	greenBulb.Speed = NumberRange.new(0)
	greenBulb.SpreadAngle = Vector2.new(0, 0)
	greenBulb.Acceleration = Vector3.new(1, 0, 0)
	
	-- Create cyanCircle particle
	local cyanCircle = Instance.new("ParticleEmitter")
	cyanCircle.Parent = att0
	cyanCircle.Color = ColorSequence.new(Color3.fromRGB(0, 179, 179))
	cyanCircle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.501, 3.88),
		NumberSequenceKeypoint.new(1, 0)
	})
	cyanCircle.LightEmission = 1
	cyanCircle.Squash = NumberSequence.new(0)
	cyanCircle.Texture = "rbxassetid://84638758580040"
	cyanCircle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.344, 1),
		NumberSequenceKeypoint.new(0.484, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	cyanCircle.EmissionDirection = Enum.NormalId.Left
	cyanCircle.Enabled = false
	cyanCircle.Lifetime = NumberRange.new(1)
	cyanCircle.Rate = 1
	cyanCircle.Speed = NumberRange.new(0)
	cyanCircle.SpreadAngle = Vector2.new(0, 0)
	cyanCircle.Acceleration = Vector3.new(1, 0, 0)

	-- store render connection
	--local renderConnection

	--renderConnection = RunService.RenderStepped:Connect(function()
	--	-- Safety check: make sure parts still exist
	--	if not hrp or not hrp.Parent or not humanoid or not humanoid.Parent then
	--		print("Character destroyed, disconnecting VFX")
	--		if renderConnection then
	--			renderConnection:Disconnect()
	--		end
	--		return
	--	end
		
	--	-- Get start time when player loaded
	--	local startTime = os.clock()
		
	--	-- When player is dead or if it took 5 seconds since loaded, enable off all particles
	--	if humanoid.Health <= 0 or os.clock() - startTime = 5 then
	--		-- Disable all effects
	--		orangeBulb.Enabled = false
	--		greenBulb.Enabled = false
	--		cyanCircle.Enabled = false
	--	end
		
	--	--	print("ENABLING PARTICLES")
	--	--	orangeBulb.Enabled = true
	--	--	greenBulb.Enabled = true
	--	--else
	--	--	orangeBulb.Enabled = false
	--	--	greenBulb.Enabled = false

	---- cleanup when character dies
	--humanoid.Died:Connect(function()
	--	print("Character died, cleaning up VFX")
	--	if renderConnection then
	--		renderConnection:Disconnect()
	--	end

	--	-- Disable all effects
	--	orangeBulb.Enabled = false
	--	greenBulb.Enabled = false
	--end)

	--print("Revive VFX setup complete")
end

-- Setup for current character (if it exists)
if player.Character then
	setupReviveVFX(player.Character)
end

-- Setup for all future characters (resapwns)
player.CharacterAdded:Connect(setupReviveVFX)

print("RevivePlayerVFX script loaded")