--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelShamanHealSpec = {
	talents = {
		{Builds["1.12.1"], {
			{"Ancestral Knowledge", 5, 614},
			{"Tidal Focus", 5, 593},
			
			{"Improved Healing Wave", 2, 586},
			{"Ancestral Healing", 3, 581},
			
			{"Healing Grace", 3, 1646},
			{"Totemic Mastery", 1, 582},
			{"Improved Healing Wave", 3, 586},
			
			{"Restorative Totems", 5, 588}, {"Tidal Mastery", 5, 594},
			{"Purification", 5, 592},
			{"Mana Tide Totem", 1, 590},
			{"Nature's Swiftness", 1, 591},
			
			{"Guardian Totems", 2, 609}, {"Thundering Strikes", 3, 613},
			{"Enhancing Totems", 2, 610},
			
			{"Healing Way", 3, 1648}, 
			{"Improved Healing Wave", 5, 586},
			{"Totemic Focus", 2, 595},
		},},
	},
};
