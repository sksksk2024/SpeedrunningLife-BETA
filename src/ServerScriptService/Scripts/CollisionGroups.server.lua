local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

print("🔧 Setting up collision groups...")

-- STEP 1: Register the groups
PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:RegisterCollisionGroup("RockDebris")

-- STEP 2: Set collision rules
PhysicsService:CollisionGroupSetCollidable("Players", "RockDebris", false)

print("✅ Collision groups registered!")
print("  - Players will NOT collide with RockDebris")

-- STEP 3: Assign parts to groups
Players.PlayerAdded:Connect(function(player)
	print("👤 Player joined:", player.Name)
	
	player.CharacterAppearanceLoaded:Connect(function(character)
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.CollisionGroup = "Players"
			end
		end
		
		print("  ✅ Set collision group for", player.Name)
	end)
end)

-- handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.CollisionGroup = "Players"
			end
		end
	end
end

--local function createDebrisRock()
--	local rock = Instance.new("Part")
--	rock.CollisionGroup = "RockDebris"
--	rock.Parent = workspace
--end

