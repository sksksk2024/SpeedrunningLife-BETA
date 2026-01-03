local SoundService = game:GetService("SoundService")

local SoundUtil = {}

function SoundUtil.playSound(soundData, parent, options)
	if not soundData or not parent then return end
	if typeof(soundData) ~= "table" then return end
	
	local options = options or {}
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundData.id
	sound.Volume = options.volume or soundData.volume or 0.5
	sound.PlaybackSpeed = options.pitch or 1
	sound.TimePosition = options.startTime or 0
	sound.Looped = options.looped or false
	sound.Parent = parent
	
	-- Delay before playing
	if options.delay and options.delay > 0 then
		task.delay(options.delay, function()
			if sound.Parent then
				sound:Play()
			end
		end)
	else
		sound:Play()
	end
	
	-- Auto stop after duration
	if not sound.Looped then
		if options.duration then
			task.delay(options.duration, function()
				if sound and sound.Parent then
					sound:Stop()
					sound:Destroy()
				end
			end)
		else
			sound.Ended:Once(function()
				if sound then
					sound:Destroy()
				end
			end)
		end
	end
	
	return sound
end

return SoundUtil
