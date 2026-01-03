local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for Remotes folder
local Remotes = RS:WaitForChild("Remotes")
local TriggerReviveVFX = Remotes:WaitForChild("TriggerReviveVFX")
local TriggerPunchPlayerVFX = Remotes:WaitForChild("TriggerPunchPlayerVFX")
local TriggerPunchBullyVFX = Remotes:WaitForChild("TriggerPunchBullyVFX")
local TriggerKickPlayerVFX = Remotes:WaitForChild("TriggerKickPlayerVFX")
local TriggerHitObjectVFX = Remotes:WaitForChild("TriggerHitObjectVFX")

-- Store particle emitters
local particles = {}

-- Main setup function
local function setupAllVFX(character)
	print("Setting up all VFX for", player.Name)
	
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	
	-- Create main attachment
	local att0 = Instance.new("Attachment")
	att0.Name = "VFXAttachment"
	att0.Parent = hrp
	att0.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	
	-- ========== REVIVE VFX ==========
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
	
	-- ========== PUNCH PLAYER VFX ==========
	-- Create starParticle
	local playerPunchStarParticle = Instance.new("ParticleEmitter")
	playerPunchStarParticle.Parent = att0
	playerPunchStarParticle.Color = ColorSequence.new(Color3.fromRGB(255, 247, 0))
	playerPunchStarParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 10),
	})
	playerPunchStarParticle.LightEmission = 1
	playerPunchStarParticle.Squash = NumberSequence.new(0)
	playerPunchStarParticle.Texture = "rbxassetid://76063116092211"
	playerPunchStarParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	playerPunchStarParticle.EmissionDirection = Enum.NormalId.Left
	playerPunchStarParticle.Enabled = false
	playerPunchStarParticle.Lifetime = NumberRange.new(0.1)
	playerPunchStarParticle.Rate = 1
	playerPunchStarParticle.Speed = NumberRange.new(1)
	playerPunchStarParticle.SpreadAngle = Vector2.new(0, 30)
	playerPunchStarParticle.Acceleration = Vector3.new(0, 0, 0)

	-- Create punchParticle particle
	local playerPunchPunchParticle = Instance.new("ParticleEmitter")
	playerPunchPunchParticle.Parent = att0
	playerPunchPunchParticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	playerPunchPunchParticle.Size = NumberSequence.new(4)
	playerPunchPunchParticle.LightEmission = 1
	playerPunchPunchParticle.Squash = NumberSequence.new(0)
	playerPunchPunchParticle.Texture = "rbxassetid://137964472332681"
	playerPunchPunchParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	playerPunchPunchParticle.EmissionDirection = Enum.NormalId.Left
	playerPunchPunchParticle.Enabled = false
	playerPunchPunchParticle.Lifetime = NumberRange.new(0.1)
	playerPunchPunchParticle.Rate = 1
	playerPunchPunchParticle.Speed = NumberRange.new(50)
	playerPunchPunchParticle.SpreadAngle = Vector2.new(0, 30)
	playerPunchPunchParticle.Acceleration = Vector3.new(1, 0, 0)
	
	-- ========== KICK PLAYER VFX (similar to punch but different color) ==========
	-- Create starParticle
	local kickPlayerStarParticle = Instance.new("ParticleEmitter")
	kickPlayerStarParticle.Parent = att0
	kickPlayerStarParticle.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	kickPlayerStarParticle.Size = NumberSequence.new(4)
	kickPlayerStarParticle.LightEmission = 1
	kickPlayerStarParticle.Squash = NumberSequence.new(0)
	kickPlayerStarParticle.Texture = "rbxassetid://107037619960848"
	kickPlayerStarParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	kickPlayerStarParticle.EmissionDirection = Enum.NormalId.Left
	kickPlayerStarParticle.Enabled = false
	kickPlayerStarParticle.Lifetime = NumberRange.new(0.1)
	kickPlayerStarParticle.Rate = 10
	kickPlayerStarParticle.Speed = NumberRange.new(50)
	kickPlayerStarParticle.SpreadAngle = Vector2.new(0, 360)
	kickPlayerStarParticle.Acceleration = Vector3.new(1, 0, 0)

	-- Create electricity particle
	local kickPlayerElectricity = Instance.new("ParticleEmitter")
	kickPlayerElectricity.Parent = att0
	kickPlayerElectricity.Color = ColorSequence.new(Color3.fromRGB(255, 238, 55))
	kickPlayerElectricity.Size = NumberSequence.new(5)
	kickPlayerElectricity.LightEmission = 1
	kickPlayerElectricity.Squash = NumberSequence.new(0)
	kickPlayerElectricity.Texture = "rbxassetid://106236998240926"
	kickPlayerElectricity.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	kickPlayerElectricity.EmissionDirection = Enum.NormalId.Left
	kickPlayerElectricity.Enabled = false
	kickPlayerElectricity.Lifetime = NumberRange.new(0.1)
	kickPlayerElectricity.Rate = 1
	kickPlayerElectricity.Speed = NumberRange.new(25)
	kickPlayerElectricity.SpreadAngle = Vector2.new(0, 0)
	kickPlayerElectricity.Acceleration = Vector3.new(1, 0, 0)

	-- Create punchParticle particle
	local kickPlayerPunchParticle = Instance.new("ParticleEmitter")
	kickPlayerPunchParticle.Parent = att0
	kickPlayerPunchParticle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	kickPlayerPunchParticle.Size = NumberSequence.new(5)
	kickPlayerPunchParticle.LightEmission = 1
	kickPlayerPunchParticle.Squash = NumberSequence.new(0)
	kickPlayerPunchParticle.Texture = "rbxassetid://84638758580040"
	kickPlayerPunchParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	kickPlayerPunchParticle.EmissionDirection = Enum.NormalId.Left
	kickPlayerPunchParticle.Enabled = false
	kickPlayerPunchParticle.Lifetime = NumberRange.new(0.1)
	kickPlayerPunchParticle.Rate = 1
	kickPlayerPunchParticle.Speed = NumberRange.new(25)
	kickPlayerPunchParticle.SpreadAngle = Vector2.new(0, 15)
	kickPlayerPunchParticle.Acceleration = Vector3.new(1, 0, 0)
	
	-- ========== HIT OBJECT VFX ==========
	-- Create smokeParticle
	local hitObjectSmokeParticle = Instance.new("ParticleEmitter")
	hitObjectSmokeParticle.Parent = att0
	hitObjectSmokeParticle.Color = ColorSequence.new(Color3.fromRGB(85, 85, 0))
	hitObjectSmokeParticle.Size = NumberSequence.new(5)
	hitObjectSmokeParticle.LightEmission = 1
	hitObjectSmokeParticle.Squash = NumberSequence.new(0)
	hitObjectSmokeParticle.Texture = "rbxassetid://80913858265383"
	hitObjectSmokeParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	hitObjectSmokeParticle.EmissionDirection = Enum.NormalId.Left
	hitObjectSmokeParticle.Enabled = false
	hitObjectSmokeParticle.Lifetime = NumberRange.new(0.1)
	hitObjectSmokeParticle.Rate = 1
	hitObjectSmokeParticle.Speed = NumberRange.new(25)
	hitObjectSmokeParticle.SpreadAngle = Vector2.new(0, 15)
	hitObjectSmokeParticle.Acceleration = Vector3.new(1, 0, 0)

	-- Create hitParticle particle
	local hitObjectHitParticle = Instance.new("ParticleEmitter")
	hitObjectHitParticle.Parent = att0
	hitObjectHitParticle.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	hitObjectHitParticle.Size = NumberSequence.new(4)
	hitObjectHitParticle.LightEmission = 1
	hitObjectHitParticle.Squash = NumberSequence.new(0)
	hitObjectHitParticle.Texture = "rbxassetid://123351232106798"
	hitObjectHitParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	hitObjectHitParticle.EmissionDirection = Enum.NormalId.Left
	hitObjectHitParticle.Enabled = false
	hitObjectHitParticle.Lifetime = NumberRange.new(0.1)
	hitObjectHitParticle.Rate = 1
	hitObjectHitParticle.Speed = NumberRange.new(50)
	hitObjectHitParticle.SpreadAngle = Vector2.new(0, 360)
	hitObjectHitParticle.Acceleration = Vector3.new(1, 0, 0)
	
	-- Store all particles for easy access
	particles = {
		revive = {orangeBulb, greenBulb, cyanCircle},
		punchPlayer = {playerPunchStarParticle, playerPunchPunchParticle},
		kickPlayer = {kickPlayerStarParticle, kickPlayerElectricity, kickPlayerPunchParticle},
		hitObject = {hitObjectSmokeParticle, hitObjectHitParticle}
	}
	
	print("All VFX setup complete for", player.Name)
