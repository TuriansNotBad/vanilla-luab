--[[*******************************************************************************************
	Talent builds for druid agents.
	Notes:
		Talent specs must be sorted in ascending order wrt client build.
*********************************************************************************************]]

-- Balance druid dps build for leveling PI.
t_LevelBalanceDruidDpsSpec = {
	talents = {
		{Builds["1.2.4"], {
			-- balance
			{"Improved Wrath", 5, 762},
			{"Improved Moonfire", 5, 763}, {"Omen of Clarity", 1, 788}, {"Nature's Reach", 2, 764},
			{"Improved Starfire", 2, 784}, {"Moonglow", 5, 783}, 
			{"Moonfury", 5, 790},
			{"Nature's Grace", 1, 789},
			{"Vengeance", 5, 792},
			{"Hurricane", 1, 793},
			-- restoration
			{"Improved Mark of the Wild", 5, 821},
			{"Improved Healing Touch", 5, 824},
			{"Combat Endurance", 5, 843},
			{"Reflection", 4, 829},},
		},
	},
};

-- Feral druid dps build for leveling PI.
t_LevelFeralDruidDpsSpec = {
	talents = {
		{Builds["1.2.4"], {
			{"Ferocity", 5, 796},
			{"Sharpened Claws", 5, 798},
			{"Blood Frenzy", 5, 800},
			{"Faerie Fire (Cat)", 1, 1162},
			{"Improved Mark of the Wild", 5, 821},
			{"Improved Shred", 2, 802}, {"Predatory Strikes", 5, 803}, 
			{"Thick Hide", 1, 794}, {"Feline Swiftness", 1, 807},
			{"Strength of the Wild", 4, 808}, {"Improved Ravage", 1, 805},
			{"Primal Instinct", 1, 809},
			{"Improved Healing Touch", 5, 824},
			{"Intensity", 5, 827}, {"Combat Endurance", 5, 843}, 
		},},
		{Builds["1.12.1"], {
			{"Ferocity", 5, 796},
			{"Thick Hide", 5, 794},
			{"Sharpened Claws", 3, 798}, {"Feline Swiftness", 2, 807}, 
			{"Predatory Strikes", 3, 803}, {"Improved Shred", 2, 802},  
			{"Faerie Fire (Feral)", 1, 1162},
			{"Blood Frenzy", 2, 800},
			{"Savage Fury", 2, 805},
			{"Heart of the Wild", 5, 808},
			{"Leader of the Pack", 1, 809},
			{"Improved Mark of the Wild", 5, 821},
			{"Improved Wrath", 5, 762},
			{"Natural Weapons", 5, 791},
			{"Omen of Clarity", 1, 788},
			{"Natural Shapeshifter", 3, 781},
			{"Furor", 1, 822},
		},},
	},
};
