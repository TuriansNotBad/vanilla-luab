--[[*******************************************************************************************
	GOAL_RogueLevelDpsDps_Battle = 10006
	
	Dps rogue leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_RogueLevelDps_Battle, "RogueLevelDps");

local ST_POT = 0;
local function print()end
--[[*****************************************************
	Goal activation.
*******************************************************]]
function RogueLevelDps_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	ai:SetRole(ROLE_MDPS);
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Bow);
	if (level >= 10) then
		agent:LearnSpell(Proficiency.DualWield);
	end
	
	local gsi = GearSelectionInfo(
		0.0003, 5, -- armor, damage
		GearSelectionWeightTable(ItemStat.Agility, 5, ItemStat.Strength, 4), -- stats
		GearSelectionWeightTable(), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Leather"},
		WeaponType = {"Dagger", DualWield = level >= 10},
		OffhandType = {"Dagger"},
		RangedType = {"Bow"},
	};
	AI_SpecGenerateGear(ai, info, gsi, nil, true);
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	
	-- combos
	data.sstrike     = ai:GetSpellMaxRankForMe(SPELL_ROG_SINISTER_STRIKE);
	data.backstab    = ai:GetSpellMaxRankForMe(SPELL_ROG_BACKSTAB);
	data.eviscerate  = ai:GetSpellMaxRankForMe(SPELL_ROG_EVISCERATE);
	data.sndice      = ai:GetSpellMaxRankForMe(SPELL_ROG_SLICE_AND_DICE);
	data.exposearmor = ai:GetSpellMaxRankForMe(SPELL_ROG_EXPOSE_ARMOR);
	
	-- util
	data.kick        = ai:GetSpellMaxRankForMe(SPELL_ROG_KICK);
	
	data._hasColdBlood = false;
	data._hasBladeFlurry = false;
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(2.0*threat);

end

--[[*****************************************************
	Goal update.
*******************************************************]]
function RogueLevelDps_Update(ai, goal)

	local data = ai:GetData();
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	
	local cmd = ai:CmdType();
	if (cmd == CMD_NONE or nil == party) then
		return GOAL_RESULT_Continue;
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
		
		AI_Replenish(agent, goal, 90.0, 0);
		
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
			print("rogue cmd_engage");
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
		
		if (goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		
		-- local target = Dps_GetLowestHpTarget(ai, agent, party, targets, agent:IsInDungeon());
		local target = Dps_GetFirstInterruptOrLowestHpTarget(ai, agent, party, targets, true, 10.0);
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
		
		-- Potions
		RoguePotions(agent, goal, data);
		RogueDpsRotation(ai, agent, goal, ai:GetData(), target);
	
	end

	return GOAL_RESULT_Continue;
	
end

function RoguePotions(agent, goal, data)
	
	local energy = agent:GetPowerPct(POWER_ENERGY);
	-- Rage Potion
	if (agent:GetLevel() >= 5 and goal:IsFinishTimer(ST_POT) and energy < 30 and agent:CastSpell(agent, SPELL_ROG_THISTLE_TEA, true) == CAST_OK) then
		print("Thistle tea", agent:GetName());
		goal:SetTimer(ST_POT, 300);
	end
	
end

function RogueDpsRotation(ai, agent, goal, data, target)

	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	Dps_MeleeChase(ai, agent, target);
	
	local level = agent:GetLevel();
	local cp = agent:GetComboPoints();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	if (target:GetDistance(agent) > 5.0) then
		return false;
	end
	
	if (level >= 12
	and agent:IsSpellReady(data.kick)
	and target:IsCastingInterruptableSpell()
	and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
		goal:AddSubGoal(GOAL_COMMON_CastAlone, 5.0, target:GetGuid(), data.kick, "Interrupt", 0.0);
		AI_PostBuff(agent:GetGuid(), target:GetGuid(), "Interrupt", true);
		return true;
	end
	
	if (cp > 2 and data._hasBladeFlurry and false == agent:HasAura(SPELL_ROG_BLADE_FLURRY) and 15000 < agent:GetAuraTimeLeft(data.sndice)) then
		if (Unit_AECheck(agent, 5.0, 2, false, partyData.attackers) and agent:CastSpell(target, SPELL_ROG_BLADE_FLURRY, false) == CAST_OK) then
			print("Blade Flurry", agent:GetName());
			return true;
		end
	end
	
	-- Finisher
	if (cp == 5) then
		if (false == agent:HasAura(SPELL_ROG_COLD_BLOOD)) then
		
			if (data._hasColdBlood and agent:CastSpell(target, SPELL_ROG_COLD_BLOOD, false) == CAST_OK) then
				print("Cold Blood", agent:GetName());
				return true;
			end
			
			if (level >= 10 and 1000 >= agent:GetAuraTimeLeft(data.sndice) and agent:CastSpell(target, data.sndice, false) == CAST_OK) then
				print("Slice and Dice", agent:GetName(), target:GetName());
				return true;
			end
			
		end
		if (agent:CastSpell(target, data.eviscerate, false) == CAST_OK) then
			print("Eviscerate", agent:GetName(), target:GetName());
			return true;
		end
		return false;
	end
	
	-- backstab, must be behind
	if (level >= 4 and agent:CastSpell(target, data.backstab, false) == CAST_OK) then
		print("Backstab", agent:GetName(), target:GetName());
		return true;
	end
	
	-- strike
	if (agent:CastSpell(target, data.sstrike, false) == CAST_OK) then
		print("Sinister Strike", agent:GetName(), target:GetName());
		return true;
	end

end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function RogueLevelDps_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function RogueLevelDps_Interrupt(ai, goal)

end
