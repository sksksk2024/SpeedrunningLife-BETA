local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local RS = game:GetService("ReplicatedStorage")
local ServerScriptStorage = game:GetService("ServerScriptService")
local Services = ServerScriptStorage.Services

local ServerStorage = game:GetService("ServerStorage")
local MapResetEvent = ServerStorage.Bindables:WaitForChild("MapResetEvent")

local PlayerDataService = require(Services.PlayerDataService)
local Constants = require(RS.Modules.Constants)
local SoundUtil = require(RS.Modules.SoundUtil)

local trashConvertedSound = Constants.Sounds.trashConvertedSound

local TrashCollectionService = {}
TrashCollectionService.ActiveTrash = {} -- Stores trash items that can be collected
TrashCollectionService.CollectedTrash = {} -- Tracks what each player collected
TrashCollectionService.TrashOwners = {}

local COLLECTION_DISTANCE = Constants.TrashCollectionDistance
local PLAYER_PROXIMITY = Constants.TrashPlayerProximity
local XP_PER_TRASH = Constants.XPPerTrash

-- Create RemoteEvent for client communication
local Remotes = RS.Remotes
local claimTrashEvent = Remotes:FindFirstChild("ClaimTrashEvent")
local TriggerTrashStatResultScreenFlash = Remotes:WaitForChild("TriggerTrashStatResultScreenFlash")

-- Create collision groups
local function setupCollisionGroups()
	-- Check if groups already exist
	local success = pcall(function()
		--PhysicsService:GetCollisionGroupId("Trash")
		-- Use BasePart.CollisionGroup instead of the above cus its deprecated
		-- IDK
	end)

	if not success then
		-- Create collision groups
		PhysicsService:RegisterCollisionGroup("Trash")
		PhysicsService:RegisterCollisionGroup("Players")

		-- Make trash NOT collide with players
		PhysicsService:CollisionGroupSetCollidable("Trash", "Players", false)

		--print("Collision groups created: Trash won't collide with players!")
	end
end

function TrashCollectionService:Init()
	-- Find the Trash folder
	local lakeMinigameFolder = workspace.LakeMinigame
	local trashFolder = lakeMinigameFolder:WaitForChild("Trash")
	if not trashFolder then
		warn("Trash folder not found!")
		return
	end
	
	-- Setup all trash items
	for _, category in trashFolder:GetChildren() do
		for _, trash in category:GetChildren() do
			self:SetupTrashItem(trash) -- setup each trash item
		end
	end
	
	MapResetEvent.Event:Connect(function()
		print("Reset detected")

		self.ActiveTrash = {}
		self.TrashOwners = {}

		local trashFolder = workspace.LakeMinigame:WaitForChild("Trash")

		for _, category in trashFolder:GetChildren() do
			for _, trash in category:GetChildren() do
				self:SetupTrashItem(trash)
			end
		end
	end)

	-- Find all collectors
	local collectorsFolder = lakeMinigameFolder:WaitForChild("TrashCollectors")
	if not collectorsFolder then
		warn("TrashCollectors folder not found!")
		return
	end

	-- Start the collection detection loop
	self:StartCollectionLoop(collectorsFolder)
	
	-- Listen for trash claim events from clients
	claimTrashEvent.OnServerEvent:Connect(function(player, trash)
		if trash and self.ActiveTrash[trash] then
			self.TrashOwners[trash] = player
			print(player.Name, "claimed ownership of", trash.Name)
		end
	end)

	-- Setup player collision group
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			task.wait(0.1)
			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					part.CollisionGroup = "Players"
				end
			end
		end)
	end)
end

function TrashCollectionService:SetupTrashItem(trash)
	-- Check if trash is a BasePart (single part)
	--print("Setting up trash:", trash.Name, trash.ClassName)

	if trash:IsA("BasePart") then
		self.ActiveTrash[trash] = true

		-- Make it draggable
		trash.CanCollide = true
		trash.Anchored = false
		trash.CollisionGroup = "Trash"
		
		-- Track when players touch trash
		trash.Touched:Connect(function(hit)
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					self.TrashOwners[trash] = player
					--print(player.Name, "is now owner of", trash.Name)
				end
			end
		end)
		
		--print("✓ Trash configured:", trash.Name)
	elseif trash:IsA("Model") then
		local primaryPart = trash.PrimaryPart or trash:FindFirstChildWhichIsA("BasePart")
		if primaryPart then
			self.ActiveTrash[trash] = true
			trash.PrimaryPart = primaryPart

			-- Make all meshes in model non-collidable
			for _, part in trash:GetDescendants() do
				if part:IsA("BasePart") then
					part.CanCollide = false
					part.Anchored = false
				end
			end
			
			-- Track touches on model's primary part
			primaryPart.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChild("Humanoid")
				if humanoid then
					local player = Players:GetPlayerFromCharacter(hit.Parent)
					if player then
						self.TrashOwners[trash] = player
						local character = player.Character
						local hrp = character:FindFirstChild("HumanoidRootPart")
						
						print(player.name, "is now owner of", trash.Name)
					end
				end
			end)
		end
	end
end

function TrashCollectionService:StartCollectionLoop(collectorsFolder)
	--print("=== COLLECTORS ===")
	-- Use task.spawn to run code in parallel
	task.spawn(function()
		while true do
			task.wait(0.1)

			-- Loop through all active trash
			for trash, _ in pairs(self.ActiveTrash) do
				-- Make sure trash still exists
				if not trash or not trash.Parent then
					self.ActiveTrash[trash] = nil
					continue
				end

				local trashPos = self:GetTrashPosition(trash)
				if not trashPos then continue end

				-- Check each collector
				for _, collector in collectorsFolder:GetChildren() do
					local collectorPos = collector:GetPivot().Position
					local distance = (trashPos - collectorPos).Magnitude

					-- If trash is close enough to collector
					if distance <= COLLECTION_DISTANCE then
						self:CollectTrash(trash, collector)
						break
					end
				end
			end
		end
	end)
end

function TrashCollectionService:GetTrashPosition(trash)
	if trash:IsA("BasePart") then
		return trash.Position
	elseif trash:IsA("Model") and trash.PrimaryPart then
		return trash.PrimaryPart.Position
	end
	return nil
end

function TrashCollectionService:CollectTrash(trash, collector)
	local owner = self.TrashOwners[trash]
	local ownerCharacter = owner and owner.Character
	local hrp = ownerCharacter and ownerCharacter:FindFirstChild("HumanoidRootPart")
	
	-- Remove trash from lists
	self.ActiveTrash[trash] = nil
	self.TrashOwners[trash] = nil

		-- Destroy the trash object
		trash:Destroy()
		
	if owner then
		-- Award XP to the player
		PlayerDataService:AddXP(owner, XP_PER_TRASH)
		
		-- Trigger Result UI Event
		local player = Players:GetPlayerFromCharacter(ownerCharacter)
		
		TriggerTrashStatResultScreenFlash:FireClient(player)
		
		-- Play collection sound
		SoundUtil.playSound(trashConvertedSound, hrp)
		
		--print(owner.Name, "collected", trash.Name, "and gained", XP_PER_TRASH, "XP!")
	else
		print("Trash collected but no player nearby!")
	end
end

return TrashCollectionService