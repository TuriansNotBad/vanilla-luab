--[[*******************************************************************************************
	GOAL_ShamanLevelDps_Battle = 10007
	
	Dps rogue leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_ShamanLevelDps_Battle, "ShamanLevelDps");

local ST_POT = 0;

--[[*****************************************************
	Goal activation.
*******************************************************]]
function ShamanLevelDps_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	ai:SetRole(ROLE_MDPS);
	
	-- learn proficiencies
	-- agent:LearnSpell(Proficiency.Bow);
	
	local gsi = GearSelectionInfo(
		0.0003, 1.5, -- armor, damage
		GearSelectionWeightTable(ItemStat.Intellect, 5, ItemStat.Strength, 2), -- stats
		GearSelectionWeightTable(), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Leather"},
		WeaponType = {"Staff"},
		-- OffhandType = {"Dagger"},
		-- RangedType = {"Bow"},
	};
	AI_SpecGenerateGear(ai, info, gsi, nil, true);
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	-- AI_SpecApplyTalents(ai, level, talentInfo.talents);
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	
	data.bolt    = ai:GetSpellMaxRankForMe(SPELL_SHA_LIGHTNING_BOLT);
	
	-- weapon enhancements
	data.wflame  = ai:GetSpellMaxRankForMe(SPELL_SHA_FLAMETONGUE_WEAPON);
	
	-- shocks
	data.eshock  = ai:GetSpellMaxRankForMe(SPELL_SHA_EARTH_SHOCK);
	
	-- totems
	data.ttremor = ai:GetSpellMaxRankForMe(SPELL_SHA_TREMOR_TOTEM);
	data.tstr    = ai:GetSpellMaxRankForMe(10442);--ai:GetSpellMaxRankForMe(SPELL_SHA_STRENGTH_OF_EARTH_TOTEM);
	data.twind   = ai:GetSpellMaxRankForMe(SPELL_SHA_WINDFURY_TOTEM);
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	
	Movement_Init(data);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(2.0*threat);
	
	-- Command params
	Cmd_EngageSetParams(data, false, 15.0, ShamanThreatActions, ShamanNonThreatActions);
	Cmd_FollowSetParams(data, 90.0, 90.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
	;

end

--[[*****************************************************
	Goal update.
*******************************************************]]
function ShamanLevelDps_Update(ai, goal)

	-- handle commands
	if (not Command_DefaultUpdate(ai, goal)) then
		return GOAL_RESULT_Continue;
	end
	
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	if (#partyData.attackers == 0) then
		agent:UnsummonAllTotems();
	end
	
	return GOAL_RESULT_Continue;
	
end

local t_totems = {
	[TOTEM_EARTH] = {
		Strength = {[5874] = true, [5921] = true, [5922] = true, [7403] = true, [15464] = true,},
		Tremor = {[5913] = true,},
	},
	[TOTEM_WATER] = {
		Poison = {[5923] = true,},
	},
	[TOTEM_AIR] = {
		Windfury = {[6112] = true, [7483] = true, [7484] = true,},
	},
};

local function HasTotemType(agent, slot, type)
	local earthEntry = agent:GetTotemEntry(slot);
	return earthEntry ~= nil and t_totems[slot][type][earthEntry] == true;
end

local function GetTotemTarget(agent, partyData, rchrpos, encTotemPos)
	
	if (encTotemPos) then
		return {x = encTotemPos.x, y = encTotemPos.y, z = encTotemPos.z}, encTotemPos.d, encTotemPos.a;
	end
	
	if (rchrpos and rchrpos.melee == nil) then
		if (agent:IsMoving()) then
			return nil;
		end
		return agent, 0, 0;
	end
	
	local target = partyData.owner;
	if (#partyData.tanks > 0) then
		for i,tank in ipairs(partyData.tanks) do
			if (tank:CmdType() == CMD_TANK) then
				target = tank:GetPlayer();
				break;
			end
		end
	end
	
	if (target:IsMoving()) then
		return nil;
	end
	
	return target, 8.0, 0.0;
	
end

local function ShamanTotemDoTotem(ai, agent, goal, data, partyData, totemSlot, totemType, totemSpell)
	
	local rchrpos = data.rchrpos or (partyData.encounter and partyData.encounter.rchrpos);
	
	if (false == HasTotemType(agent, totemSlot, totemType) and agent:HasEnoughPowerFor(totemSpell, false)) then
		local target, D, A = GetTotemTarget(agent, partyData, rchrpos, partyData.encounter and partyData.encounter.totemPos);
		if (type(target) == "table") then
			goal:AddSubGoal(GOAL_COMMON_TotemXYZ, 10.0, target.x, target.y, target.z, totemSpell, totemSlot, D, A);
		elseif (target) then
			goal:AddSubGoal(GOAL_COMMON_Totem, 10.0, target:GetGuid(), totemSpell, totemSlot, D, A);
		end
		return true;
	end
	return false;
	
end

function ShamanTotems(ai, agent, goal, data, partyData)
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	local level = agent:GetLevel();
	
	-- earth
	if (level >= 18 and true == partyData._needTremor) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_EARTH, "Tremor", data.ttremor)) then
			return;
		end
	elseif (level >= 10) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_EARTH, "Strength", data.tstr)) then
			return;
		end
	end
	
	-- water
	if (level >= 22 and true == partyData._needPoisonCleansing) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_WATER, "Poison", SPELL_SHA_POISON_CLEANSING_TOTEM)) then
			return;
		end
	end
	
	-- air
	if (level >= 32) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_AIR, "Windfury", data.twind)) then
			return;
		end
	end
	
