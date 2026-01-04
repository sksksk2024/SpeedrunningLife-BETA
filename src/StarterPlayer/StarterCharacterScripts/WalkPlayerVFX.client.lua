local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Take player's state if running fast (above 100 speed) or not
local isRunningFast = false

-- Dirt particle
-- helper function to create dirt particles
local function createDirtParticle(parent)
	local dirt = Instance.new("ParticleEmitter")
	dirt.Parent = parent
	dirt.Color = ColorSequence.new(Color3.fromRGB(86, 69, 34))
	dirt.LightEmission = 0.2
	dirt.LightInfluence = 1
	
	dirt.Size = NumberSequence.new(0.3)                           
	dirt.Squash = NumberSequence.new(0)
	dirt.Texture = "rbxassetid://104706397679822"
	--rbxassetid://104706397679822
	--rbxasset://textures/particles/smoke_main.dds
	dirt.Transparency = NumberSequence.new(0)
	dirt.EmissionDirection = Enum.NormalId.Bottom
	dirt.Enabled = false
	dirt.Lifetime = NumberRange.new(1, 2)
	dirt.Rate = 20
	dirt.Speed = NumberRange.new(1)
	dirt.SpreadAngle = Vector2.new(0, 45)
	dirt.Acceleration = Vector3.new(-1, 0, 0)
	
	return dirt
end

-- Main setup function - called for each character
local function setupSpeedVFX(character)
	print("Setting up speed VFX for", player.Name)
	
	-- Wait for Humanoid and HumanoidRootPart
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	local rightFoot = character:WaitForChild("RightFoot")
	local leftFoot = character:WaitForChild("LeftFoot")

	local att0 = Instance.new("Attachment")
	att0.Name = "DashAttachment"
	att0.Parent = hrp
	att0.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	att0.Position = Vector3.new(0, 0, 5)

 	-- Create dash trail
	local trail = Instance.new("ParticleEmitter")
	trail.Parent = att0
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 179, 179)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 166, 86)),
	})
	trail.Size = NumberSequence.new(10)
	trail.LightEmission = 0.55
	-- squash of 3 values keys that have time, value and envelope
	trail.Squash = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 3),
		NumberSequenceKeypoint.new(0.117, 3),
		NumberSequenceKeypoint.new(0.454, 0.525),
		NumberSequenceKeypoint.new(0.607, -2.14),
		NumberSequenceKeypoint.new(0.7, 0.375),
		NumberSequenceKeypoint.new(0.776, -0.975),
		NumberSequenceKeypoint.new(0.854, 2.44),
		NumberSequenceKeypoint.new(1, 0.225)
	})
	trail.Texture = "rbxassetid://100264719749986"
	--rbxassetid://100264719749986
	--rbxasset://textures/particles/smoke_main.dds
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	trail.EmissionDirection = Enum.NormalId.Left
	trail.Enabled = false
	trail.Lifetime = NumberRange.new(1, 2)
	trail.Rate = 50
	trail.Speed = NumberRange.new(0)
	trail.SpreadAngle = Vector2.new(0, 5)
	trail.Acceleration = Vector3.new(-10, 0, 0)

	-- Create electricity particle
	local electricity = Instance.new("ParticleEmitter")
	electricity.Parent = att0
	electricity.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 179, 179)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 166, 86)),
	})
	electricity.Size = NumberSequence.new(5)
	electricity.Texture = "rbxassetid://121221329129233"
	--rbxassetid://121221329129233
	--rbxasset://textures/particles/sparkles_main.dds
	electricity.LightEmission = 0.55
	electricity.Squash = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 3),
		NumberSequenceKeypoint.new(0.117, 3),
		NumberSequenceKeypoint.new(0.454, 0.525),
		NumberSequenceKeypoint.new(0.607, -2.14),
		NumberSequenceKeypoint.new(0.7, 0.375),
		NumberSequenceKeypoint.new(0.776, -0.975),
		NumberSequenceKeypoint.new(0.854, 2.44),
		NumberSequenceKeypoint.new(1, 0.225)
	})
	electricity.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	electricity.EmissionDirection = Enum.NormalId.Left
	electricity.Enabled = false
	electricity.Lifetime = NumberRange.new(1, 2)
	electricity.Rate = 10
	electricity.Speed = NumberRange.new(3, 7)
	electricity.SpreadAngle = Vector2.new(0, 5)
	electricity.Acceleration = Vector3.new(-10, 0, 0)

	-- Create attachments for feet
	local att1 = Instance.new("Attachment")
	att1.Parent = rightFoot
	att1.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	
	local att2 = Instance.new("Attachment")
	att2.Parent = leftFoot
	att2.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	
	-- Create dirt particles for both feet
	local dirtLeft = createDirtParticle(att1)
	local dirtRight = createDirtParticle(att2)

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
		if humanoid.FloorMaterial == Enum.Material.Air then
			-- In air, disable effects
			trail.Enabled = false
			electricity.Enabled = false
			dirtLeft.Enabled = false
			dirtRight.Enabled = false
			return
		end

		-- 3. If speed is >= 100, enable trail
		if speed >= 100 then
			print("ENABLING PARTICLES")
			trail.Enabled = true
			electricity.Enabled = true
			dirtLeft.Enabled = true
			dirtRight.Enabled = true
		else
			trail.Enabled = false
			electricity.Enabled = false
			dirtLeft.Enabled = false
			dirtRight.Enabled = false
		end
	end)
	
	-- cleanup when character dies
	humanoid.Died:Connect(function()
		print("Character died, cleaning up VFX")
		if renderConnection then
			renderConnection:Disconnect()
		end
		
		-- Disable all effects
		trail.Enabled = false
		electricity.Enabled = false
		dirtLeft.Enabled = false
		dirtRight.Enabled = false
	end)
	
	print("Speed VFX setup complete")
end

-- Setup for current character (if it exists)
if player.Character then
	setupSpeedVFX(player.Character)
end

-- Setup for all future characters (respawns)
player.CharacterAdded:Connect(setupSpeedVFX)

print("WalkPlayerVFX script loaded")