end

-- Remote event handlers
TriggerReviveVFX.OnClientEvent:Connect(function()
	if particles.revive then
		for _, emitter in particles.revive do
			emitter:Emit(3)
		end
	end
end)

TriggerPunchPlayerVFX.OnClientEvent:Connect(function()
	if particles.punchPlayer then
		for _, emitter in particles.punchPlayer do
			emitter:Emit(5)
		end
	end
end)

TriggerPunchBullyVFX.OnClientEvent:Connect(function(bullyCharacter)
	-- this creates particles on the BULLY, not the player
	if not bullyCharacter or not bullyCharacter:FindFirstChild("HumanoidRootPart") then
		return
	end
	
	local bullyHRP = bullyCharacter:WaitForChild("HumanoidRootPart")
	local att = Instance.new("Attachment")
	att.Parent = bullyHRP
	
	-- Create explosionParticle
	local explosionParticle = Instance.new("ParticleEmitter")
	explosionParticle.Parent = att
	explosionParticle.Color = ColorSequence.new(Color3.fromRGB(255, 247, 0))
	explosionParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 10),
	})
	explosionParticle.LightEmission = 1
	explosionParticle.Squash = NumberSequence.new(0)
	explosionParticle.Texture = "rbxassetid://79802270330984"
	explosionParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.351, 0.306),
		NumberSequenceKeypoint.new(1, 0)
	})
	explosionParticle.EmissionDirection = Enum.NormalId.Left
	--explosionParticle.Enabled = false
	explosionParticle.Lifetime = NumberRange.new(0.1)
	explosionParticle.Rate = 1
	explosionParticle.Speed = NumberRange.new(1)
	explosionParticle.SpreadAngle = Vector2.new(0, 30)
	explosionParticle.Acceleration = Vector3.new(0, 0, 0)

	-- Create punchParticle particle
	local punchParticle = Instance.new("ParticleEmitter")
	punchParticle.Parent = att
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
	punchParticle.EmissionDirection = Enum.NormalId.Bottom
	--punchParticle.Enabled = false
	punchParticle.Lifetime = NumberRange.new(1)
	punchParticle.Rate = 1
	punchParticle.Speed = NumberRange.new(10)
	punchParticle.SpreadAngle = Vector2.new(30, 30)
	punchParticle.Acceleration = Vector3.new(0, -10, 0)
	
	explosionParticle:Emit(10)
	
	game.Debris:AddItem(att, 1)
end)

TriggerKickPlayerVFX.OnClientEvent:Connect(function()
	if particles.kickPlayer then
		for _, emitter in particles.kickPlayer do
			emitter:Emit(8)
		end
	end
end)

TriggerHitObjectVFX.OnClientEvent:Connect(function()
	if particles.hitObject then
		for _, emitter in particles.hitObject do
			emitter:Emit(3)
		end
	end
end)

-- Setup for current character
if player.Character then
	setupAllVFX(player.Character)
end

-- Setup for all future character (respawns)
player.CharacterAdded:Connect(setupAllVFX)

print("PlayerVFXHandler loaded")