--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelWarriorTankSpec = {
	talents = {
		{Builds["1.2.4"], {
				-- prot
				{"Shield Specialization", 5, 139},
				{"Toughness", 5, 140},
				-- fury
				{"Cruelty", 5, 157},
				{"Improved Demoralizing Shout", 5, 161},
				-- prot
				{"Defiance", 5, 144},
				{"Improved Taunt", 2, 143}, {"Improved Sunder Armor", 3, 146},
				{"Improved Shield Bash", 2, 149}, {"Improved Bloodrage", 2, 142}, {"Last Stand", 1, 153},
				{"One-Handed Weapon Specialization", 5, 702},
				{"Shield Discipline", 1, 148},
				{"Improved Shield Block", 1, 145},
				-- arms
				{"Deflection", 5, 130},
				{"Tactical Mastery", 4, 641},
			},
		},
		{Builds["1.12.1"], {
				{"Deflection", 5, 130},
				{"Tactical Mastery", 5, 641},
				
				{"Shield Specialization", 5, 1601},
				{"Improved Bloodrage", 2, 142}, {"Toughness", 3, 140},
				{"Defiance", 5, 144},
				{"Improved Taunt", 2, 143}, {"Improved Sunder Armor", 3, 146},
				{"Toughness", 5, 140}, {"Concussion Blow", 1, 152}, {"Improved Shield Block", 3, 145},
				{"One-Handed Weapon Specialization", 5, 702},
				{"Shield Slam", 1, 148},
			
				{"Anger Management", 1, 137},
				
				{"Cruelty", 5, 157},
				{"Unbridled Wrath", 3, 159},
			},
		},
	},
};
