local ts = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes
local RemoveWallEvent = Remotes:WaitForChild("RemoveWall")

RemoveWallEvent.OnClientEvent:Connect(function(wallName)
	local wallsFolder = workspace:FindFirstChild("Walls")
	if wallsFolder then
		local wall = wallsFolder:FindFirstChild(wallName)
		if wall then
			-- Efect vizual (opțional): îl facem transparent înainte să dispară
			wall.CanCollide = false
			local tweenInfo = TweenInfo.new(1)
			ts:Create(wall, tweenInfo, {Transparency = 1}):Play()
			task.delay(1, function()
				wall:Destroy()
			end)
		end
	end
end)