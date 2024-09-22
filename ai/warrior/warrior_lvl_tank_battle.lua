--[[*******************************************************************************************
	GOAL_WarriorLevelTank_Battle = 10001
	
	Tank warrior leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_WarriorLevelTank_Battle, "WarriorLevelTank");

local ST_BOMB = 0; -- dynamite cooldown
local ST_SAPP = 1; -- goblin sapper charge cooldown
local ST_POT  = 2; -- potion cooldown
local ST_TAUNT= 3; -- taunt cooldown
local SN_JUSTTAUNTED = 4;


local function GetForms()
	return {
		[FORM_CAT]  = SPELL_DRD_CAT_FORM,
		[FORM_BEAR] = SPELL_DRD_BEAR_FORM,
	};
end

local function WarriorIncapacitatedUpdate(ai, agent, goal, party, data, partyData)
	if (agent:GetLevel() >= 32 and agent:HasAuraType(AURA_MOD_FEAR) and agent:GetShapeshiftForm() == FORM_BERSERKERSTANCE) then
		if (agent:CastSpell(agent, SPELL_WAR_BERSERKER_RAGE, false) == CAST_OK) then
			print("Berserker Rage", agent:GetName());
			return true;
		end
	end
end

local function WarriorUpdateStance(data, ai, agent, goal)
	
	local form = ai:GetForm();
	if (form == agent:GetShapeshiftForm() or agent:GetStandState() ~= STAND_STATE_STAND or agent:IsNonMeleeSpellCasted()) then
		return;
	end
	
	if (agent:GetShapeshiftForm() ~= FORM_NONE and agent:GetShapeshiftForm() ~= form) then
		agent:CancelAura(GetSpellForForm(agent:GetShapeshiftForm()));
		return;
	end
	
	if (form ~= FORM_NONE) then
		agent:CastSpell(agent, GetSpellForForm(form), false);
	end

end

local function WarriorTankShapeshift(ai, agent, level)
	if (level >= 10) then
		if (ai:GetData().attackmode == "fury" and level >= 30) then
			ai:SetForm(FORM_BERSERKERSTANCE);
		else
			ai:SetForm(FORM_DEFENSIVESTANCE);
		end
	elseif (FORM_BATTLESTANCE ~= agent:GetShapeshiftForm()) then
		ai:SetForm(FORM_BATTLESTANCE);
	end
end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function WarriorLevelTank_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Bow);
	agent:LearnSpell(Proficiency.Crossbow);
	agent:LearnSpell(Proficiency.Plate);
	
	local gsi = GearSelectionInfo(
		0.1, 1.5, -- armor, damage
		GearSelectionWeightTable(ItemStat.Stamina, 5, ItemStat.Strength, 3, ItemStat.Agility, 1.5), -- stats
		GearSelectionWeightTable(), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Mail"},
		WeaponType = {"Mace", "Fist", "Dagger", "Axe", "Sword"},
		OffhandType = {"Shield"},
		RangedType = {"Bow"},
	};
	local race = agent:GetRace();
	if (race == RACE_ORC) then
		info.WeaponType = {"Axe"};
	elseif (race == RACE_HUMAN) then
		info.WeaponType = {"Sword"};
	end
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	AI_SpecEquipLoadoutOrRandom(ai, info, gsi, nil, true, Gear_GetLoadoutForLevel60(specTbl.Loadout));
	AI_SpecSetAmmo(ai, ITEMID_ROUGH_ARROW);
	
	ai:SetRole(ROLE_TANK);
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	
	AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	data.sunder  = ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR);
	data.heroic  = ai:GetSpellMaxRankForMe(SPELL_WAR_HEROIC_STRIKE);
	data.revenge = ai:GetSpellMaxRankForMe(SPELL_WAR_REVENGE);
	data.bash    = ai:GetSpellMaxRankForMe(SPELL_WAR_SHIELD_BASH);
	data.sslam   = Builds.Select(ai, "1.6.1", SPELL_WAR_SHIELD_SLAM, ai.GetSpellMaxRankForMe);
	data.mock    = ai:GetSpellMaxRankForMe(SPELL_WAR_MOCKING_BLOW);
	
	data.dshout  = ai:GetSpellMaxRankForMe(SPELL_WAR_DEMORALIZING_SHOUT);
	
	-- consumes
	data.grenade = Consumable_GetExplosive(level);
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.ragepot = Consumable_GetRagePotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_FLASK_OF_THE_TITANS, level);
	
	-- dps
	data.charge			= ai:GetSpellMaxRankForMe(SPELL_WAR_CHARGE);
	data.rend			= ai:GetSpellMaxRankForMe(SPELL_WAR_REND);
	data.execute		= ai:GetSpellMaxRankForMe(SPELL_WAR_EXECUTE);
	data.overpower 		= ai:GetSpellMaxRankForMe(SPELL_WAR_OVERPOWER);
	data.cleave         = ai:GetSpellMaxRankForMe(SPELL_WAR_CLEAVE);
	
	-- talents
	data._hasShieldSlam = Builds.Select(agent, "1.6.1", 148, agent.HasTalent, 0);
	data._hasLastStand  = agent:HasTalent(153, 0);
	data._hasTacticalMs = agent:HasTalent(641, 1) or agent:HasTalent(641, 2) or agent:HasTalent(641, 3) or agent:HasTalent(641, 4);
	
	data.UpdateShapeshift    = WarriorUpdateStance;
	data.IncapacitatedUpdate = WarriorIncapacitatedUpdate;
	
	Movement_Init(data);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, data.sunder, false, true);;
	if (false == agent:HasAura(SPELL_WAR_DEFENSIVE_STANCE)) then
		threat = threat * 1.3;
	end
	ai:SetStdThreat(threat);
	Print("Tank std threat, x2", ai:GetStdThreat(), ai:GetStdThreat() * 2);
	
	data.PullRotation = WarriorPullRotation;
	
	-- Command params
	Cmd_FollowSetParams(data, 90.0, -1.0);
	-- Register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, WarriorLevelTank_CmdEngageUpdate, nil, true)
		(CMD_PULL,   nil, nil, nil, true)
		(CMD_TANK,   WarriorLevelTank_CmdTankOnBegin, WarriorLevelTank_CmdTankUpdate, WarriorLevelTank_CmdTankOnEnd, true)
		(CMD_SCRIPT, nil, nil, nil, true)
	;
	
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function WarriorLevelTank_Update(ai, goal)
	
	-- handle commands
	if (not Command_DefaultUpdate(ai, goal)) then
		return GOAL_RESULT_Continue;
	end
	
	if (ai:CmdType() == CMD_FOLLOW) then		
		local agent = ai:GetPlayer();
		WarriorTankShapeshift(ai, agent, agent:GetLevel());
	end
	
	return GOAL_RESULT_Continue;
	
