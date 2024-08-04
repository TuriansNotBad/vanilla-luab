--[[*******************************************************************************************
	Defines all useable agent specs as well as general class information.
*********************************************************************************************]]

--[[*****************************************************
	- Given type-value pairs as consecutive arguments
	builds a t[type]=value table. Additionally sets
	field "n" to number of elements.
	- Returns table.
*******************************************************]]
function GearSelectionWeightTable(...)
	local t = {};
	local n = 0;
	for i = 1, select("#", ...), 2 do
		local tp = select(i, ...);
		local value = select(i + 1, ...);
		if (tp == nil) then
			error("GearSelectionWeightTable: type was nil");
		elseif (value == nil) then
			error("GearSelectionWeightTable: for type " .. tp .. " value not provided");
		elseif (t[tp] ~= nil) then
			error("GearSelectionWeightTable: type " .. tp .. " already has a value");
		end
		t[tp] = value;
		n = n + 1;
	end
	t.n = n;
	return t;
end

--[[*****************************************************
	- Builds a GearSelectionInfo table used by
	AI_SpecGenerateGear() function.
	- arm: weight for armor on armor. Does nothing for
	weapons.
	- dmg: weight for damage on weapons. Does nothing
	for armor.
	- stats: weight table for stats. Valid stats are
	defined in ItemStat table in ai_define.lua. Use
	GearSelectionWeightTable to create a suitable table.
	- auras: weight table for auras. Only
	AURA_MOD_DAMAGE_DONE is fully supported.
	Use	GearSelectionWeightTable to create a suitable
	table.
	- spellSchoolMask: spell school mask for filtering
	damage auras. Use values from SpellSchoolMask
	defined in ai_define.lua.
*******************************************************]]
function GearSelectionInfo(arm, dmg, stats, auras, spellSchoolMask)
	return {ArmorWeight = arm, DamageWeight = dmg, StatWeights = stats, AuraWeights = auras, SpellSchools = spellSchoolMask};
end

-- Holds all specs
t_agentSpecs = {};

-- Druid general info
t_agentSpecs[CLASS_DRUID] = {
	ArmorType = {"Cloth", "Leather"},
	WeaponType = {"Mace", "Mace2H", "Staff", "Fist", "Dagger"},
};

-- Balance druid dps spec for leveling PI.
t_agentSpecs[CLASS_DRUID].BalanceLvlDps = {
	BattleGoalID = GOAL_DruidBalanceLevelDps_Battle,
	TalentInfo = "t_LevelBalanceDruidDpsSpec",
};

-- Feral druid dps spec for leveling PI.
t_agentSpecs[CLASS_DRUID].FeralLvlDps = {
	BattleGoalID = GOAL_DruidFeralLevelDps_Battle,
	TalentInfo = "t_LevelFeralDruidDpsSpec",
	-- Copy = true,
};

-- Tank druid spec for leveling PI.
t_agentSpecs[CLASS_DRUID].LvlTank = {
	BattleGoalID = GOAL_DruidLevelTank_Battle,
};

--[[*****************************************************
	MAGE
*******************************************************]]

-- Mage general info
t_agentSpecs[CLASS_MAGE] = {};
t_agentSpecs[CLASS_MAGE].LvlDps = {
	BattleGoalID = GOAL_MageLevelDps_Battle,
	TalentInfo = "t_LevelMageDpsSpec",
};

--[[*****************************************************
	PRIEST
*******************************************************]]

-- Priest general info
t_agentSpecs[CLASS_PRIEST] = {};
t_agentSpecs[CLASS_PRIEST].LvlHeal = {
	BattleGoalID = GOAL_PriestLevelHeal_Battle,
	TalentInfo = "t_LevelPriestHealerSpec",
};

--[[*****************************************************
	SHAMAN
*******************************************************]]

-- Shaman general info
t_agentSpecs[CLASS_SHAMAN] = {};
t_agentSpecs[CLASS_SHAMAN].LvlDps = {
	BattleGoalID = GOAL_ShamanLevelDps_Battle,
	TalentInfo = "t_LevelShamanDpsSpec",
};

--[[*****************************************************
	ROGUE
*******************************************************]]

-- Rogue general info
t_agentSpecs[CLASS_ROGUE] = {};
t_agentSpecs[CLASS_ROGUE].LvlDps = {
	BattleGoalID = GOAL_RogueLevelDps_Battle,
	TalentInfo = "t_LevelRogueDpsSpec",
};

--[[*****************************************************
	WARLOCK
*******************************************************]]

-- Warlock general info
t_agentSpecs[CLASS_WARLOCK] = {};
t_agentSpecs[CLASS_WARLOCK].LvlDps = {
	BattleGoalID = GOAL_WarlockLevelDps_Battle,
	TalentInfo = "t_LevelWarlockDpsSpec",
};

--[[*****************************************************
	WARRIOR
*******************************************************]]

-- Warrior general info
t_agentSpecs[CLASS_WARRIOR] = {
	ArmorType = {"Cloth", "Leather", "Mail"},
	WeaponType = {"Mace", "Mace2H", "Staff", "Fist", "Dagger"},
};
t_agentSpecs[CLASS_WARRIOR].LvlTank = {
	BattleGoalID = GOAL_WarriorLevelTank_Battle,
	TalentInfo = "t_LevelWarriorTankSpec",
};
t_agentSpecs[CLASS_WARRIOR].LvlTankSwapOnly = {
	BattleGoalID = GOAL_WarriorLevelTank_Battle,
	TalentInfo = "t_LevelWarriorTankSpec",
	TankSwapOnly = true,
};
