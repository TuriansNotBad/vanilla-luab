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
	agent:LearnSpell(Proficiency.Gun);
	agent:LearnSpell(Proficiency.Sword);
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
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	AI_SpecEquipLoadoutOrRandom(ai, info, gsi, nil, true, Gear_GetLoadoutForLevel60(specTbl.Loadout));
	
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
	
	-- openers
	data.ambush      = ai:GetSpellMaxRankForMe(SPELL_ROG_AMBUSH);
	
	-- util
	data.kick        = ai:GetSpellMaxRankForMe(SPELL_ROG_KICK);
	data.vanish      = ai:GetSpellMaxRankForMe(SPRLL_ROG_VANISH);
	
	data._hasColdBlood   = agent:HasTalent(280, 0);
	data._hasBladeFlurry = agent:HasTalent(223, 0);
	data._hasAdrenaline  = agent:HasTalent(205, 0);
	
	-- consumes
	data.grenade = Consumable_GetExplosive(level);
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_ELIXIR_OF_THE_MONGOOSE, level);
	
	Movement_Init(data);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(threat * 2);
	
	ai:SetAmmo(ITEMID_ROUGH_ARROW);
	
	-- Command params
	Cmd_EngageSetParams(data, false, 10.0, RogueThreatActions);
	Cmd_FollowSetParams(data, 90.0, -1.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
		(CMD_SCRIPT, nil, nil, nil, true)
	;
	-- agent:SetGameMaster(false);
	-- agent:SetGameMaster(true);
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function RogueLevelDps_Update(ai, goal)
	
	-- local agent     = ai:GetPlayer();
	-- local party     = ai:GetPartyIntelligence();
	-- local partyData = party:GetData();
	
	-- local owner = partyData.owner;
	-- if (not owner) then return GOAL_RESULT_Continue; end
	
	-- local target = owner:GetVictim()--or owner;
	-- if (not target) then agent:AttackStop(); agent:ClearMotion(); return GOAL_RESULT_Continue; end
	-- agent:Attack(target);
	-- if (agent:GetMotionType() ~= MOTION_CHASE --[[or ai:GetChaseTarget() ~= target]]) then
		-- agent:ClearMotion();
		
		-- local r = AI_GetDefaultChaseSeparation(target);
		-- Print(r, r/2, target:GetBoundingRadius(), target:GetCombatReach());
		-- agent:MoveChase(target, r, r/2, r/2, math.pi, math.pi/4.0, true, true);
		-- -- agent:MoveChase(target, 1.5, 2.0, 1.5, math.rad(math.random(160, 200)), math.pi/4.0, false, true);
	-- end
	-- target:SetHealthPct(100)
	
	-- if true then return GOAL_RESULT_Continue; end
	
	-- handle commands
	Command_DefaultUpdate(ai, goal);
	
	return GOAL_RESULT_Continue;
	
end

function RogueThreatActions(ai, agent, goal, party, data, partyData, target)
	RoguePotions(agent, goal, data, Data_GetDefensePotion(data, partyData.encounter));
	RogueDpsRotation(ai, agent, goal, data, partyData, target);
end

function RoguePotions(agent, goal, data, defensePot)
	
	if (defensePot and false == agent:HasAura(defensePot)) then
		if (goal:IsFinishTimer(ST_POT) and agent:CastSpell(agent, defensePot, true) == CAST_OK) then
			print("Defense Potion", GetSpellName(defensePot), agent:GetName());
			goal:SetTimer(ST_POT, 120);
		end
		return;
	end
	
	local energy = agent:GetPowerPct(POWER_ENERGY);
	-- Rage Potion
	if (agent:GetLevel() >= 5 and goal:IsFinishTimer(ST_POT) and energy < 30 and agent:CastSpell(agent, SPELL_ROG_THISTLE_TEA, true) == CAST_OK) then
		print("Thistle tea", agent:GetName());
		goal:SetTimer(ST_POT, 300);
	end
	
end

function RogueDpsRotation(ai, agent, goal, data, partyData, target)
	
	local encounter = partyData.encounter;
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local targets = Data_GetAttackers(data, partyData);
	local level = agent:GetLevel();
	local cp = agent:GetComboPoints();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	-- check if we can do melee
	if (false == agent:CanReachWithMelee(target)) then
		if (agent:IsMoving()) then
			return false;
		end
		-- assume target is outside holding area, must use ranged
		if (CAST_OK == agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 2.5) and CAST_OK == agent:CastSpell(target, SPELL_GEN_SHOOT_BOW, false)) then
			return true;
		end
		return false;
	end
	
	-- use ambush if can
	if (level >= 18 and agent:HasAuraType(AURA_MOD_STEALTH)) then
		if (agent:CastSpell(target, data.ambush, true) == CAST_OK) then
			print("Ambush", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	if (data.attackmode == "aoe") then
		if (Unit_AECheck(agent, 4.0, 3, false, targets)) then
			AI_UseGrenade(agent, goal, target, data.grenade, 60);
		end
	end
	
	-- check interruptable
	local interruptFilter = encounter and encounter.interruptFilter;
	local interruptCheck;
	if (interruptFilter) then
		interruptCheck = interruptFilter(ai, agent, party, target, partyData.attackers, false, 10.0);
	else
		interruptCheck = target:IsCastingInterruptableSpell();
	end
	if (level >= 12
	and agent:IsSpellReady(data.kick)
	and interruptCheck
	and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
		goal:AddSubGoal(GOAL_COMMON_CastAlone, 5.0, target:GetGuid(), data.kick, "Interrupt", 0.0);
		AI_PostBuff(agent:GetGuid(), target:GetGuid(), "Interrupt", true);
		return true;
	end
	
	local _,tankThreat = target:GetHighestThreat();
	local myThreat = target:GetThreat(agent);
	local threatDiff = tankThreat - myThreat;
	local canIgnoreThreat = not encounter and true or encounter.noboss;
	if (threatDiff >= 1500 or canIgnoreThreat) then
	
		if (15000 < agent:GetAuraTimeLeft(data.sndice)) then
		
			if (data._hasBladeFlurry and false == agent:HasAura(SPELL_ROG_BLADE_FLURRY)) then
				local bShouldBF = encounter ~= nil or Unit_AECheck(agent, 5.0, 2, false, partyData.attackers);
				if (bShouldBF and agent:CastSpell(agent, SPELL_ROG_BLADE_FLURRY, false) == CAST_OK) then
					print("Blade Flurry", agent:GetName());
					-- return true;
				end
			end
			
			if (Dps_DoRacialDmgCd(agent)) then
				-- return true;
			end
			
			if (data._hasAdrenaline and false == agent:HasAura(SPELL_ROG_ADRENALINE_RUSH)) then
				if (agent:CastSpell(agent, SPELL_ROG_ADRENALINE_RUSH, false) == CAST_OK) then
					print("Adrenaline Rush", agent:GetName());
					-- return true;
				end
			end
			
		end
		
	end
	
	-- vanish
	if (level >= 22 and threatDiff < 1000 and myThreat > 3000) then
		if (agent:CastSpell(agent, data.vanish, false) == CAST_OK) then
			print("Vanish", agent:GetName(), threatDiff, myThreat);
			return true;
		end
	end
	
	if (cp > 0 and level >= 10 and 1000 >= agent:GetAuraTimeLeft(data.sndice)) then
		if (agent:CastSpell(target, data.sndice, false) == CAST_OK) then
			print("Slice and Dice", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	-- Finisher
	if (cp == 5) then
		if (false == agent:HasAura(SPELL_ROG_COLD_BLOOD)) then
		
			if (data._hasColdBlood and Dps_IsRacialDmgCdActive(agent, true) and agent:CastSpell(agent, SPELL_ROG_COLD_BLOOD, false) == CAST_OK) then
				print("Cold Blood", agent:GetName());
				return true;
			end
			
		end
		if (agent:CastSpell(target, data.eviscerate, false) == CAST_OK) then
			print("Eviscerate", agent:GetName(), target:GetName());
			return true;
		end
		return false;
	end
	
	if (level >= 4 and not target:HasInArc(agent, math.pi)) then
		-- backstab, must be behind
		if (agent:CastSpell(target, data.backstab, false) == CAST_OK) then
			print("Backstab", agent:GetName(), target:GetName());
			return true;
		end
	else
		-- strike
		if (agent:CastSpell(target, data.sstrike, false) == CAST_OK) then
			print("Sinister Strike", agent:GetName(), target:GetName());
			return true;
		end
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
