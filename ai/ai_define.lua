--[[*******************************************************************************************
	AI Constants.
	Must be kept in sync with enums in the cpp.
	This file is always loaded before others; along with goal_list.lua and logic_list.lua
*********************************************************************************************]]

-- for debug
__Mgr_Disable_Agent_Save = true;

t_dungeons = {};

-- Goal execution result
GOAL_RESULT_Continue = 0;
GOAL_RESULT_Success = 1;
GOAL_RESULT_Failed = 2;

-- Commands
CMD_STATE_WAITING = 0;
CMD_NONE   = 0;
CMD_MOVE   = 1;
CMD_FOLLOW = 2;
CMD_ENGAGE = 3;
CMD_TANK   = 4;
CMD_HEAL   = 5;
CMD_PULL   = 6;
CMD_CC     = 7;
CMD_BUFF   = 8;
CMD_DISPEL = 9;
CMD_SCRIPT = 10;

-- Teams
TEAM_HORDE    = 67;
TEAM_ALLIANCE = 469;

-- Roles
ROLE_MDPS   = 1;
ROLE_RDPS   = 2;
ROLE_TANK   = 3;
ROLE_HEALER = 4;
ROLE_SCRIPT = 5;

-- Races
RACE_HUMAN              = 1;
RACE_ORC                = 2;
RACE_DWARF              = 3;
RACE_NIGHTELF           = 4;
RACE_UNDEAD             = 5;
RACE_TAUREN             = 6;
RACE_GNOME              = 7;
RACE_TROLL              = 8;
RACE_GOBLIN             = 9;

-- Classes
CLASS_WARRIOR       = 1;
CLASS_PALADIN       = 2;
CLASS_HUNTER        = 3;
CLASS_ROGUE         = 4;
CLASS_PRIEST        = 5;
CLASS_SHAMAN        = 7;
CLASS_MAGE          = 8;
CLASS_WARLOCK       = 9;
CLASS_DRUID         = 11;

-- Stand state
STAND_STATE_STAND = 0;

-- Motion types
MOTION_IDLE                = 0;                    -- IdleMovementGenerator.h
MOTION_RANDOM              = 1;                    -- RandomMovementGenerator.h
MOTION_WAYPOINT            = 2;                    -- WaypointMovementGenerator.h
MOTION_CYCLIC              = 3;                    -- CyclicMovementGenerator.h
MOTION_CONFUSED            = 5;                    -- ConfusedMovementGenerator.h
MOTION_CHASE               = 6;                    -- TargetedMovementGenerator.h
MOTION_HOME                = 7;                    -- HomeMovementGenerator.h
MOTION_FLIGHT              = 8;                    -- WaypointMovementGenerator.h
MOTION_POINT               = 9;                    -- PointMovementGenerator.h
MOTION_FLEEING             = 10;                   -- FleeingMovementGenerator.h
MOTION_DISTRACT            = 11;                   -- IdleMovementGenerator.h
MOTION_ASSISTANCE          = 12;                   -- PointMovementGenerator.h (first part of flee for assistance)
MOTION_ASSISTANCE_DISTRACT = 13;                   -- IdleMovementGenerator.h (second part of flee for assistance)
MOTION_TIMED_FLEEING       = 14;                   -- FleeingMovementGenerator.h (alt.second part of flee for assistance)
MOTION_FOLLOW              = 15;                   -- TargetedMovementGenerator.h
MOTION_EFFECT              = 16;
MOTION_PATROL              = 17;
MOTION_CHARGE              = 18;
MOTION_DISTANCING          = 19;

-- Power types
POWER_MANA                          = 0;            -- UNIT_FIELD_POWER1
POWER_RAGE                          = 1;            -- UNIT_FIELD_POWER2
POWER_FOCUS                         = 2;            -- UNIT_FIELD_POWER3
POWER_ENERGY                        = 3;            -- UNIT_FIELD_POWER4
POWER_HAPPINESS                     = 4;            -- UNIT_FIELD_POWER5

