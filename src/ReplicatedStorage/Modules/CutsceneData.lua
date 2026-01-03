local CutsceneData = {}

CutsceneData.Subtitles = {
	Intro = {
		{time = 5, text = "Weak man", duration = 3}
	},
	Guide = {
		{time = 0, text = "Welcome to the city", duration = 2.5},
		{time = 2.5, text = "You have the objective of going through all the worlds, and finding your purpose in this game", duration = 3},
		{time = 5.5, text = "You can have fun by", duration = 2},
		{time = 7.5, text = "clean up lakes", duration = 3},
		{time = 10.5, text = "compete with friends", duration = 3},
		{time = 11.5, text = "and much more", duration = 2},
		{time = 13.5, text = "Have fun :)", duration = 3}
	},
	-- Start Quests
	-- City
	--GuideCity1 = {
	--	{time = 0, text = "Go to the city", duration = 3},
	--},
}

CutsceneData.Animations = {
	CutscneIntroPlayerV1 = "rbxassetid://114257461118075",
	CutsceneIntroBully1V1 = "rbxassetid://103685120382292",
	--CutsceneGuideV1 = "rbxassetid://114257461118075",
}

return CutsceneData
