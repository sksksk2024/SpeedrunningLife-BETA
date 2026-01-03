local ts = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- CONCEPT 1: RAYCASTING (Finding the Ground)
local function findGroundBelow(position)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {workspace.Debris} -- don't want to detect the rocks we JUST spawned
	
	-- cast ray downroad
	local origin = position
	local direction = Vector3.new(0, -1000, 0)
	
	local result = workspace:Raycast(origin, direction, rayParams)
	
	if result then
		return result.Position, result.Instance
	end
	
	return nil, nil
end

-- CONCEPT 2: ARRANGING IN A CIRCLE
local function createRockCircle(centerCFrame, radius, numRocks)
	local angleStep = 360 / numRocks
	local currentAngle = 0
	
	for i = 1, numRocks do
		local rockPosition = centerCFrame *
			CFrame.Angles(0, math.rad(currentAngle), 0) *
			CFrame.new(0, 0, -radius)
		
		print("Rock", i, "at angle:", currentAngle, "Position:", rockPosition.Position)
		
		currentAngle = currentAngle + angleStep
	end
end

--CONCEPT 3: ANIMATING ROCKS (Tweening)
local function animateRock(rock, groundPosition)
	-- start position: below ground
	rock.Position = groundPosition - Vector3.new(0, 5, 0)
	rock.Anchored = true
	
	-- Rise up
	local tweenUp = ts:Create(
		rock,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Position = groundPosition + Vector3.new(0, 4, 0)}
	)
	tweenUp:Play()
	
	-- Then sink back down
	task.delay(1, function()
		local tweenDown = ts:Create(
			rock,
			TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				Position = groundPosition - Vector3.new(0, 5, 0),
				Size = Vector3.new(1, 1, 1)
			}
		)
		tweenDown:Play()
		
		task.wait(4.5)
		rock:Destroy()
	end)
end

-- CONCEPT 4: PUTTING IT ALL TOGETHER - CRATER FUNCTION
local function createCrater(centerCFrame, radius, numRocks)
	-- Find actual ground
	local groundPosition, groundPart = findGroundBelow(centerCFrame.Position)
	
	if not groundPosition then
		warn("No ground found!")
		return
	end
	
	-- Calculate rock positions in circle
	local angleStep = 360 / numRocks
	local currentAngle = 0
	
	for i = 1, numRocks do
		-- Create Rock
		local rock = Instance.new("Part")
		rock.Name = "DebrisRock"
		rock.Size = Vector3.new(
			math.random(3, 5),
			math.random(2, 3),
			math.random(2, 4)
		)
		
		-- Match ground matrial
		rock.Material = groundPart.Material
		rock.Color = groundPart.Color
		
		-- Position circle
		local rockCFrame = CFrame.new(groundPosition) *
			CFrame.Angles(0, math.rad(currentAngle), 0) *
			CFrame.new(0, 0, -radius)
		
		rock.CFrame = CFrame.lookAt(rockCFrame.Position, groundPosition)
		
		rock.Parent = workspace
		
		-- Animate
		animateRock(rock, rockCFrame.Position)
		
		currentAngle = currentAngle + angleStep
	end
end

--local module = {}

--return module
