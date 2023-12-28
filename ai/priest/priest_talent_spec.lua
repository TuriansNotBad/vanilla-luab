--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelPriestHealerSpec = {
	talents = {
		{Builds["1.12.1"], {
			{"Improved Renew", 3, 406}, {"Holy Specialization", 2, 401},
			{"Divine Fury", 5, 1181},
			{"Inspiration", 3, 361}, {"Holy Specialization", 4, 401},
			{"Improved Healing", 3, 408}, {"Holy Reach", 2, 1635},
			{"Spiritual Guidance", 5, 402},
			{"Spiritual Healing", 5, 404},
			
			{"Unbreakable Will", 5, 342},
			{"Improved Power Word: Fortitude", 2, 344}, {"Silent Resolve", 3, 352},
			{"Inner Focus", 1, 348}, {"Meditation", 3, 347}, {"Silent Resolve", 4, 352},
			{"Mental Agility", 5, 341},
			{"Divine Spirit", 1, 351},
		},},
	},
};
