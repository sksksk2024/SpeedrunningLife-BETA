local Players = game:GetService("Players")

local PlayerSetupService = {}

function PlayerSetupService:Init()
	-- Currently empty - you'll add character setup here later
	-- Like setting max health based on level
	Players.PlayerAdded:Connect(function(player)
		-- Future: Set health, animations, etc
	end)
end

return PlayerSetupService