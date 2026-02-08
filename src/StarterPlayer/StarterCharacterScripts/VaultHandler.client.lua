local UIS = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Animatii
local vaultTrack = humanoid:LoadAnimation(script:WaitForChild("VaultAnim"))
local slideTrack = humanoid:LoadAnimation(script:WaitForChild("SlideAnim"))
local narrowTrack = humanoid:LoadAnimation(script:WaitForChild("NarrowAnim"))

local vaultSound = script:WaitForChild("Jump")
local slideSound = script:WaitForChild("Slide")
local narrowSound = script:WaitForChild("Narrow")

local isVaulting = false

local function stopAllAnimations()
	for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop(0.1)
	end
end

-- Functie sa facem tot corpul sa nu se loveasca de nimic
local function setCharacterCollision(state)
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanCollide = state
		end
	end
end

local function executeParkour(hitObject, animationTrack, duration, forwardDistance, upwardOffset)
	isVaulting = true
	hrp.Anchored = true
	stopAllAnimations()

	-- 1. Pregatire (Fara Anchored, folosim Physics state)
	--humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	-- Facem caracterul sa treaca prin orice pe durata miscarii
	setCharacterCollision(false) 

	animationTrack:Play()
	if animationTrack == vaultTrack then 
		vaultSound:Play() 
	elseif animationTrack == slideTrack then
		slideSound:Play()
	elseif animationTrack == narrowTrack then
		narrowSound:Play()
	end

	-- 2. Calculam pozitia (Folosim CFrame-ul actual ca baza)
	local startCFrame = hrp.CFrame
	local targetCFrame = startCFrame * CFrame.new(0, upwardOffset, -forwardDistance)

	-- 3. Tween-ul
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})

	tween:Play()

	-- Asteptam sa se termine animația SAU tween-ul (care e mai lung)
	task.wait(duration)

	-- 4. Resetare
	hrp.Anchored = false
	setCharacterCollision(true)
	--humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	isVaulting = false
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or isVaulting or input.KeyCode ~= Enum.KeyCode.Space then return end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}

	local rayOrigin = hrp.Position + Vector3.new(0, 1, 0)
	local rayDirection = hrp.CFrame.LookVector * 15

	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if result and result.Instance then
		local hitObject = result.Instance

		if CollectionService:HasTag(hitObject, "Vault") then
			executeParkour(hitObject, vaultTrack, 1.3, 40, 4) -- Distanta 12, Inaltime 4
		elseif CollectionService:HasTag(hitObject, "Slide") then
			executeParkour(hitObject, slideTrack, 1.0, 18, 0)
		elseif CollectionService:HasTag(hitObject, "Narrow") then
			executeParkour(hitObject, narrowTrack, 1.5, 0, 0)
		end
	end
end)