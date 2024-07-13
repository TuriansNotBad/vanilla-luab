--[[*******************************************************************************************
	List of available goals.
	Keeps all goal ID definitions in one place.
	This file is always loaded before others, along with goal_list.lua and logic_list.lua
*********************************************************************************************]]

--===============================================================
-- Common subgoals
--===============================================================

GOAL_COMMON_MoveInPosToCast =  0;
GOAL_COMMON_FollowCLineRev  =  1;
GOAL_COMMON_Pull            =  2;
GOAL_COMMON_Replenish       =  3;
GOAL_COMMON_Buff            =  4;
GOAL_COMMON_Cc              =  5;
GOAL_COMMON_MoveTo          =  6;
GOAL_COMMON_CastInForm      =  7;
GOAL_COMMON_Shapeshift      =  8;
GOAL_COMMON_DoNothing       =  9;
GOAL_COMMON_CastAlone       = 10;
GOAL_COMMON_Totem           = 11;
GOAL_COMMON_UseObj          = 12;
GOAL_COMMON_UseItemObj      = 13;

--===============================================================
-- Individual top goals
--===============================================================

-- Leveling PI top goals
GOAL_DruidBalanceLevelDps_Battle            = 10000;
GOAL_DruidLevelTank_Battle                  = 10001;
GOAL_WarriorLevelTank_Battle				= 10002;
GOAL_PriestLevelHeal_Battle					= 10003;
GOAL_MageLevelDps_Battle					= 10004;
GOAL_DruidFeralLevelDps_Battle              = 10005;
GOAL_RogueLevelDps_Battle                   = 10006;
GOAL_ShamanLevelDps_Battle                  = 10007;

-- Open World Pvp
GOAL_WARRIOR_OpenWorldPvp = 11000;
