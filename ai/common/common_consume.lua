--[[*******************************************************************************************
	Common functions for consumables.
	Notes:
		Engineering Skill Id = 202;
		Levels requirements and max skill for 202:
		- Apprentice = 5  (75)
		- Journeyman = 10 (150)
		- Expert     = 20 (225)
		- Artisan    = 35 (300)
*********************************************************************************************]]

SPELL_GEN_GOBLIN_SAPPER_CHARGE          = 13241; -- requires skill 205 - level 10.
SPELL_GEN_FLASK_OF_THE_TITANS           = 17626; -- requires level 50
SPELL_GEN_FLASK_OF_DISTILLED_WISDOM     = 17627; -- requires level 50
SPELL_GEN_FLASK_OF_SUPREME_POWER        = 17628; -- requires level 50
SPELL_GEN_FLASK_OF_CHROMATIC_RESISTANCE = 17629; -- requires level 50

local flask = {
	[SPELL_GEN_FLASK_OF_SUPREME_POWER] = 50,
	[SPELL_GEN_FLASK_OF_THE_TITANS] = 50,
	[SPELL_GEN_FLASK_OF_DISTILLED_WISDOM] = 50,
	[SPELL_GEN_FLASK_OF_CHROMATIC_RESISTANCE] = 50,
};

local food = {
	{45, 1131}, -- Alterac Swiss: 8932. Restores 2148 health.
	{25, 1129}, -- Bloodbelly Fish: 13546. Restores 1392 health.
	{10,  435}, -- Dig Rat Stew: 5478. Restores 552 health.
	{ 5,  434}, -- Smoked Bear Meat: 6890. Restores 243.6 health.
	{ 0,  433}, -- Darnassian Bleu: 2070. Restores 61.2 health.
};

local drink = {
	{55, 22734}, -- Conjured Crystal Water: 8079. Restores 4200 mana.
	{45,  1137}, -- Conjured Sparkling Water: 8078. Restores 2934 mana.
	{35,  1135}, -- Conjured Mineral Water: 8077. Restores 1992 mana.
	{25,  1133}, -- Conjured Spring Water: 3772. Restores 1344.6 mana.
	{ 5,   431}, -- Conjured Fresh Water: 2288. Restores 436.8 mana.
	{ 0,   430}, -- Conjured Water: 5350. Restores 151.2 mana.
};

local rage = {
	{46, 17528}, -- Mighty Rage Potion
	{25,  6613}, -- Great Rage Potion
};

local mana = {
	{49, 17531}, -- Major Mana Potion
	{41, 17530}, -- Superior Potion
	{31, 11903}, -- Greater Mana Potion
	{22,  2023}, -- Mana Potion
	{14,   438}, -- Lesser Mana Potion
};

local explosives = {
	{35, 23063}, -- dense dynamite
	{20, 12419}, -- solid dynamite
	{10,  4062}, -- heavy dynamite
	{5,   4061}, -- coarse dynamite
};

if (CVER < Builds["1.4.2"]) then
	table.remove(explosives, 1);
end

if (CVER < Builds["1.3.1"]) then
	table.remove(drink, 1);
end

local function GetLeveledItemFromTbl(t, level)
	for i = 1, #t do
		if (t[i][1] <= level) then
			return t[i][2];
		end
	end
end

function Consumable_GetExplosive(level)
	return GetLeveledItemFromTbl(explosives, level);
end

function Consumable_GetFood(level)
	return GetLeveledItemFromTbl(food, level);
end

function Consumable_GetWater(level)
	return GetLeveledItemFromTbl(drink, level);
end

function Consumable_GetRagePotion(level)
	return GetLeveledItemFromTbl(rage, level);
end

function Consumable_GetManaPotion(level)
	return GetLeveledItemFromTbl(mana, level);
end

function Consumable_GetFlask(spellid, level)
	if (flask[spellid] and flask[spellid] <= level) then
		return spellid;
	end
end
