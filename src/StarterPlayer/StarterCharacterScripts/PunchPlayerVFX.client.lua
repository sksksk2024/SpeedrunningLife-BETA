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
	att0.Name = "PunchPlayerAttachment"
	att0.Parent = hrp
	att0.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	att0.Position = Vector3.new(0, 0, 0)

	-- Create starParticle
	local starParticle = Instance.new("ParticleEmitter")
	starParticle.Parent = att0
	starParticle.Color = ColorSequence.new(Color3.fromRGB(255, 247, 0))
	starParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 10),
	})
	starParticle.LightEmission = 1
	starParticle.Squash = NumberSequence.new(0)
	starParticle.Texture = "rbxassetid://76063116092211"
	starParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	starParticle.EmissionDirection = Enum.NormalId.Left
	starParticle.Enabled = false
	starParticle.Lifetime = NumberRange.new(0.1)
	starParticle.Rate = 1
	starParticle.Speed = NumberRange.new(1)
	starParticle.SpreadAngle = Vector2.new(0, 30)
	starParticle.Acceleration = Vector3.new(0, 0, 0)

	-- Create punchParticle particle
	local punchParticle = Instance.new("ParticleEmitter")
	punchParticle.Parent = att0
	punchParticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	punchParticle.Size = NumberSequence.new(4)
	punchParticle.LightEmission = 1
	punchParticle.Squash = NumberSequence.new(0)
	punchParticle.Texture = "rbxassetid://137964472332681"
	punchParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	punchParticle.EmissionDirection = Enum.NormalId.Left
	punchParticle.Enabled = false
	punchParticle.Lifetime = NumberRange.new(0.1)
	punchParticle.Rate = 1
	punchParticle.Speed = NumberRange.new(50)
	punchParticle.SpreadAngle = Vector2.new(0, 30)
	punchParticle.Acceleration = Vector3.new(1, 0, 0)
end
	-- store render connection
	--local renderConnection

--	renderConnection = RunService.RenderStepped:Connect(function()
--		-- Safety check: make sure parts still exist
--		if not hrp or not hrp.Parent or not humanoid or not humanoid.Parent then
--			print("Character destroyed, disconnecting VFX")
--			if renderConnection then
--				renderConnection:Disconnect()
--			end
--			return
--		end
		
--		-- Get starParticlet time when player loaded
--		--local starParticletTime = os.clock()
		
--		-- When player is dead or if it took 5 seconds since loaded, enable off all particles
--		--if humanoid.Health <= 0 or os.clock() - starParticletTime = 5 then
--		--	-- Disable all effects
--		--	starParticle.Enabled = false
--		--	punchParticle.Enabled = false
--		--end
		
--		--	print("ENABLING PARTICLES")
--		--	starParticle.Enabled = true
--		--	punchParticle.Enabled = true
--		--else
--		--	starParticle.Enabled = false
--		--	punchParticle.Enabled = false

--	-- cleanup when character dies
--	humanoid.Died:Connect(function()
--		print("Character died, cleaning up VFX")
--		if renderConnection then
--			renderConnection:Disconnect()
--		end

--		-- Disable all effects
--		starParticle.Enabled = false
--		punchParticle.Enabled = false
--	end)

--	print("Revive VFX setup complete")
--	end

---- Setup for current character (if it exists)
--if player.Character then
--	setupReviveVFX(player.Character)
--end

---- Setup for all future characters (resapwns)
--player.CharacterAdded:Connect(setupReviveVFX)

--print("RevivePlayerVFX script loaded")