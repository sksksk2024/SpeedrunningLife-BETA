local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Remotes = RS.Remotes
local PlayerAttack = Remotes:WaitForChild("PlayerAttack")

-- Press E to attack during fight
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Space then
		print("Attacking!")
		PlayerAttack:FireServer()
	end
end)