local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RS = game:GetService("ReplicatedStorage")
local Services = RS.Modules
local Constants = require(Services.Constants)
local SoundUtil = require(Services.SoundUtil)

-- Sounds
local speedBoost = Constants.Sounds.speedBoost
local slowBoost = Constants.Sounds.slowBoost

local WorldService = {}

local speedPlatform = Workspace.SlowSpeedPlatforms:WaitForChild("SpeedPlatform")
local slowPlatform = workspace.SlowSpeedPlatforms:WaitForChild("SlowPlatform")

local function onSpeedPlatformTouched(hit)
	local character = hit.Parent
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	if not hrp then return end
	
	if humanoid and humanoid.WalkSpeed ~= Constants.WalkSpeedPad then
		humanoid.WalkSpeed = Constants.WalkSpeedPad
		
		-- Play Speed Boost Sound
		SoundUtil.playSound(speedBoost, hrp)
		
		print(character.Name, "got speed boost!")
	end
end

local function onSlowPlatformTouched(hit)
	local character = hit.Parent
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	if not hrp then return end
	
	if humanoid and humanoid.WalkSpeed == Constants.WalkSpeedPad then
		humanoid.WalkSpeed = Constants.WalkSpeedDefault
		
		-- Play Slow Boost Sound
		SoundUtil.playSound(slowBoost, hrp)
		
		print(character.Name, "got normal speed")
	end
end

function WorldService:Init()
	speedPlatform.Touched:Connect(onSpeedPlatformTouched)
	slowPlatform.Touched:Connect(onSlowPlatformTouched)
end

return WorldService