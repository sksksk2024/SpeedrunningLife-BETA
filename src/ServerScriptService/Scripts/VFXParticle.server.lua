---- 📚 STEP-BY-STEP: Creating your first particle effect

--local function createExplosionEffect()
--	-- STEP 1: Create the container (usually invisible)
--	local effectPart = Instance.new("Part")
--	effectPart.Name = "ExplosionEffect"
--	effectPart.Size = Vector3.new(1, 1, 1)
--	effectPart.Transparency = 1
--	effectPart.Anchored = true
--	effectPart.CanCollide = false
--	effectPart.Parent = workspace
	
--	-- STEP 2: Create attachment (spawn point)
--	local attachement = Instance.new("Attachment")
--	attachement.Name = "ParticleOrigin"
--	attachement.Parent = effectPart
	
--	-- STEP 3: Create the particle emitter
--	local particleEmitter = Instance.new("ParticleEmitter")
--	particleEmitter.Parent = attachement
	
--	-- TEXTURE
--	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
--	-- 💭 Common textures:
--	-- smoke_main.dds = smoke puffs
--	-- sparkles_main.dds = sparkles
--	-- explosion_trail.dds = trail marks
--	-- Find more in: View → Asset Manager → Textures
	
--	particleEmitter.Color = ColorSequence.new({
--		ColorSequenceKeypoint.new(0, Color3.new(1, 0.5, 0)),
--		ColorSequenceKeypoint.new(0.5, Color3.new(1, 0, 0)),
--		ColorSequenceKeypoint.new(1, Color3.new(0.2, 0.2, 0.2))
--	})
	
--	-- TRANSPARENCY
--	particleEmitter.Transparency = NumberSequence.new({
--		NumberSequenceKeypoint.new(0, 1),
--		NumberSequenceKeypoint.new(0.1, 0),
--		NumberSequenceKeypoint.new(0.8, 0),
--		NumberSequenceKeypoint.new(1, 1)
--	})
	
--	-- SIZE
--	particleEmitter.Size = NumberSequence.new({
--		NumberSequenceKeypoint.new(0, 0),
--		NumberSequenceKeypoint(0.5, 3),
--		NumberSequenceKeypoint.new(1, 5)
--	})
	
--	-- LIFETIME
--	particleEmitter.Lifetime = NumberRange.new(1, 2)
	
--	-- RATE
--	particleEmitter.Rate = 50
	
--	-- SPEED
--	particleEmitter.Speed = NumberRange.new(5, 15)
	
--	-- SPREAD ANGLE
--	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	
--	-- ROTATION
--	particleEmitter.Rotation = NumberRange.new(-180, 180)
--	particleEmitter.RotSpeed = NumberRange.new(-90, 90)
	
--	-- ACCELERATION
--	particleEmitter.Acceleration = Vector3.new(0, 5, 0)
	
--	-- LIGHT EMISSION
--	particleEmitter.LightEmission = 1
	
--	-- Z OFFSET
--	particleEmitter.ZOffset = 0.5
	
--	return effectPart
--end

---- 🔥 EMISSION MODES: Enabled vs Emit
--local function demonstrateEmissionModes()
--	local part = createExplosionEffect()
--	part.Position = Vector3.new(0, 10, 0)
--	local particleEmitter = part:FindFirstChildWhichIsA("Attachment"):FindFirstChild("ParticleEmitter")
	
--	-- Method 1: Continuous
--	particleEmitter.Enabled = true
--	task.wait(2)
	
--	-- Method 2: Burst
--	task.wait(1)
--	particleEmitter:Emit(100) -- Spawn 100 particles instantly
--end

---- 🎓 ADVANCED: Multiple particles for ONE effect
--local function createRealisticExplosion()
--	local part = Instance.new("Part")
--	part.Transparency = 1
--	part.Anchored = true
--	part.CanCollide = false
--	part.Parent = workspace
	
--	local attachement = Instance.new("Attachment")
--	attachement.Parent = part
	
--	-- LAYER 1: Fast expanding shockwave
--	local shockwave = Instance.new("ParticleEmitter")
--	shockwave.Parent = attachement
--	shockwave.Texture = "rbxasset://textures/particles/smoke_main.dds"
--	shockwave.Size = NumberSequence.new({
--		NumberSequenceKeypoint.new(0, 0),
--		NumberSequenceKeypoint.new(1, 10)
--	})
--	shockwave.Transparency = NumberSequence.new({
--		NumberSequenceKeypoint.new(0, 0),
--		NumberSequenceKeypoint.new(1, 1)
--	})
--	shockwave.Lifetime = NumberRange.new(0.3)
--	shockwave.Speed = NumberRange.new(0)
--	shockwave.Rate = 0 -- :Emit() incoming
--	shockwave.Color = ColorSequence.new(Color3.new(1, 1, 1))
	
--	-- LAYER 2: Fire burst
--	local fire = Instance.new("ParticleEmitter")
--	fire.Parent = attachement
--	fire.Texture = "rbxasset://textures/particles/explosion_trail.dds"
--	fire.Size = NumberSequence.new(3)
--	fire.Transparency = NumberSequence.new({
--		NumberSequenceKeypoint.new(0, 0.5),
--		NumberSequenceKeypoint.new(1, 1)
--	})
--	fire.Lifetime = NumberRange.new(0.5, 0.8)
--	fire.Speed = NumberRange.new(10, 20)
--	fire.SpreadAngle = Vector2.new(180, 180)
--	fire.Rate = 0
--	fire.LightEmission = 1
--	fire.Color = ColorSequence.new({
--		ColorSequenceKeypoint.new(0, Color3.new(1, 0.8, 0)),
--		ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
--	})
	
--	-- LAYER 3: Smoke aftermath
--	local smoke = Instance.new("ParticleEmitter")
--	smoke.Parent = attachement
--	smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
--	smoke.Size = NumberSequenceKeypoint.new({
--		NumberSequenceKeypoint.new(0, 2),
--		NumberSequenceKeypoint.new(1, 6)
--	})
--	smoke.Transparency = NumberSequence.new({
--		NumberSequenceKeypoint.new(0, 0.5),
--		NumberSequenceKeypoint.new(1, 1)
--	})
--	smoke.Lifetime = NumberRange.new(2, 3)
--	smoke.Speed = NumberRange.new(2, 5)
--	smoke.SpreadAngle = Vector2.new(45, 45)
--	smoke.Rate = 0
--	smoke.Acceleration = Vector3.new(0, 5, 0)
--	smoke.Color = ColorSequence.new({
--		ColorSequenceKeypoint.new(0, Color3.new(0.3, 0.3, 0.3)),
--		ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
--	})
	
--	-- TRIGGER THEM ALL
--	shockwave:Emit(5)
--	fire:Emit(50)
--	smoke:Emit(30)
	
--	-- Clean up
--	task.delay(5, function()
--		part:Destroy()
--	end)
	
--	return part
--end