end

function ShamanPotions(agent, goal, data)
	
	local mp = agent:GetPowerPct(POWER_MANA);
	-- Mana Potion
	if (data.manapot and goal:IsFinishTimer(ST_POT) and mp < 50 and agent:CastSpell(agent, data.manapot, true) == CAST_OK) then
		print("Mana Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

function ShamanDpsRotation(ai, agent, goal, data, partyData, target)
	
	local mp = agent:GetPowerPct(POWER_MANA);

	local encounter = partyData.encounter;
	local rchrpos = data.rchrpos or (encounter and encounter.rchrpos);

	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local bRanged = encounter.bestRanged == true;	
	Cmd_EngageSetParams(data, bRanged, 15.0, ShamanThreatActions, ShamanNonThreatActions);
	
	local level = agent:GetLevel();
	
	-- check if we can do melee
	if (not bRanged and false == agent:CanReachWithMelee(target)) then
		if (agent:IsMoving() or (rchrpos and rchrpos.melee == "ignore")) then
			return false;
		end
		-- assume target is outside holding area, must use ranged
		if (CAST_OK == agent:IsInPositionToCast(target, data.bolt, 2.5) and CAST_OK == agent:CastSpell(target, data.bolt, false)) then
			return true;
		end
		return false;
	end
	
	-- check interruptable
	local interruptFilter = encounter and encounter.interruptFilter;
	local interruptCheck;
	if (interruptFilter) then
		interruptCheck = interruptFilter(ai, agent, party, target, partyData.attackers, false, 15.0);
	else
		interruptCheck = target:IsCastingInterruptableSpell();
	end
	-- interrupt
	if (level >= 4
	and interruptCheck
	and agent:IsSpellReady(data.eshock)
	and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
		goal:AddSubGoal(GOAL_COMMON_CastAlone, 5.0, target:GetGuid(), data.eshock, "Interrupt", 3.0);
		AI_PostBuff(agent:GetGuid(), target:GetGuid(), "Interrupt", true);
		return true;
	end
	
	if (bRanged and mp > 30) then
		print(agent:IsInPositionToCast(target, data.bolt, 2.5));
		if (CAST_OK == agent:IsInPositionToCast(target, data.bolt, 2.5) and CAST_OK == agent:CastSpell(target, data.bolt, false)) then
			return true;
		end	
	end
	
end

function ShamanThreatActions(ai, agent, goal, party, data, partyData, target)
	ShamanTotems(ai, agent, goal, data, partyData);
	ShamanPotions(agent, goal, data);
	ShamanDpsRotation(ai, agent, goal, data, partyData, target);
end

function ShamanNonThreatActions(ai, agent, goal, party, data, partyData, target)
	local tank = partyData:GetFirstActiveTank();
	if (not tank or not tank:GetPlayer():IsInCombat()) then
		return;
	end
	ShamanTotems(ai, agent, goal, data, partyData);
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function ShamanLevelDps_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function ShamanLevelDps_Interrupt(ai, goal)

end
