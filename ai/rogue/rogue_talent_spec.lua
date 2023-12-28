--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelRogueDpsSpec = {
	talents = {
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