end

function WarriorLevelTank_CmdEngageUpdate(ai, agent, goal, party, data, partyData)
	-- do combat!
	-- party has no attackers
	local targets = Data_GetAttackers(data, partyData);
	if (not targets[1]) then
		agent:AttackStop();
		agent:ClearMotion();
		Command_Complete(ai, "CMD_ENGAGE no targets left");
		goal:ClearSubGoal();
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	local target;
	local bAllowThreatActions = true; 
	
	if (partyData.hostileTotems) then
		target = Dps_GetNearestTarget(agent, partyData.hostileTotems);
	end
	
	if (nil == target) then
		local bThreatCheck = agent:IsInDungeon() and partyData:HasTank() and not targets.ignoreThreat;
		target = Tank_GetLowestHpTarget(ai, agent, party, targets, bThreatCheck, ai:GetStdThreat());
		bAllowThreatActions = target ~= nil;
	end
	
	-- use tank's target if threat is too high
	if (nil == target) then
		local _,tank = partyData:GetFirstActiveTank();
		if (tank and tank:IsInCombat()) then
			target = tank:GetVictim();
		end
	end
	
	-- still nothing
	if (nil == target or not target:IsAlive()) then
		agent:AttackStop();
		agent:ClearMotion();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
		agent:InterruptSpell(CURRENT_MELEE_SPELL);
		-- Print("No target for", agent:GetName());
		return;
	end
	
	if (agent:IsNonMeleeSpellCasted()) then
		return;
	end
	
	-- movement
	Movement_Process(ai, goal, party, target, false, bAllowThreatActions);
	
	-- attacks
	if (bAllowThreatActions) then
		if (bSwap) then
			WarriorTankMaintainThreatRotation(ai, agent, goal, data, partyData, target);
		else
			WarriorTankDpsRotation(ai, agent, goal, data, partyData, target);
		end
	else
		agent:AttackStop();
	end
	
