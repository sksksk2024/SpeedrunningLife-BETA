local ts = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local SoundUtil = require(RS.Modules.SoundUtil)
local Constants = require(RS.Modules.Constants)

local doorOpeningSound = Constants.Sounds.doorOpening
local doorClosingSound = Constants.Sounds.doorClosing
local teleportSound = Constants.Sounds.teleportSound

-- Remotes
local Remotes = RS.Remotes
local TriggerTeleportVFX = Remotes:WaitForChild("TriggerTeleportVFX")

local DoorService = {}

function DoorService:Init()
	-- Find all doors in workspace
	local doors = workspace.Doors:GetChildren()
	
	for _, obj in doors do
		if obj.Name == "Door" and obj:IsA("Model") then
			local prompt = obj:FindFirstChild("ProximityPrompt")
			if prompt then
				-- Store closed position for swing doors
				local doorPart = obj.PrimaryPart or obj:FindFirstChild("DoorPart")
				if doorPart then
					obj:SetAttribute("ClosedCFrame", doorPart.CFrame)
				end
				
				prompt.Triggered:Connect(function(player)
					local doorType = obj:GetAttribute("DoorType") or "Swing"
					
					if doorType == "Swing" then
						self:ToggleDoor(obj)
					elseif doorType == "Teleport" then
						self:TeleportPlayer(obj, player)
					end
				end)
				
				print("Registered door:", obj.Name, "| Type:", obj:GetAttribute("DoorType") or "Swing")
			else
				warn("Door missing ProximityPrompt:", obj.Name)
			end
		end
	end
end

function DoorService:ToggleDoor(door)
	local doorPart = door.PrimaryPart or door:FindFirstChild("DoorPart")
	local hinge = door:FindFirstChild("Hinge")

	if not doorPart or not hinge then 
		warn("Door missing DoorPart or Hinge:", door.Name)
		return 
	end

	local isOpen = door:GetAttribute("IsOpen") or false
	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Get swing direction (default to right if not specified)
	local swingDirection = door:GetAttribute("SwingDirection") or "Right"
	local openAngle = swingDirection == "Left" and -90 or 90

	-- Store initial state on first use
	if not door:GetAttribute("InitialCFrame") then
		door:SetAttribute("InitialCFrame", doorPart.CFrame)
	end

	local initialCFrame = door:GetAttribute("InitialCFrame")

	-- Calculate offset from hinge to door
	local offset = hinge.CFrame:Inverse() * initialCFrame
	
	-- Get the primary part of the door
	local soundLocation
	
	if door.PrimaryPart then
		soundLocation = door.PrimaryPart
	end
	
	local targetCFrame
	if isOpen then
		-- Close: return to initial position
		door:SetAttribute("IsOpen", false)
		SoundUtil.playSound(doorClosingSound, soundLocation)
		targetCFrame = hinge.CFrame * offset
	else
		-- Open: rotate around hinge
		door:SetAttribute("IsOpen", true)
		SoundUtil.playSound(doorOpeningSound, soundLocation)
		local rotation = CFrame.Angles(0, math.rad(openAngle), 0)
		targetCFrame = hinge.CFrame * rotation * offset
	end

	local doorTween = ts:Create(doorPart, tweenInfo, {
		CFrame = targetCFrame
	})
	doorTween:Play()
end

-- Teleport player to a specific CFrame
function DoorService:TeleportPlayer(door, player)
	-- Get the destination name from the door's attribute
	local destinationName = door:GetAttribute("TeleportTo")
	if not destinationName then
		warn("Door has no TeleportTo attribute:", door.Name)
		return
	end
	
	-- Find the destination spawn point
	local spawns = workspace:FindFirstChild("Spawns")
	if not spawns then
		warn("No Spawns folder found")
		return
	end
	
	local destination = spawns:FindFirstChild(destinationName)
	if not destination then
		warn("Spawn point not found:", destinationName)
		return
	end
	
	-- Get player's character
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Get the player's HumanoidRootPart
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- Teleport the player with slight upward offset
	if destination:IsA("Model") then
		rootPart.CFrame = destination:GetPivot() + Vector3.new(0, 3, 0)
	else
		rootPart.CFrame = destination.CFrame + Vector3.new(0, 3, 0)
	end
	
	-- Play teleport sound
	SoundUtil.playSound(teleportSound, hrp)
	
	TriggerTeleportVFX:FireClient(player)
	
	print("Teleported", player.Name, "to", destinationName)
end

return DoorService
