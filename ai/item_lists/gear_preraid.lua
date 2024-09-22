-----------------------------------------------------------------------------------------------
-- Equipment loadouts for level 60, no MC/Onyxia items, 1.2 gear only.
-----------------------------------------------------------------------------------------------

Enchants =
{
	["LA of Constitution"] = 1503,
	["LA of Voracity AGI"] = 1508, -- +8 Agi
	["LA of Voracity INT"] = 1509, -- +8 Int
	["LA of Voracity SPI"] = 1510, -- +8 Spi
	["Major Health"]       = 1892,
	["Lesser Agility"]     = 849,
	["Spirit"]             = 851,  -- +5 Spi
	["Greater Stamina"]    = 929,
	["Greater Intellect"]  = 1883, -- +7 Int
	["Superior Spirit"]    = 1884, -- +9 Spi
	["Superior Strength"]  = 1885, -- +9 Str
	["Superior Stamina"]   = 1886,
	["Greater Agility"]    = 1887,
	["Greater Resistance"] = 1888, -- +5 all resistances
	["Greater Stats"]      = 1891, -- +4 all stats
	["Major Intellect"]    = 1904, -- +9 Int
	["Fire Resistance"]    = 2463,
	["Crusader"]           = 1900,
	["Sniper Scope"]       = 664,
	["Superior Striking"]  = 1897, -- +5 weapon dmg
	["Winter's Might"]     = 2443, -- +7 frost spell damage
};

local function WarriorTank_GetMainHandWpn(player)
	if (player:GetRace() == RACE_HUMAN) then
		return {15806, lvl=55, e=Enchants["Crusader"]};
	end
	return {12798, e=Enchants["Crusader"]};
end

local function PriestHeal_GetRing(player)
	return player:GetRace() == RACE_HUMAN and {12543,lvl=50} or {12545,lvl=48};
end

