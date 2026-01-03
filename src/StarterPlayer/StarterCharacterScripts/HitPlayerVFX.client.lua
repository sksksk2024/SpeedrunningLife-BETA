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

	-- Create smokeParticle
	local smokeParticle = Instance.new("ParticleEmitter")
	smokeParticle.Parent = att0
	smokeParticle.Color = ColorSequence.new(Color3.fromRGB(85, 85, 0))
	smokeParticle.Size = NumberSequence.new(5)
	smokeParticle.LightEmission = 1
	smokeParticle.Squash = NumberSequence.new(0)
	smokeParticle.Texture = "rbxassetid://80913858265383"
	smokeParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	smokeParticle.EmissionDirection = Enum.NormalId.Left
	smokeParticle.Enabled = false
	smokeParticle.Lifetime = NumberRange.new(0.1)
	smokeParticle.Rate = 1
	smokeParticle.Speed = NumberRange.new(25)
	smokeParticle.SpreadAngle = Vector2.new(0, 15)
	smokeParticle.Acceleration = Vector3.new(1, 0, 0)

	-- Create hitParticle particle
	local hitParticle = Instance.new("ParticleEmitter")
	hitParticle.Parent = att0
	hitParticle.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	hitParticle.Size = NumberSequence.new(4)
	hitParticle.LightEmission = 1
	hitParticle.Squash = NumberSequence.new(0)
	hitParticle.Texture = "rbxassetid://123351232106798"
	hitParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	hitParticle.EmissionDirection = Enum.NormalId.Left
	hitParticle.Enabled = false
	hitParticle.Lifetime = NumberRange.new(0.1)
	hitParticle.Rate = 1
	hitParticle.Speed = NumberRange.new(50)
	hitParticle.SpreadAngle = Vector2.new(0, 360)
	hitParticle.Acceleration = Vector3.new(1, 0, 0)

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
	--		smokeParticle.Enabled = false
	--		hitParticle.Enabled = false
	--		punchParticle.Enabled = false
	--	end

	--	--	print("ENABLING PARTICLES")
	--	--	smokeParticle.Enabled = true
	--	--	hitParticle.Enabled = true
	--	--else
	--	--	smokeParticle.Enabled = false
	--	--	hitParticle.Enabled = false

	---- cleanup when character dies
	--humanoid.Died:Connect(function()
	--	print("Character died, cleaning up VFX")
	--	if renderConnection then
	--		renderConnection:Disconnect()
	--	end

	--	-- Disable all effects
	--	smokeParticle.Enabled = false
	--	hitParticle.Enabled = false
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