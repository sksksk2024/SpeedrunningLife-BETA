local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RS = game:GetService("ReplicatedStorage")
local Services = RS.Modules
local Constants = require(Services.Constants)
local SoundUtil = require(Services.SoundUtil)
local PassService = require(script.Parent.PassService)

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
	
	local player = Players:GetPlayerFromCharacter(character)
	if not player or not humanoid then return end
	
	local multiplier = PassService.HasSpeedPass[player.UserId] and 2 or 1
	local targetSpeed = Constants.WalkSpeedPad * multiplier
	
	if humanoid and humanoid.WalkSpeed ~= targetSpeed then
		humanoid.WalkSpeed = targetSpeed
		-- Play Speed Boost Sound
		SoundUtil.playSound(speedBoost, hrp)
	end
end

local function onSlowPlatformTouched(hit)
	local character = hit.Parent
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	if not hrp then return end
	local player = Players:GetPlayerFromCharacter(character)
	if not player or not humanoid then return end
	
	-- Reset to 16 or 32
	local multiplier = PassService.HasSpeedPass[player.UserId] and 2 or 1
	humanoid.WalkSpeed = Constants.WalkSpeedDefault * multiplier
	-- Play Slow Boost Sound
	SoundUtil.playSound(slowBoost, hrp)
end

function WorldService:Init()
	speedPlatform.Touched:Connect(onSpeedPlatformTouched)
	slowPlatform.Touched:Connect(onSlowPlatformTouched)
end

return WorldService