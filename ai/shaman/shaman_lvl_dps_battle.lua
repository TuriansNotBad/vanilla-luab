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
	data.tstr    = ai:GetSpellMaxRankForMe(SPELL_SHA_STRENGTH_OF_EARTH_TOTEM);
	data.twind   = ai:GetSpellMaxRankForMe(SPELL_SHA_WINDFURY_TOTEM);
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, data.bolt, false, true, 1);
	ai:SetStdThreat(threat);

end

--[[*****************************************************
	Goal update.
*******************************************************]]
function ShamanLevelDps_Update(ai, goal)

	local data = ai:GetData();
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	
	local cmd = ai:CmdType();
	if (cmd == -1 or nil == party) then
		return GOAL_RESULT_Continue;
	end
	local partyData = party:GetData();
	
	if (#partyData.attackers == 0) then
		agent:UnsummonAllTotems();
	end
	
	-- handle commands
	if (cmd == CMD_FOLLOW) then
	
		if (ai:CmdState() == CMD_STATE_WAITING) then
			agent:AttackStop();
			agent:ClearMotion();
			ai:CmdSetInProgress();
			goal:ClearSubGoal();
		end
		
		if (goal:GetSubGoalNum() > 0 or agent:IsNonMeleeSpellCasted()) then
			return GOAL_RESULT_Continue;
		end
		
		AI_Replenish(agent, goal, 90.0, 90.0);
		
		if (goal:GetSubGoalNum() == 0 and agent:GetMotionType() ~= MOTION_FOLLOW) then
			goal:ClearSubGoal();
			agent:ClearMotion();
			local guid, dist, angle = ai:CmdArgs();
			local target = GetPlayerByGuid(guid);
			if (target) then
				agent:MoveFollow(target, dist, angle);
			else
				ai:CmdComplete();
			end
		end
		
	elseif (cmd == CMD_ENGAGE) then
	
		-- do combat!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			print("shaman cmd_engage");
			ai:CmdSetInProgress();
		end
		local partyData = party:GetData();
		local targets = partyData.attackers;
		if (not targets[1]) then
			agent:AttackStop();
			agent:ClearMotion();
			ai:CmdComplete();
			goal:ClearSubGoal();
			return GOAL_RESULT_Continue;
		end
		
		if (false == Tank_AnyTankPulling(partyData.tanks) and targets[1]:IsInCombat() and not ShamanTotems(ai, agent, goal, data, partyData)) then
			return GOAL_RESULT_Continue;
		end
		
		if (goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		
		local target = Dps_GetLowestHpTarget(ai, agent, party, targets, agent:IsInDungeon());
		-- too high threat
		if (not target or not target:IsAlive()) then
			agent:AttackStop();
			agent:ClearMotion();
			agent:InterruptSpell(CURRENT_GENERIC_SPELL);
			agent:InterruptSpell(CURRENT_MELEE_SPELL);
			-- Print("No target for", agent:GetName());
			return GOAL_RESULT_Continue;
		end
		
		if (agent:IsNonMeleeSpellCasted()) then
			return GOAL_RESULT_Continue;
		end
		
		ShamanPotions(agent, goal, data);
		ShamanDpsRotation(ai, agent, goal, data, target);
	
	end

	return GOAL_RESULT_Continue;
	
end

local t_totems = {
	[TOTEM_EARTH] = {
		Strength = {[5874] = true, [5921] = true, [5922] = true, [7403] = true, [15464] = true,},
		Tremor = {[5913] = true,},
	},
	[TOTEM_AIR] = {
		Windfury = {[6112] = true, [7483] = true, [7484] = true,},
	},
};

local function HasTotemType(agent, slot, type)
	local earthEntry = agent:GetTotemEntry(slot);
	return earthEntry ~= nil and t_totems[slot][type][earthEntry] == true;
end

local function GetTotemTarget(agent, partyData)
	local target = partyData.owner;
	if (#partyData.tanks > 0) then
		for i,tank in ipairs(partyData.tanks) do
			if (tank:CmdType() == CMD_TANK) then
				target = tank:GetPlayer();
				break;
			end
		end
	end
	return target, 8.0, 0.0;
end

function ShamanTotems(ai, agent, goal, data, partyData)
	
	if (goal:GetSubGoalNum() > 0) then
		return true;
	end
	
	local level = agent:GetLevel();
	
	-- earth
	if (level >= 18 and true == partyData._needTremor) then
		if (false == HasTotemType(agent, TOTEM_EARTH, "Tremor") and agent:HasEnoughPowerFor(data.ttremor, false)) then
			local target, D, A = GetTotemTarget(agent, partyData);
			goal:AddSubGoal(GOAL_COMMON_Totem, 10.0, target:GetGuid(), data.ttremor, TOTEM_EARTH, D, A);
			return false;
		end
	elseif (level >= 10 and false == HasTotemType(agent, TOTEM_EARTH, "Strength") and agent:HasEnoughPowerFor(data.tstr, false)) then
		
		local target, D, A = GetTotemTarget(agent, partyData);
		goal:AddSubGoal(GOAL_COMMON_Totem, 10.0, target:GetGuid(), data.tstr, TOTEM_EARTH, D, A);
		return false;
	end
	
	-- air
	if (level >= 32) then
		if (false == HasTotemType(agent, TOTEM_AIR, "Windfury") and agent:HasEnoughPowerFor(data.twind, false)) then
			local target, D, A = GetTotemTarget(agent, partyData);
			goal:AddSubGoal(GOAL_COMMON_Totem, 10.0, target:GetGuid(), data.twind, TOTEM_AIR, D, A);
			return false;
		end
	end
	
	return true;
	
end

function ShamanPotions(agent, goal, data)
	
	local mp = agent:GetPowerPct(POWER_MANA);
	-- Mana Potion
	if (data.manapot and goal:IsFinishTimer(ST_POT) and mp < 50 and agent:CastSpell(agent, data.manapot, true) == CAST_OK) then
		print("Mana Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

function ShamanDpsRotation(ai, agent, goal, data, target)

	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	Dps_MeleeChase(ai, agent, target);
	
	local level = agent:GetLevel();
	
	if (target:GetDistance(agent) > 5.0) then
		return false;
	end
	
	-- interrupt
	if (level >= 4
	and target:IsCastingInterruptableSpell()
	and agent:IsSpellReady(data.eshock)
	and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
		goal:AddSubGoal(GOAL_COMMON_CastAlone, 5.0, target:GetGuid(), data.eshock, "Interrupt", 3.0);
		AI_PostBuff(agent:GetGuid(), target:GetGuid(), "Interrupt", true);
		return true;
	end

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
