local ts = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Remotes = RS.Remotes

local LevelUp = Remotes:WaitForChild("LevelUp")

local function createLevelUpBurst(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Smooth tween using NumberValue trick
	local scaleValue = Instance.new("NumberValue")
	scaleValue.Value = 1
	
	scaleValue.Changed:Connect(function()
		character:ScaleTo(scaleValue.Value)
	end)
	
	-- UP
	local upTween = ts:Create(scaleValue, TweenInfo.new(0.5), {Value = 1.3})
	upTween:Play()
	upTween.Completed:Wait()
	
	-- DOWN
	local downTween = ts:Create(scaleValue, TweenInfo.new(0.15), {Value = 0.85})
	downTween:Play()
	downTween.Completed:Wait()
	
	-- NORMAL
	local normalTween = ts:Create(scaleValue, TweenInfo.new(0.2), {Value = 1})
	normalTween:Play()
	normalTween.Completed:Wait()
	
	scaleValue:Destroy()
	--]]

	-- Create attachment
	local att = Instance.new("Attachment")
	att.Parent = hrp

	-- Create burst particle
	local burst = Instance.new("ParticleEmitter")
	burst.Parent = att
	burst.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	burst.Size = NumberSequence.new(2)
	burst.Texture = "rbxassetid://111125230747373"  -- Sparkle
	burst.LightEmission = 1
	burst.Rate = 0
	burst.Lifetime = NumberRange.new(0.5, 1)
	burst.Speed = NumberRange.new(10, 20)
	burst.SpreadAngle = Vector2.new(180, 180)

	-- Emit burst
	burst:Emit(50)

	-- Create ring that expands outward
	local ring = Instance.new("ParticleEmitter")
	ring.Parent = att
	ring.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	ring.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 3),
		NumberSequenceKeypoint.new(1, 0)
	})
	ring.Texture = "rbxassetid://100264719749986"  -- Smoke
	ring.LightEmission = 0.8
	ring.Rate = 0
	ring.Lifetime = NumberRange.new(0.3)
	ring.Speed = NumberRange.new(20)
	ring.SpreadAngle = Vector2.new(0, 0)
	ring.EmissionDirection = Enum.NormalId.Top

	ring:Emit(20)

	-- Cleanup
	task.delay(2, function()
		att:Destroy()
	end)
end

LevelUp.OnClientEvent:Connect(function(newLevel)
	print("🎉 LEVEL UP! Level:", newLevel)

	local character = player.Character
	if character then
		createLevelUpBurst(character)
	end
end)