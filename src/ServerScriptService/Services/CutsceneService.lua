local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remotes = RS.Remotes
local StateService = require(script.Parent.StateService)
local PlayerDataService = require(script.Parent.PlayerDataService)

local ShowLoadingScreen = Remotes:WaitForChild("ShowLoadingScreen")
local PlayCutscene = Remotes:WaitForChild("PlayCutscene")
local EndCutscene = Remotes:WaitForChild("EndCutscene")

local TeleportPlayer = workspace.TeleportPlayer

local Areas = workspace.Areas

local CutsceneService = {}

 --Anchor player immediately when they spawn (before cutscene logic runs)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local hrp = character:WaitForChild("HumanoidRootPart", 10)
		if hrp then
			-- Anchor immediately to prevent movement before cutscene
			hrp.Anchored = true
			print("Player anchored on spawn:", player.Name)
		end
	end)
end)

function CutsceneService:PlayIntroCutscene(player)
	local data = PlayerDataService:GetData(player)
	
	if not data then
		warn("No data for player:", player.Name)
		return
	end
	
	if data.HasSeenIntroCutscene then
		-- Show loading screen instead
		ShowLoadingScreen:FireClient(player)
		
		-- Unanchor since they're not watching cutscene
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = false
			end
		end
		return
	end
	
	-- Wait for character with timeout
	local character = player.Character
	if not character then
		warn("Waiting for character to load...")
		character = player.CharacterAdded:Wait()
	end
	
	-- Wait for essential parts
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	local humanoid = character:WaitForChild("Humanoid", 10)
	
	if not hrp or not humanoid then
		warn("Character not fully loaded for:", player.Name)
		return
	end
	
	-- small delay to ensure character is fully replicated
	task.wait(0.5)
	
	-- Make character archivable (allows cloning)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Archivable = true
		end
	end
	character.Archivable = true
	
	-- Try to clone
	local success, characterClone = pcall(function()
		return character:Clone()
	end)
	
	if not success or not characterClone then
		warn("Failed to clone character for:", player.Name, "Error:", characterClone)
		hrp.Anchored = false
		return
	end
	
	print("Successfully cloned character for:", player.Name)
	
	characterClone.Name = player.Name .. "_CutsceneClone" -- Unique name
	
	local cutsceneSpawnPoint = workspace.GYMCutscene:FindFirstChild("playerCutsceneIntro")
	
	
	if not cutsceneSpawnPoint then
		warn("Cutscene spawn point not found!")
		characterClone:Destroy()
		return
	end
	
	-- Hide the spawn point
	
	-- Parent first, then position
	characterClone.Parent = workspace.GYMCutscene
	
	-- PivotTo works for both Models and Parts!
	characterClone:PivotTo(cutsceneSpawnPoint:GetPivot())
	
	-- Scale the clone
	characterClone:ScaleTo(2.835)
	
	-- Move spawn point down
	cutsceneSpawnPoint:PivotTo(cutsceneSpawnPoint:GetPivot() * CFrame.new(0, -1000, 0))
	
	print("Positioned clone at:", cutsceneSpawnPoint:GetPivot())
	
	-- Hide real player
	hrp.CFrame = TeleportPlayer.CFrame + Vector3.new(0, 5, 0)
	hrp.Anchored = true	

	-- Lock player movement
	StateService:SetState(player, "InCutscene")
	
	-- Fire to client to play the cutscene
	PlayCutscene:FireClient(player, "Intro", characterClone.Name)
	
	-- Mark as seen
	data.HasSeenIntroCutscene = true
	print("Intro cutscene started for:", player.Name)
end

function CutsceneService:PlayGuideCutscene(player)
	local character = player.Character
	if not character then return end
	
	StateService:SetState(player, "InCutscene")
	
	-- Anchore player during guide cutscene
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Anchored = true
	end
	
	-- Activate the area sound
	local Guide1Area = Instance.new("Part")
	Guide1Area.Name = "Guide1Area"
	Guide1Area.Anchored = true
	Guide1Area.CanCollide = false
	Guide1Area.Position = Vector3.new(35.5, 38.834, -73.1)
	Guide1Area.Size = Vector3.new(187.6, 147.3, 212.6 )
	Guide1Area.Transparency = 1
	Guide1Area.Parent = Areas
	
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://75963850963192"
	Sound.Parent = Guide1Area
	
	-- No clone
	PlayCutscene:FireClient(player, "Guide")
end

-- Handle when client finishes cutscene
EndCutscene.OnServerEvent:Connect(function(player, cutsceneName)
	StateService:SetState(player, "Idle")
	
	-- If guide cutscene, destroy the Guide1Area part
	if cutsceneName == "Guide" then
		local Guide1Area = workspace.GYMCutscene:FindFirstChild("Guide1Area")
		if Guide1Area then
			Guide1Area:Destroy()
		end	
	end
	
	-- Clean up the clone
	-- HINT: you might need to store clones in a table
	local clone = workspace.GYMCutscene:FindFirstChild(player.Name .. "_CutsceneClone")
	if clone then
		clone:Destroy()
	end
	
	-- Restore the real player
	local character = player.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.Anchored = false

			-- Only teleport after Intro cutscene
			if cutsceneName == "Intro" then
				rootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
			end
		end
	end
	--player.Character:MoveTo(workspace.SpawnLocation.Position)
	
	print(player.Name, "finished cutscene")
end)

return CutsceneService