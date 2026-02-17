local ts = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Constants)
local Remotes = RS.Remotes

local UpdateStat = Remotes:WaitForChild("UpdateStat")
local UpdateAllStats = Remotes:WaitForChild("UpdateAllStats")
local TriggerStatResultScreenFlash = Remotes:WaitForChild("TriggerStatResultScreenFlash")

local gui = script.Parent
local statsFrame = gui:WaitForChild("StatsFrame")

local energyBar = statsFrame:WaitForChild("EnergyBar")
local energyFill = energyBar:WaitForChild("EnergyFill")
local energyText = energyBar:WaitForChild("EnergyText")

local thirstBar = statsFrame:WaitForChild("ThirstBar")
local thirstFill = thirstBar:WaitForChild("ThirstFill")
local thirstText = thirstBar:WaitForChild("ThirstText")

local levelBar = statsFrame:WaitForChild("LevelBar")
local levelFill = levelBar:WaitForChild("LevelFill")
local levelText = levelBar:WaitForChild("LevelText")

-- Results
local thirstResultFrame = gui:WaitForChild("ThirstResultFrame")
local energyResultFrame = gui:WaitForChild("EnergyResultFrame")

-- Store current displayed values
local currentEnergy = 100
local currentThirst = 100

-- Store the XP needed for next level
local storedXPNeeded = 100
local currentLevel = 1

-- Animation function
local function animateNumber(textLabel, prefix, startValue, endValue, duration)
	-- Create a NumberValue to tween
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = startValue
	
	-- Update text when number changes
	numberValue.Changed:Connect(function(value)
		textLabel.Text = prefix .. math.floor(value)
	end)
	
	-- Create tween
	local tweenInfo = TweenInfo.new(duration)
	local tween = ts:Create(
		numberValue,
		tweenInfo,
		{
			Value = endValue,
		}
	)
	tween:Play()
	
	-- Cleanup after tween finishes
	tween.Completed:Connect(function()
		numberValue:Destroy()
	end)
end

-- Animate bar fill
local function animateBar(barFill, endPercent, duration)
	local tweenInfo = TweenInfo.new(duration)
	local tween = ts:Create(barFill, tweenInfo, {
		Size = UDim2.new(endPercent, 0, 1, 0)
	})
	tween:Play()
end

UpdateAllStats.OnClientEvent:Connect(function(data)
	print("=== UpdateAllStats Debug ===")
	print("Level:", data.Level)
	print("XP:", data.XP)
	print("XP Needed:", Constants.XPToLevelUp[data.Level])
	
	-- Update level and XP needed
	currentLevel = data.Level
	storedXPNeeded = Constants.XPToLevelUp[currentLevel] or 100
	levelText.Text = "Level " .. currentLevel
	
	-- Update Level Bar
	local xpPercent = data.XP / storedXPNeeded
	levelFill.Size = UDim2.new(xpPercent, 0, 1, 0)
	
	-- Update energy
	animateNumber(energyText, "Energy ", currentEnergy, data.Energy, 0.5)
	animateBar(energyFill, data.Energy / 100, 0.5)
	--energyFill.Size = UDim2.new(data.Energy / 100, 0, 1, 0)
	currentEnergy = data.Energy
	--energyText.Text = "Energy " .. math.floor(data.Energy)
	
	-- Update thirst
	animateNumber(thirstText, "Thirst ", currentThirst, data.Thirst, 0.5)
	animateBar(thirstFill, data.Thirst / 100, 0.5)
	--thirstFill.Size = UDim2.new(data.Thirst / 100, 0, 1, 0)
	currentThirst = data.Thirst
	--thirstText.Text = "Thirst " .. math.floor(data.Thirst)
	
	-- Update humanoid health
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.MaxHealth = data.MaxHealth
		humanoid.Health = data.Health
	end
end)

UpdateStat.OnClientEvent:Connect(function(type, value)
	if type == "Energy" then
		animateNumber(energyText, "Energy ", currentEnergy, math.floor(value), 0.5)
		animateBar(energyFill, value / 100, 0.5)
		currentEnergy = math.floor(value)
		--energyFill.Size = UDim2.new(value / 100, 0, 1, 0)
		--energyText.Text = "Energy " .. math.floor(value)
	elseif type == "Thirst" then
		animateNumber(thirstText, "Thirst ", currentThirst, math.floor(value), 0.5)
		animateBar(thirstFill, value / 100, 0.5)
		currentThirst = math.floor(value)
		--thirstFill.Size = UDim2.new(value / 100, 0, 1, 0)
		--thirstText.Text = "Thirst " .. math.floor(value)
	elseif type == "Level" then
		currentLevel = value
		storedXPNeeded = Constants.XPToLevelUp[currentLevel] or 100
		levelText.Text = "Level " .. math.floor(value)
	elseif type == "XP" then
		local xpPercent = value / storedXPNeeded
		levelFill.Size = UDim2.new(xpPercent, 0, 1, 0)
	elseif type == "Health" then
		-- check if humanoid exists
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = value
		end
		 
	end
end)

TriggerStatResultScreenFlash.OnClientEvent:Connect(function(statName)
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local properties1 = {
		BackgroundTransparency = 0,
	}
	local properties2 = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	}
	
	if statName == "Thirst" then
		thirstResultFrame.Visible = true
		local thirstTween = ts:Create(
			thirstResultFrame,
			tweenInfo,
			properties1
		)
		thirstTween:Play()
		thirstTween.Completed:Connect(function()
			local thirstTweenOut = ts:Create(
				thirstResultFrame,
				tweenInfo,
				properties2
			)
			thirstTweenOut:Play()
			thirstTweenOut.Completed:Connect(function()
				thirstResultFrame.Visible = false
			end)
		end)
	elseif statName == "Energy" then
		energyResultFrame.Visible = true
		local energyTween = ts:Create(
			energyResultFrame,
			tweenInfo,
			properties1
		)
		energyTween:Play()
		energyTween.Completed:Connect(function()
			local energyTweenOut = ts:Create(
				energyResultFrame,
				tweenInfo,
				properties2
			)
			energyTweenOut:Play()
			energyTweenOut.Completed:Connect(function()
				energyResultFrame.Visible = false
			end)
		end)
	end
end)