-- Shapeshift Forms
FORM_NONE               = 0x00;
FORM_CAT                = 0x01;
FORM_TREE               = 0x02;
FORM_TRAVEL             = 0x03;
FORM_AQUA               = 0x04;
FORM_BEAR               = 0x05;
FORM_AMBIENT            = 0x06;
FORM_GHOUL              = 0x07;
FORM_DIREBEAR           = 0x08;
FORM_CREATUREBEAR       = 0x0E;
FORM_CREATURECAT        = 0x0F;
FORM_GHOSTWOLF          = 0x10;
FORM_BATTLESTANCE       = 0x11;
FORM_DEFENSIVESTANCE    = 0x12;
FORM_BERSERKERSTANCE    = 0x13;
FORM_SHADOW             = 0x1C;
FORM_STEALTH            = 0x1E;
FORM_MOONKIN            = 0x1F;
FORM_SPIRITOFREDEMPTION = 0x20;

-- Totems
TOTEM_FIRE   = 0;
TOTEM_EARTH  = 1;
TOTEM_WATER  = 2;
TOTEM_AIR    = 3;

-- Generic Spell IDs
SPELL_GEN_SHOOT_BOW   = 2480;
SPELL_GEN_PUMMELER    = 13494;

-- Spell Aura
AURA_MOD_CONFUSE              = 5;
AURA_MOD_CHARM                = 6;
AURA_MOD_FEAR                 = 7;
AURA_MOD_TAUNT                = 11;
AURA_MOD_STUN                 = 12;
AURA_MOD_DAMAGE_DONE          = 13;
AURA_MOD_SHAPESHIFT           = 36;
AURA_MOD_HEALING_DONE         = 135;
AURA_MOD_HEALING_DONE_PERCENT = 136;

-- Spell Mechanics
MECHANIC_CHARM =  1;
MECHANIC_FEAR  =  5;
MECHANIC_SLEEP = 10;

-- Spell Cast Result
CAST_OK = 255;
-- these are defined in C++
-- CAST_NOTHING_TO_DISPEL
-- CAST_NOT_SHAPESHIFT
-- CAST_ONLY_SHAPESHIFT

-- Current Spell Types
CURRENT_MELEE_SPELL             = 0;
CURRENT_GENERIC_SPELL           = 1;
CURRENT_AUTOREPEAT_SPELL        = 2;
CURRENT_CHANNELED_SPELL         = 3;

-- Spell School Mask
SpellSchoolMask = {
	Nature = 8,
	Frost  = 16,
	Arcane = 64,
};

-- Equipment slots
EquipSlot = {
	MainHand     = 15,
	OffHand      = 16,
	Null         = 255,
};

-- Item class
ItemClass = {
	Consumable                       = 0,
	Container                        = 1,
	Weapon                           = 2,
	Gem                              = 3,
	Armor                            = 4,
	Reagent                          = 5,
	Projectile                       = 6,
	TradeGoods                       = 7,
	Generic                          = 8,
	Recipe                           = 9,
	Money                            = 10,
	Quiver                           = 11,
	Quest                            = 12,
	Key                              = 13,
	Permanent                        = 14,
	Junk                             = 15,
};

-- Item subclass
ItemSubclass = {
	-- Armor
	ArmorMisc                    = 0,
	ArmorCloth                   = 1,
	ArmorLeather                 = 2,
	ArmorMail                    = 3,
	ArmorPlate                   = 4,
	ArmorBuckler                 = 5,
	ArmorShield                  = 6,
	ArmorLibram                  = 7,
	ArmorIdol                    = 8,
	ArmorTotem                   = 9,
	-- Weapons
	WeaponAxe                    = 0,
	WeaponAxe2                   = 1,
	WeaponBow                    = 2,
	WeaponGun                    = 3,
	WeaponMace                   = 4,
	WeaponMace2                  = 5,
	WeaponPolearm                = 6,
	WeaponSword                  = 7,
	WeaponSword2                 = 8,
	WeaponObsolete               = 9,
	WeaponStaff                  = 10,
	WeaponExotic                 = 11,
	WeaponExotic2                = 12,
	WeaponFist                   = 13,
	WeaponMisc                   = 14,
	WeaponDagger                 = 15,
	WeaponThrown                 = 16,
	WeaponSpear                  = 17,
	WeaponCrossbow               = 18,
	WeaponWand                   = 19,
	WeaponFishingPole            = 20,
};

