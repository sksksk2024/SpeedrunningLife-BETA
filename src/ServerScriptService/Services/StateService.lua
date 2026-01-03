local StateService = {}
local states = {} -- [player] = "Idle" | "InCombat" | "InCutscene"

function StateService:SetState(player, newState)
	states[player] = newState
	print(player.Name, "->", newState) -- Debug
	
	-- Lock/unlock player based on state
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	
	local lastSpeed = 16
	local lastJump = 50
	
	-- Check if humanoid's walk speed is not 0, and save it
	if humanoid.WalkSpeed ~= 0 then
		lastSpeed = humanoid.WalkSpeed
	end
	if humanoid.JumpPower ~= 0 then
		lastJump = humanoid.JumpPower
	end
	
	-- Set humanoid walk speed to 0 if in combat or cutscene
	if character then
		if humanoid then
			if newState == "InCombat" or newState == "InCutscene" then
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
				humanoid.JumpHeight = 0
			elseif newState == "Idle" then
				humanoid.WalkSpeed = lastSpeed
				humanoid.JumpPower = lastJump
				humanoid.JumpHeight = 7.2
			end
		end
	end
end

function StateService:GetState(player)
	return states[player] or "Idle"
end

function StateService:Clear(player)
	states[player] = nil
end

return StateService