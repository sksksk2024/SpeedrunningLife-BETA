local Constants = {}

-- PLAYER STATS
Constants.DefaultStats = {
	Thirst = 100,
	Energy = 100,
	Level = 1,
	CompletedLevels = {},
	DefeatedBullies = {},
}

-- VAULT ANIMATIONS


-- JUMP MINIGAME
Constants.XPPerJumpWin = 10000
Constants.DistanceLeaveGame = 1100

-- PLAYER MOVEMENT
Constants.WalkSpeedDefault = 16
Constants.JumpPowerDefault = 50
Constants.GravityScaleDefault = 1
Constants.WalkSpeedPad = 100
Constants.WalkSpeedMinigame = 100
Constants.JumpPowerPad = 100
Constants.JumpPowerPlayer = 300
Constants.GravityScale = 0.05

-- TRASH COLLECTION MINIGAME
Constants.TrashCollectionDistance = 50 -- How close trash must be to collector to collect
Constants.TrashPickupDistance = 30 -- How far player can be from trash to pick it up
Constants.TrashDragDistance = 10 -- How far in front of camera trash floats while dragging
Constants.TrashPlayerProximity = 25 -- How close player must be to trash for server to award XP
Constants.XPPerTrash = 5 -- XP awarded per trash collected

-- STATION TIERS
Constants.Tiers = {
	bronze = 5,
	silver = 15,
	golden = 25,
}
Constants.StationCooldown = 3

-- NEEDS DEPLETION (per second)
Constants.ThirstRate = 0.15
Constants.EnergyRate = 0.05

-- Guide Cutscene
Constants.TriggerDistance = 10

-- BULLY COMBAT
Constants.BullyDamage = {
	Level1 = 5,
	Level2 = 10,
	Level3 = 25,
	Level4 = 50,
	Level5 = 100,
	Level6 = 200,
	Level7 = 500,
	Level8 = 1000,
	Level9 = 2000,
	Level10 = 5000,
	Level11 = 10000,
	Level12 = 20000,
	Level13 = 50000,
}

Constants.PlayerBaseDamage = 10
Constants.DamagePerLevel = 20
Constants.BaseHealth = 100
Constants.HealthPerLevel = 50

Constants.XPPerBully = {
	Level1 = 10,
	Level2 = 25,
	Level3 = 50,
	Level4 = 100,
	Level5 = 250,
	Level6 = 500,
	Level7 = 1000,
	Level8 = 2500,
	Level9 = 5000,
	Level10 = 10000,
	Level11 = 25000,
	Level12 = 50000,
	Level13 = 100000,
}

Constants.XPToLevelUp = {
	[1] = 100,
	[2] = 250,
	[3] = 500,
	[4] = 1000,
	[5] = 2000,
	[6] = 3000,
	[7] = 4000,
	[8] = 5000,
	[9] = 6000,
	[10] = 7000,
	[11] = 8000,
	[12] = 9000,
	[13] = 10000,
}

Constants.Badges = {
	Visited = 3602368334706924,
	CityComplete = 1518773638548990,
}

Constants.Passes = {
	DoubleSpeed = 1729936942,
	Teleportation = 1728534055,
}

Constants.DevProducts = {
	RechargeResources = 3546245020,
	LevelUp = 3546245246,
	RechargeMap = 3546244773,
	BadDeath = 3546245992,
}

--FullHP = 3546245992, -- DevProduct


Constants.LevelRewards = {
	--City = {Money = 50, Energy = -20},
	City = {Energy = 20}
}

Constants.Animations = {
	Player = {
		Punch = "rbxassetid://122263097330782",
		Kick = "rbxassetid://84660093636494",
		Hurt = "rbxassetid://105554353446009",
		Victory = "rbxassetid://101376224869679",
		Defeat = "rbxassetid://140527045317336",
	},
	Bully = {
		Punch = "rbxassetid://130870148713693",
		Hurt = "rbxassetid://138591174355937",
		Defeat = "rbxassetid://74993711933805",
	}
}

Constants.Lighting = {
	outsideAmbient = Color3.fromRGB(150, 150, 150),
	insideAmbient = Color3.fromRGB(30, 30, 30),
	tweenSpeed = 1,
}

Constants.Sounds = {
	-- SFX
	outsideAmbient = {
		id = 73599153219420,
		volume = 0.05,
	},
	insideAmbient = {
		id = 9043883407,
		volume = 0.05,
	},
	vfxTutorialAudio = {
		id = 128690660595672,
		volume = 0.5,
	},
	speedBoost = {
		id = 92235360782852,
		volume = 0.5,
	},
	slowBoost = {
		id = 123972559146493,
		volume = 0.5,
	},
	doorOpening = {
		id = 833871080,
		volume = 0.25,
	},
	bullyPunchSound = {
		id = 9117969687,
		volume = 0.5,
	},
	trashDropSound = {
		id = 9118731216,
		volume = 0.25,
	},
	defeatFightSound = {
		id = 9044605335,
		volume = 0.1,
	},
	doorClosing = {
		id = 7038967181,
		volume = 0.25,
	},
	hitCarSound = {
		id = 9114402340,
		volume = 0.25,
	},
	deadOof = {
		id = 18765287354,
		volume = 2,
	},
	playerKick = {
		id = 8595975878,
		volume = 1,
	},
	playerPunch = {
		id = 8595980577,
		volume = 0.8,
	},
	defeatJumpSound = {
		id = 2440525645,
		volume = 0.25,
	},
	reviveSound = {
		id = 107610998788968,
		volume = 0.25,
	},
	teleportSound = {
		id = 108688312097046,
		volume = 0.5,
	},
	trashCollectedSound = {
		id = 107261392908541,
		volume = 0.25,
	},
	trashConvertedSound = {
		id = 4612373756,
		volume = 0.25,
	},
	winFightSound = {
		id = 86926216602953,
		volume = 0.1,
	},
	winJumpSound = {
		id = 7039366503,
		volume = 0.25,
	},
	messagePosterSound = {
		id = 1381230047,
		volume = 0.25,
	},
	leveledUpSound = {
		id = 84872960927850,
		volume = 0.25,
	},
	drinkSound = {
		id = 9114171960,
		volume = 1,
	},
	energySound = {
		id = 5530025800,
		volume = 1,
	},
	airSound = {
		id = 1836246174,
		volume = 0.25,
	},
	touchedSound = {
		id = 18922477538,
		volume = 0.25,
	},
	jumpPadHitSound = {
		id = 18922477538,
		volume = 0.25,
	},
}

return Constants