end

function WarriorLevelTank_CmdTankOnBegin(ai, agent, goal, party, data, partyData)
	goal:ClearSubGoal();
	agent:ClearMotion();
	ai:UnsetAbsAngle();
	data.tankrot = nil;
end

function WarriorLevelTank_CmdTankOnEnd(ai)
	ai:GetPlayer():AttackStop();
	ai:GetPlayer():ClearMotion();
	ai:UnsetAbsAngle();
end

function WarriorLevelTank_CmdTankUpdate(ai, agent, goal, party, data, partyData)
	-- do tank!
	local guid = ai:CmdArgs();
	local target = GetUnitByGuid(agent, guid);
	local encounter = partyData.encounter;
	
	-- target expired
	if (nil == target or false == target:IsAlive() or party:IsCC(target)) then
		Command_Complete(ai, "CMD_TANK complete");
		Print(agent:GetName(), "CMD_TANK complete.", type(target), target and not target:IsAlive(), target and party:IsCC(target), #partyData.attackers);
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	-- changing target
	if (not AI_IsAttackingTarget(agent, target)) then
		if (agent:GetMotionType() == MOTION_CHASE) then
			agent:ClearMotion();
		end
		if (agent:GetVictim() ~= nil) then
			agent:AttackStop();
		end
		agent:Attack(target);
	end
	
	-- move
	Movement_Process(ai, goal, party, target, false, true);

	-- do abilities
	if (WarriorTankRotation(ai, agent, goal, data, partyData, target) and false == ai:CmdIsRequirementMet()) then
		local threat = target:GetThreat(agent);
		if (threat >= ai:CmdGetProgress() - 0.01) then
			ai:CmdSetProgress(threat);
		else
			-- creature uses aggro reducing spells, set complete
			ai:CmdSetProgress(10000000.0);
		end
	end
end

local function WarriorTankPotions(agent, goal, data, partyData)
	
	-- encounter forced potion
	local tankPot = partyData.encounter and partyData.encounter.tankPot
	if (tankPot) then
		if (goal:IsFinishTimer(ST_POT) and agent:CastSpell(agent, tankPot, false) == CAST_OK) then
			Print("Tank Encounter Potion", agent:GetName(), GetSpellName(tankPot));
			goal:SetTimer(ST_POT, 120);
		end
		return;
	end
	
	-- Rage Potion
	if (data.ragepot and goal:IsFinishTimer(ST_POT) and agent:CastSpell(agent, data.ragepot, false) == CAST_OK) then
		print("Rage Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

local function WarriorTankDoDebuffs(ai, agent, goal, data, partyData, level, target, bRend)
	
	if (partyData.encounter and partyData.encounter.nodebuffs) then
		return false;
	end
	
	-- Demoralizing Shout
	if (level >= 14 and false == target:HasAura(data.dshout) and agent:CastSpell(target, data.dshout, false) == CAST_OK) then
		-- print("Demoralizing Shout", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Rend
	if (bRend and level >= 4 and false == target:HasAura(data.rend) and agent:CastSpell(target, data.rend, false) == CAST_OK) then
		print("Rend", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;

end

function WarriorTankRotation(ai, agent, goal, data, partyData, target)
	
	local level = agent:GetLevel();
	local levelDiff = target:GetLevel() - level;
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	WarriorTankShapeshift(ai, agent, level);
	
	local rage = agent:GetPowerPct(POWER_RAGE);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	if (goal:GetNumber(SN_JUSTTAUNTED) == 1) then
		goal:SetTimer(ST_TAUNT, 0.5);
		goal:SetNumber(SN_JUSTTAUNTED, 0);
	end
	
	if (data.grenade and party and agent:GetDistance(target) < 10.0 and false == target:IsMoving() and false == agent:IsMoving()) then
		
		if (level >= 10 and goal:IsFinishTimer(0) and hp > 50) then
			
			-- sapper charge
			if ((Unit_AECheck(agent, 5.0, 3, false, partyData.attackers) or data.forceBurstThreat)
			and agent:CastSpell(agent, SPELL_GEN_GOBLIN_SAPPER_CHARGE, false) == CAST_OK) then
				print("Goblin Sapper Charge", agent:GetName(), target:GetName());
				goal:SetTimer(0, 300);
				goal:SetTimer(1, 60);
				return true;
			end
			
		elseif (goal:IsFinishTimer(ST_GRENADE)) then
			
			-- throw dynamite
			if ((Unit_AECheck(target, 5.0, 2, false, partyData.attackers) or data.forceBurstThreat)
			and agent:CastSpell(target, data.grenade, false) == CAST_OK) then
				print("Dynamite", agent:GetName(), target:GetName());
				goal:SetTimer(ST_GRENADE, 60);
				return true;
			end
			
		end
	end
	
	-- Potions
	WarriorTankPotions(agent, goal, data, partyData);
	
	-- try to save ourselves
	if (hp < 30 and not agent:HasAura(SPELL_WAR_SHIELD_WALL) and not agent:HasAura(SPELL_WAR_LAST_STAND)) then
		
		if (hp < 15) then
			if (level >= 28 and not agent:IsSpellReady(SPELL_WAR_SHIELD_WALL)) then
				if (agent:CastSpell(agent, SPELL_WAR_SHIELD_WALL, false) == CAST_OK) then
					return true;
				end
			end
			
			if (data._hasLastStand and agent:IsSpellReady(SPELL_WAR_LAST_STAND)) then
				if (agent:CastSpell(agent, SPELL_WAR_LAST_STAND, false) == CAST_OK) then
					return true;
				end
			end
		end
		
		-- Shield Block
		if (level >= 16 and not agent:HasAura(SPELL_WAR_SHIELD_BLOCK) and agent:CastSpell(agent, SPELL_WAR_SHIELD_BLOCK, false) == CAST_OK) then
			-- print("Shield Block", agent:GetName());
			return true;
		end

	end
	
	-- check if we can do melee
	if (false == agent:CanReachWithMelee(target)) then
		local nonTankThreat,tankThreat = target:GetHighestThreat();
		local threatDiff = nonTankThreat - tankThreat;
		if (agent:GetMotionType() ~= MOTION_IDLE --[[or (threatDiff > 25.0 or target:GetDistance(agent) < 10)]]) then
			return false;
		end
		-- assume target is outside holding area, must use ranged
		-- if (CAST_OK == agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 2.5) and CAST_OK == agent:CastSpell(target, SPELL_GEN_SHOOT_BOW, false)) then
			-- return true;
		-- end
		return false;
	end
	
	-- oil of immolation
	if ((levelDiff > 3 or agent:GetAttackersNum() > 3 or (partyData.encounter and #partyData.attackers > 1)) and false == agent:HasAura(11350)) then
		if (Unit_AECCCheck(agent, party, 10, partyData.attackers)) then
			agent:CastSpell(agent, 11350, true);
		end
	end
	
	if (agent:HasAura(11350) and not Unit_AECCCheck(agent, party, 8, partyData.attackers)) then
		agent:CancelAura(11350);
	end
	
	-- crystal spire
	if (levelDiff > 3 and false == agent:HasAura(15279)) then
		agent:CastSpell(agent, 15279, true);
	end
	
	-- bloodrage
	if (level >= 10 and hp > 20 and rage < 40 and false == agent:HasAura(SPELL_WAR_BLOODRAGE)) then
		agent:CastSpell(agent, SPELL_WAR_BLOODRAGE, false);
	end
	
	-- Taunt
	-- Timer for spell batching issues
	if (level >= 10 and goal:IsFinishTimer(ST_TAUNT) and target:GetVictim() and target:GetVictim() ~= agent and not target:HasAuraType(AURA_MOD_TAUNT)) then
	
		if (agent:IsSpellReady(SPELL_WAR_TAUNT)) then
			print("!!!!! Taunt attempt", agent:GetName(), target:GetName());
			goal:AddSubGoal(GOAL_COMMON_CastInForm, 10.0, target:GetGuid(), SPELL_WAR_TAUNT, FORM_DEFENSIVESTANCE, 0.0);
			goal:SetNumber(SN_JUSTTAUNTED, 1);
			return true;
		end
		
		if (level >= 16 and data._hasTacticalMs and rage >= 10 and agent:IsSpellReady(data.mock)) then
			Print("!!!!! Mocking blow attempt");
			goal:AddSubGoal(GOAL_COMMON_CastInForm, 10.0, target:GetGuid(), data.mock, FORM_BATTLESTANCE, 0.0);
			goal:SetNumber(SN_JUSTTAUNTED, 1);
			return true;
		end
		
		if (level >= 26 and agent:IsSpellReady(SPELL_WAR_CHALLENGING_SHOUT)) then
			if (agent:CastSpell(target, SPELL_WAR_CHALLENGING_SHOUT, false) == CAST_OK) then
				print("!!!!! Challenging Shout", agent:GetName(), target:GetName());
				goal:SetNumber(SN_JUSTTAUNTED, 1);
				return true;
			end
		end
	end
	
	if (data.attackmode == "fury") then
		
		if (level >= 32 and agent:HasAuraType(AURA_MOD_FEAR)) then
			if (agent:CastSpell(agent, SPELL_WAR_BERSERKER_RAGE, false) == CAST_OK) then
				print("Berserker Rage", agent:GetName());
				return true;
			end
		end
		
	end
	
	-- Revenge
	if (level >= 14 and agent:CastSpell(target, data.revenge, false) == CAST_OK) then
		-- print("Revenge", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Demo shout
	if (WarriorTankDoDebuffs(ai, agent, goal, data, partyData, level, target, false)) then
		return true;
	end
	
	-- Shield Bash
	if (level >= 12 and agent:CastSpell(target, data.bash, false) == CAST_OK) then
		-- print("Shield Bash", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Sunder
	local shouldSunder = level >= 10 and (target:GetAuraStacks(data.sunder) < 5 or target:GetAuraTimeLeft(data.sunder) < 3000);
	if (shouldSunder and agent:CastSpell(target, data.sunder, false) == CAST_OK) then
		-- print("Sunder Armor", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Shield Slam
	if (data._hasShieldSlam and agent:CastSpell(target, data.sslam, false) == CAST_OK) then
		-- print("Shield Slam", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Strike
	if ((rage > 50 or data.attackmode == "fury") and agent:CastSpell(target, data.heroic, false) == CAST_OK) then
		-- print("Heroic Strike", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
	
end

function WarriorTankMaintainThreatRotation(ai, agent, goal, data, partyData, target)
	
	local level = agent:GetLevel();
	local levelDiff = target:GetLevel() - level;
	
	do
		local _,threat = target:GetHighestThreat();
		-- Print("Maintaining threat", agent:GetName(), target:GetThreat(agent), threat);
			-- Taunt
		if (level >= 10 and threat - target:GetThreat(agent) > 1000 and not target:HasAura(SPELL_WAR_TAUNT)) then
			local result = agent:CastSpell(target, SPELL_WAR_TAUNT, false);
			if (result == CAST_OK) then
				print("Taunt ", agent:GetName(), target:GetName());
				return true;
			end
		end

	end
	
	WarriorTankShapeshift(ai, agent, level);
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local rage = agent:GetPowerPct(POWER_RAGE);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	-- Potions
	WarriorTankPotions(agent, goal, data, partyData);
	
	-- check if we can do melee
	if (false == agent:CanReachWithMelee(target)) then
		if (agent:IsMoving()) then
			return false;
		end
		-- assume target is outside holding area, must use ranged
		-- if (CAST_OK == agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 2.5) and CAST_OK == agent:CastSpell(target, SPELL_GEN_SHOOT_BOW, false)) then
			-- return true;
		-- end
		return false;
	end
	
	-- oil of immolation
	if ((levelDiff > 3 or agent:GetAttackersNum() > 3) and false == agent:HasAura(11350)) then
		if (Unit_AECCCheck(agent, party, 6, partyData.attackers)) then
			agent:CastSpell(agent, 11350, true);
		end
	end
	
	-- bloodrage
	if (level >= 10 and hp > 20 and rage < 40 and false == agent:HasAura(SPELL_WAR_BLOODRAGE)) then
		agent:CastSpell(agent, SPELL_WAR_BLOODRAGE, false);
	end
	
	-- Revenge
	if (level >= 14 and agent:CastSpell(target, data.revenge, false) == CAST_OK) then
		-- print("Revenge", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Demo shout
	if (WarriorTankDoDebuffs(ai, agent, goal, data, partyData, level, target, false)) then
		return true;
	end
	
	-- Shield Bash
	if (level >= 12 and agent:CastSpell(target, data.bash, false) == CAST_OK) then
		-- print("Shield Bash", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Sunder
	local shouldSunder = level >= 10 and (target:GetAuraStacks(data.sunder) < 5 or target:GetAuraTimeLeft(data.sunder) < 3000);
	if (shouldSunder and agent:CastSpell(target, data.sunder, false) == CAST_OK) then
		-- print("Sunder Armor", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Shield Slam
	if (data._hasShieldSlam and agent:CastSpell(target, data.sslam, false) == CAST_OK) then
		-- print("Shield Slam", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Strike
	if (rage > 50 and agent:CastSpell(target, data.heroic, false) == CAST_OK) then
		-- print("Heroic Strike", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
	
end

function WarriorTankDpsRotation(ai, agent, goal, data, partyData, target)
	
	local level = agent:GetLevel();
	
	ai:SetForm(data.attackmode == "aoe" and FORM_BERSERKERSTANCE or FORM_BATTLESTANCE);
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local rage = agent:GetPowerPct(POWER_RAGE);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	-- Potions
	WarriorTankPotions(agent, goal, data, partyData);
	
	-- Charge
	if (level >= 4 and agent:CastSpell(target, data.charge, false) == CAST_OK) then
		print("Charge", agent:GetName(), target:GetName());
		return true;
	end
	
	-- check if we can do melee
	if (false == agent:CanReachWithMelee(target)) then
		if (agent:IsMoving()) then
			return false;
		end
		-- assume target is outside holding area, must use ranged
		-- if (CAST_OK == agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 2.5) and CAST_OK == agent:CastSpell(target, SPELL_GEN_SHOOT_BOW, false)) then
			-- return true;
		-- end
		return false;
	end
	
	-- bloodrage
	if (level >= 10 and hp > 20 and rage < 40 and false == agent:HasAura(SPELL_WAR_BLOODRAGE)) then
		agent:CastSpell(agent, SPELL_WAR_BLOODRAGE, false);
	end
	
	if (data.attackmode == "aoe" and level >= 36) then
		
		local targets = Data_GetAttackers(data, partyData);
		-- throw dynamite
		if (goal:IsFinishTimer(ST_GRENADE) and Unit_AECheck(target, 5.0, 3, false, targets) and agent:CastSpell(target, data.grenade, false) == CAST_OK) then
			Print("Dynamite", agent:GetName(), target:GetName());
			goal:SetTimer(ST_GRENADE, 60);
			return true;
		end
		
		if (Unit_AECheck(agent, 7, 3, false, targets)) then
			if (agent:CastSpell(target, SPELL_WAR_WHIRLWIND, false) == CAST_OK) then
				return;
			end
			if (not agent:IsSpellReady(SPELL_WAR_WHIRLWIND)) then
				if (agent:CastSpell(target, data.cleave, false) == CAST_OK) then
					return;
				end
			end
			return;
		end
		
	end
	
	-- Execute
	if (level >= 24 and agent:CastSpell(target, data.execute, false) == CAST_OK) then
		print("Execute", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Overpower
	if (level >= 12 and agent:CastSpell(target, data.overpower, false) == CAST_OK) then
		print("Overpower", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Rend
	if (WarriorTankDoDebuffs(ai, agent, goal, data, partyData, level, target, true)) then
		return true;
	end
	
	-- Strike
	if (agent:CastSpell(target, data.heroic, false) == CAST_OK) then
		print("Heroic Strike", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
	
end


function WarriorPullRotation(ai, agent, target)
	
	local level = agent:GetLevel();
	WarriorTankShapeshift(ai, agent, level);
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 5.0)) then
		return false;
	end
	return AI_ShootRanged(ai, agent, target) == CAST_OK;

end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function WarriorLevelTank_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function WarriorLevelTank_Interrupt(ai, goal)

end
