local WorkoutService = {}

local ServerScriptService = game:GetService("ServerScriptService")

local RS = game:GetService("ReplicatedStorage")
local PlayerStatsService = require(ServerScriptService.Services.PlayerStatsService)
local StateService = require(ServerScriptService.Services.StateService)
local Constants = require(RS.Modules.Constants)

function WorkoutService:DoWorkout(player, workoutName)
	-- 1. Check state
	if StateService:GetState(player) ~= Constants.States.Idle then
		return nil
	end	

	-- 2. Lock state
	StateService:SetState(player, Constants.States.Workout)

	-- 3. Get stats (must exist)
	local stats = PlayerStatsService:Get(player)
	if not stats then
		warn("Stats missing for", player.Name)
		return nil
	end

	-- 4. Apply gains
	stats:AddStrength(10)
	stats:AddMoney(10)

	-- 5. Unlock state
	StateService:SetState(player, Constants.States.Idle)

	-- 6. Return NEW TOTALS ONLY
	return {
		Strength = stats.Strength,
		Money = stats.Money,
	}
end

return WorkoutService