local t_gearLoadout60 = 
{
	
	PriestHeal = {
		13141,                                              -- Tooth of Gnarr, 58
		14558,                                              -- Lady Maye's Pendant, 59
		{16058, lvl=52},                                    -- Fordring's Seal, 52
		PriestHeal_GetRing,                                 -- Songstone of Ironforge for alliance, Eye of Orgrimmar for horde
		12930,                                              -- Briarwood Reed, 55
		11819,                                              -- Second Wind, 54
		11923,                                              -- The Hammer of Grace, 52
		11928,                                              -- Thaurissan's Royal Scepter, 55
		13938,                                              -- Bonecreeper Stylus, 57
		{13102, e=Enchants["LA of Voracity SPI"]},          -- Cassandra's Grace, 42
		11624,                                              -- Kentic Amice, 47
		{13386, rp=2033, e=Enchants["Greater Resistance"]}, -- Archivist Cape, 56
		{14154, e=Enchants["Greater Stats"]},               -- Truefaith Vestments, 57
		{16697, e=Enchants["Superior Spirit"]},             -- Devout Bracers, 52
		12554,                                              -- Hands of the Exalted Herald, 54
		11662,                                              -- Ban'thok Sash, 49
		{11841, e=Enchants["LA of Voracity SPI"]},          -- Senior Designer's Pantaloons, 50
		{11822, e=Enchants["Spirit"]},                      -- Omnicast Boots, 54
	},
	
	RogueDps = {
		{15411, lvl=52},                           -- Mark of Fordring, 52
		17713,                                     -- Blackstone Ring, 49
		13098,                                     -- Painweaver Band, 58
		11815,                                     -- Hand of Justice, 53
		{13965, lvl=55},                           -- Blackhand's Breadth, 
		{12590, e=Enchants["Crusader"]},           -- Felstriker, 58
		{13368, e=Enchants["Superior Striking"]},  -- Bonescraper, 57
		{2100,  e=Enchants["Sniper Scope"]},       -- Precisely Calibrated Boomstick, 43
		{16707, e=Enchants["LA of Voracity AGI"]}, -- Shadowcraft Cap, 57
		16708,                                     -- Shadowcraft Spaulders, 55
		{13340, e=Enchants["Lesser Agility"]},     -- Cape of the Black Baron, 58
		{16721, e=Enchants["Greater Stats"]},      -- Shadowcraft Tunic, 58
		{16710, e=Enchants["Superior Strength"]},  -- Shadowcraft Bracers, 52
		{15063, e=Enchants["Greater Agility"]},    -- Devilsaur Gauntlets, 53
		16713,                                     -- Shadowcraft Belt, 53
		{15062, e=Enchants["LA of Voracity AGI"]}, -- Devilsaur Leggings, 55
		{16711, e=Enchants["Greater Agility"]},    -- Shadowcraft Boots, 54
	},
	
	MageFrostDps = {
		14558,                                              -- Lady Maye's Pendant, 59
		942,                                                -- Freezing Band, 47
		942,                                                -- Freezing Band, 47
		12930,                                              -- Briarwood Reed, 55
		{13968, lvl=55},                                    -- Eye of the Beast, 55
		{13964, e=Enchants["Winter's Might"]},              -- Witchblade, 57
		{11904, lvl=47},                                    -- Spirit of Aquementas, 47
		13938,                                              -- Bonecreeper Stylus, 57
		{12752, lvl=57, e=Enchants["LA of Voracity INT"]},  -- Cap of the Scarlet Savant, 57
		11782,                                              -- Boreal Mantle, 52
		{13386, rp=1960, e=Enchants["Greater Resistance"]}, -- Archivist Cape (RP 1884 Fiery Wrath, RP 1960 Frozen Wrath), 56
		{14152, e=Enchants["Greater Stats"]},               -- Robe of the Archmage, 57
		{11766, rp=1960, e=Enchants["Greater Intellect"]},  -- Flameweave Cuffs, 52, (RP 1960 Frozen Wrath)
		13253,                                              -- Hands of Power, 55
		11662,                                              -- Ban'thok Sash, 49
		{13170, e=Enchants["LA of Voracity INT"]},          -- Skyshroud Leggings, 55
		{11822, e=Enchants["Spirit"]},                      -- Omnicast Boots, 54
	},
	
	WarriorTank = {
		13091,                                          -- Medallion of Grand Marshal Morris, 52
		{10795, rp=1206},                               -- Drakeclaw Band, of the Bear, RP 1206, 49
		{10795, rp=1206},                               -- Drakeclaw Band, of the Bear, RP 1206, 49
		11810,                                          -- Force of Will, 55
		{13966, lvl=55},                                -- Mark of Tyranny, 55, no lvl
		{12651, e=Enchants["Sniper Scope"]},            -- Blackcrow, 54
		{12602, e=Enchants["Greater Stamina"]},         -- Draconian Deflector, 58
		WarriorTank_GetMainHandWpn,                     -- Mirah's Song, 55, no lvl, HUMAN | Annihilator, 58, NOT HUMAN
		{12640, e=Enchants["LA of Constitution"]},      -- Lionheart Helm, 56
		14552,                                          -- Stockade Pauldrons, 50
		{13397, e=Enchants["Fire Resistance"]},         -- Stoneskin Gargoyle Cape, 56
		{15413, lvl=52, e=Enchants["Major Health"]},    -- Ornate Adamantium Breastplate, 52, no lvl
		{12936, e=Enchants["Superior Stamina"]},        -- Battleborn Armbraces, 58
		{13963, lvl=55, e=Enchants["Greater Agility"]}, -- Voone's Vice Grips, 55, no lvl
		13502,                                          -- Handcrafted Mastersmith Girdle, 58
		{14554, e=Enchants["LA of Constitution"]},      -- Cloudkeeper Legplates, 57
		{16734, e=Enchants["Greater Stamina"]},         -- Boots of Valor, 54
	},
	
};

function Gear_GetLoadoutForLevel60(key)
	if (key) then
		return t_gearLoadout60[key];
	end
end
