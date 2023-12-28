--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelMageDpsSpec = {
	talents = {
		{Builds["1.12.1"], {
			{"Improved Frostbolt", 5, 37}, {"Elemental Precision", 3, 1649},
			{"Ice Shards", 5, 73}, {"Permafrost", 1, 65},
			{"Piercing Ice", 3, 61}, {"Cold Snap", 1, 69}, {"Improved Blizzard", 2, 63},
			{"Arctic Reach", 2, 741}, {"Frost Channeling", 3, 66},
			{"Ice Block", 1, 72},
			{"Winter's Chill", 5, 68},
			{"Ice Barrier", 1, 71},
			
			{"Arcane Subtlety", 2, 74}, {"Arcane Focus", 3, 76},
			{"Magic Absorption", 4, 1650}, {"Arcane Concentration", 5, 75},
			{"Magic Attunement", 2, 82},
			{"Arcane Meditation", 3, 1142},
		},},
	},
};
