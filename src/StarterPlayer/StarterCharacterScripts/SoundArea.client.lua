local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local DifferentAreas = workspace:WaitForChild("Areas")
local Remotes = RS:WaitForChild("Remotes")

-- Muzica default
local DEFAULT_MUSIC = "rbxassetid://73599153219420"
local DEFAULT_VOLUME = 0.1

local MINIGAME_MUSIC = "rbxassetid://140419044175901"

-- Sunetul principal
local areaSound = Instance.new("Sound", script)
areaSound.Looped = true
areaSound.SoundId = DEFAULT_MUSIC
areaSound.Volume = DEFAULT_VOLUME
areaSound:Play()

local CurrentArea = nil
local isInMinigame = false

-- Ascultam cand incepe minigame-ul
Remotes.StartMinigameTimer.OnClientEvent:Connect(function()
	isInMinigame = true
	areaSound.SoundId = MINIGAME_MUSIC
	areaSound.Volume = DEFAULT_VOLUME
end)

-- Ascultam cand se termina minigame-ul
Remotes.CompleteMinigameTimer.OnClientEvent:Connect(function()
	isInMinigame = false
	CurrentArea = nil
	areaSound.SoundId = DEFAULT_MUSIC
	areaSound.Volume = DEFAULT_VOLUME
	areaSound:Play()
end)

-- Parametri pentru detectarea volumului
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = {DifferentAreas}

RunService.Heartbeat:Connect(function()
	-- Daca suntem in minigame, oprim logica de schimbare
	if isInMinigame then return end
	
	-- Verificăm ce părți din folderul "Areas" se suprapun cu poziția jucătorului
	-- Creăm o mică cutie invizibilă de 2x2x2 în jurul jucătorului
	local foundParts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(2, 4, 2), overlapParams)
	local hitPart = foundParts[1] -- Luăm prima zonă detectată

	if hitPart then
		-- Dacă am intrat într-o zonă nouă
		if hitPart ~= CurrentArea then
			CurrentArea = hitPart
			local soundInPart = hitPart:FindFirstChildOfClass("Sound")

			if soundInPart then
				-- Schimbăm muzica
				areaSound.SoundId = soundInPart.SoundId
				areaSound.Volume = DEFAULT_VOLUME
				if not areaSound.IsPlaying then
					areaSound:Play()
				end
				print("Acum redau muzica pentru zona: " .. hitPart.Name)
			end
		end
	else
		-- Dacă nu suntem în nicio zonă (suntem pe drumul principal)
		if CurrentArea ~= nil then
			CurrentArea = nil
			areaSound.SoundId = DEFAULT_MUSIC
			areaSound.Volume = DEFAULT_VOLUME
		end
	end
end)