-- Inventory types
InventoryType = {
	NonEquip                            = 0,
	Head                                = 1,
	Neck                                = 2,
	Shoulders                           = 3,
	Body                                = 4,
	Chest                               = 5,
	Waist                               = 6,
	Legs                                = 7,
	Feet                                = 8,
	Wrists                              = 9,
	Hands                               = 10,
	Finger                              = 11,
	Trinket                             = 12,
	Weapon                              = 13,
	Shield                              = 14,
	Ranged                              = 15,
	Cloak                               = 16,
	Weapon2H                            = 17,
	Bag                                 = 18,
	Tabard                              = 19,
	Robe                                = 20,
	WeaponMainHand                      = 21,
	WeaponOffHand                       = 22,
	Holdable                            = 23,
	Ammo                                = 24,
	Thrown                              = 25,
	RangedRight                         = 26,
	Quiver                              = 27,
	Relic                               = 28,
};

-- Item stats
ItemStat = {
	Mana                     = 0,
	Health                   = 1,
	Agility                  = 3,
	Strength                 = 4,
	Intellect                = 5,
	Spirit                   = 6,
	Stamina                  = 7,
};

ITEMID_MANUAL_CROWD_PUMMELER = 9449;
-- ammo
ITEMID_ROUGH_ARROW = 2512;

Proficiency = {
	Axe2H     = 197,
	Bow       = 264,
	Dagger    = 1180,
	Fist      = 15590,
	Mace      = 198,
	Mace2H    = 199,
	Staff     = 227,
	Sword     = 201,
	Sword2H   = 202,
	DualWield = 674,
};

-- reputation
REP_HATED       = 0;
REP_HOSTILE     = 1;
REP_UNFRIENDLY  = 2;
REP_NEUTRAL     = 3;
REP_FRIENDLY    = 4;
REP_HONORED     = 5;
REP_REVERED     = 6;
REP_EXALTED     = 7;

-- CMD Name Lookup
CMD2STR = {
	[CMD_NONE  ] = "CMD_NONE",
	[CMD_MOVE  ] = "CMD_MOVE",
	[CMD_FOLLOW] = "CMD_FOLLOW",
	[CMD_ENGAGE] = "CMD_ENGAGE",
	[CMD_TANK  ] = "CMD_TANK",
	[CMD_HEAL  ] = "CMD_HEAL",
	[CMD_PULL  ] = "CMD_PULL",
	[CMD_CC    ] = "CMD_CC",
	[CMD_BUFF  ] = "CMD_BUFF",
	[CMD_DISPEL] = "CMD_DISPEL",
	[CMD_SCRIPT] = "CMD_SCRIPT",
}

-- Client build numbers
Builds = {
	["1.1.2"]  = 4125,
	["1.2.4"]  = 4222,
	["1.3.1"]  = 4297,
	["1.4.2"]  = 4375,
	["1.5.1"]  = 4449,
	["1.6.1"]  = 4544,
	["1.7.1"]  = 4695,
	["1.8.4"]  = 4878,
	["1.9.4"]  = 5086,
	["1.10.2"] = 5302,
	["1.11.2"] = 5464,
	["1.12.1"] = 5875,
	Spell = function(key, id1, id2)
		return CVER <= Builds[key] and id1 or id2;
	end,
	Select = function(target, key, id1, f, c)
		return CVER >= Builds[key] and f(target, id1, c) or false;
	end,
};

function Mask(value)
	return 1 << (value - 1);
end
