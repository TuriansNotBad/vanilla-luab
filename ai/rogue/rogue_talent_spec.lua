--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelRogueDpsSpec = {
	talents = {
		{Builds["1.2.4"], {
			-- assassination
			{"Malice", 5, 270},
			{"Improved Slice and Dice", 3, 277}, {"Ruthlessness", 3, 273},
			{"Relentless Strikes", 1, 281}, {"Lethality", 5, 269}, {"Improved Expose Armor", 3, 278},
			{"Cold Blood", 1, 280}, {"Improved Eviscerate", 3, 276}, {"Improved Instant Poison", 1, 268},
			{"Seal Fate", 5, 283},
			-- subtlety
			{"Camouflage", 5, 244},
			{"Opportunity", 5, 261},
			-- combat
			{"Lightning Reflexes", 5, 186},
			{"Improved Backstab", 3, 202}, {"Precision", 3, 181},
		},},
		{Builds["1.12.1"], {
			{"Opportunity", 5, 261},
			
			{"Malice", 5, 270},                       
			{"Improved Slice and Dice", 3, 277}, {"Ruthlessness", 2, 273},
			{"Lethality", 5, 269}, {"Relentless Strikes", 1, 281}, {"Ruthlessness", 3, 273}, {"Improved Eviscerate", 3, 276},
			{"Cold Blood", 1, 280}, {"Improved Poisons", 4, 268},			
			{"Seal Fate", 5, 283},
			
			{"Improved Sinister Strike", 2, 201}, {"Lightning Reflexes", 3, 186},
			{"Improved Backstab", 3, 202}, {"Precision", 5, 181}, {"Lightning Reflexes", 5, 186},
			{"Dual Wield Specialization", 1, 221},
		},},
	},
};
