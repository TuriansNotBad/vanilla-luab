--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelRogueDpsSpec = {
	talents = {
		{Builds["1.2.4"], {
			-- combat
			{"Improved Sinister Strike", 2, 201}, {"Lightning Reflexes", 3, 186},
			{"Improved Backstab", 3, 202}, {"Precision", 5, 181}, {"Lightning Reflexes", 5, 186},
			{"Dagger Specialization", 5, 182},
			{"Blade Flurry", 1, 223}, {"Dual Wield Specialization", 5, 221},
			{"Aggression", 3, 1122}, {"Deflection", 1, 187},
			{"Adrenaline Rush", 1, 205},
			-- assassination
			{"Malice", 5, 270},
			{"Improved Slice and Dice", 3, 277}, {"Ruthlessness", 2, 273},
			{"Lethality", 5, 269}, {"Ruthlessness", 3, 273}, {"Relentless Strikes", 1, 281},
			{"Improved Eviscerate", 3, 276},
		},},
		{Builds["1.12.1"], {
			{"Opportunity", 5, 261},
			
			{"Malice", 5, 270},
			{"Improved Slice and Dice", 3, 277}, {"Murder", 2, 274},
			{"Lethality", 4, 269}, {"Relentless Strikes", 1, 281},
			
			{"Improved Sinister Strike", 2, 201}, {"Lightning Reflexes", 3, 186},
			{"Improved Backstab", 3, 202}, {"Precision", 5, 181}, {"Lightning Reflexes", 5, 186},
			{"Dual Wield Specialization", 5, 221}, {"Dagger Specialization", 5, 182},
			{"Blade Flurry", 1, 223},
			{"Weapon Expertise", 2, 1703},
			{"Improved Sprint", 2, 222},
			{"Adrenaline Rush", 1, 205},
		},},
	},
};
