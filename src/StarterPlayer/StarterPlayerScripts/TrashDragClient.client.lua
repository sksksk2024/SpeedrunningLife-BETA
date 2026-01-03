local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Constants)
local SoundUtil = require(RS.Modules.SoundUtil)

local Remotes = RS.Remotes
local claimTrashEvent = Remotes:FindFirstChild("ClaimTrashEvent")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local TrashDragClient = {}
TrashDragClient.DraggingTrash = nil -- Currently dragged trash
TrashDragClient.DragConnection = nil -- RenderStepped connection
TrashDragClient.OriginalCFrame = nil -- Starting position

local DRAG_DISTANCE = Constants.TrashDragDistance
local MAX_PICKUP_DISTANCE = Constants.TrashPickupDistance

-- Sounds
local trashCollectedSound = Constants.Sounds.trashCollectedSound
local trashConvertedSound = Constants.Sounds.trashConvertedSound
local trashDropSound = Constants.Sounds.trashDropSound

function TrashDragClient:Init()
	-- Detect when mouse button is pressed
	UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:TryStartDrag()
		end
	end)
	
	-- Detect when mouse button is released
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:StopDrag()
		end
	end)
	print("TrashDragClient initialized")
end

-- Initialize immediately
TrashDragClient:Init()

function TrashDragClient:TryStartDrag()
	local target = mouse.Target -- What the mouse is pointing at
	if not target then return end

	-- Check if target is trash
	local trash = self:FindTrashObject(target)
	if not trash then return end
	
	-- Check distance from player
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local trashPos = self:GetTrashPosition(trash)
	if not trashPos then return end
	
	local distance = (hrp.Position - trashPos).Magnitude
	if distance > MAX_PICKUP_DISTANCE then
		print("Trash too far away:", distance, "studs (max:", MAX_PICKUP_DISTANCE, ")")
		return
	end
	
	-- Start dragging
	self.DraggingTrash = trash
	self.OriginalCFrame = trash:IsA("BasePart") and trash.CFrame or trash:GetPivot()
	
	claimTrashEvent:FireServer(trash)
	
	-- Start drag loop
	self.DragConnection = RunService.RenderStepped:Connect(function()
		self:UpdateDrag()
	end)
	
	-- Play Collection Sound
	SoundUtil.playSound(trashCollectedSound, hrp)
	
	
	print("Started dragging", trash.Name)
end

function TrashDragClient:UpdateDrag()
	if not self.DraggingTrash then return end
	
	-- Calculate position in front of camera
	local camCFrame = camera.CFrame
	local targetPos = camCFrame.Position + camCFrame.LookVector * DRAG_DISTANCE
	
	-- Move the trash smoothly
	if self.DraggingTrash:IsA("BasePart") then
		local currentPos = self.DraggingTrash.Position
		local newPos = currentPos:Lerp(targetPos, 0.3) -- Smooth interpolation
		self.DraggingTrash.CFrame = CFrame.new(newPos)
	elseif self.DraggingTrash:IsA("Model") and self.DraggingTrash.PrimaryPart then
		local currentPos = self.DraggingTrash.PrimaryPart.Position
		local newPos = currentPos:Lerp(targetPos, 0.3)
		self.DraggingTrash:SetPrimaryPartCFrame(CFrame.new(newPos))
	end
end

function TrashDragClient:StopDrag()
	if not self.DraggingTrash then return end
	
	-- Get player's hrp
	local character = player.Character
	local hrp = character and character:WaitForChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Stop the drag loop
	if self.DragConnection then
		self.DragConnection:Disconnect()
		self.DragConnection = nil
	end
	
	-- Play drop sound
	SoundUtil.playSound(trashDropSound, hrp)
	
	print("Stopped dragging:", self.DraggingTrash.Name)
	self.DraggingTrash = nil
	self.OriginalCFrame = nil
end

function TrashDragClient:FindTrashObject(part)
	-- Check if part is directly in Trash folder structure
	if part.Parent and part.Parent.Parent then
		local grandParent = part.Parent.Parent
		if grandParent.Name == "Trash" then
			return part
		end
	end
	
	-- Check if part is in a Model that's in Trash
	local model = part:FindFirstAncestorOfClass("Model")
	if model and model.Parent and model.Parent.Parent then
		if model.Parent.Parent.Name == "Trash" then
			return model
		end
	end
	return nil
end

function TrashDragClient:GetTrashPosition(trash)
	if trash:IsA("BasePart") then
		return trash.Position
	elseif trash:IsA("Model") and trash.PrimaryPart then
		return trash.PrimaryPart.Position
	end
	return nil
end

return TrashDragClient