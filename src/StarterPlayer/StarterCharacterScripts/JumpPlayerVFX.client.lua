local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Main setup function - called for each player
local function setupJumpVFX(character)
	print("Setting up speed VFX for", player.Name)

	-- Wait for Humanoid and HumanoidRootPart
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")

	local att0 = Instance.new("Attachment")
	att0.Name = "JumpAttachment"
	att0.Parent = hrp
	att0.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	att0.Position = Vector3.new(0, 0, 1)

	-- Create dash yellowParticle
	local yellowParticle = Instance.new("ParticleEmitter")
	yellowParticle.Parent = att0
	yellowParticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	yellowParticle.Size = NumberSequence.new(1)
	yellowParticle.LightEmission = 1
	yellowParticle.Squash = NumberSequence.new(0)
	yellowParticle.Texture = "rbxassetid://111125230747373"
	yellowParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	yellowParticle.EmissionDirection = Enum.NormalId.Left
	yellowParticle.Enabled = false
	yellowParticle.Lifetime = NumberRange.new(1, 2)
	yellowParticle.Rate = 10
	yellowParticle.Speed = NumberRange.new(4, 6)
	yellowParticle.SpreadAngle = Vector2.new(0, 360)
	yellowParticle.Acceleration = Vector3.new(-5, -5, 0)

	-- Create smoke particle
	local smoke = Instance.new("ParticleEmitter")
	smoke.Parent = att0
	smoke.Color = ColorSequence.new(Color3.fromRGB(76, 76, 76))
	smoke.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 5)
	})
	smoke.Texture = "rbxassetid://126204840295633"
	smoke.LightEmission = 0.55
	smoke.Squash = NumberSequence.new(0)
	smoke.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	smoke.EmissionDirection = Enum.NormalId.Left
	smoke.Enabled = false
	smoke.Lifetime = NumberRange.new(1, 2)
	smoke.Rate = 4
	smoke.Speed = NumberRange.new(1, 3)
	smoke.SpreadAngle = Vector2.new(-360, 360)
	smoke.Acceleration = Vector3.new(0, 0, 0)

	-- store render connection
	local renderConnection

	renderConnection = RunService.RenderStepped:Connect(function()
		-- Safety check: make sure parts still exist
		if not hrp or not hrp.Parent or not humanoid or not humanoid.Parent then
			print("Character destroyed, disconnecting VFX")
			if renderConnection then
				renderConnection:Disconnect()
			end
			return
		end

		-- 1. Get current speed(HumanoidRootPart has velocity)
		local speed = hrp.AssemblyLinearVelocity.Magnitude

		-- 2. Check if in air(Humanoid.FloorMaterial)
		if humanoid.FloorMaterial ~= Enum.Material.Air then
			-- In air, disable effects
			yellowParticle.Enabled = false
			smoke.Enabled = false
			return
		end

		-- 3. If speed is >= 100, enable yellowParticle
		if speed >= 100 then
			print("ENABLING PARTICLES")
			yellowParticle.Enabled = true
			smoke.Enabled = true
		else
			yellowParticle.Enabled = false
			smoke.Enabled = false
		end
	end)

	-- cleanup when character dies
	humanoid.Died:Connect(function()
		print("Character died, cleaning up VFX")
		if renderConnection then
			renderConnection:Disconnect()
		end

		-- Disable all effects
		yellowParticle.Enabled = false
		smoke.Enabled = false
	end)

	print("Jump VFX setup complete")
end

-- Setup for current character (if it exists)
if player.Character then
	setupJumpVFX(player.Character)
end

-- Setup for all future characters (resapwns)
player.CharacterAdded:Connect(setupJumpVFX)

print("JumpPlayerVFX script loaded")