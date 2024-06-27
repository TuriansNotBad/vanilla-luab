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
	AI_SpecGenerateGear(ai, info, gsi, nil, true)
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
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
	
	data.dshout  = ai:GetSpellMaxRankForMe(SPELL_WAR_DEMORALIZING_SHOUT);
	
	-- consumes
	data.grenade = Consumable_GetExplosive(level);
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.ragepot = Consumable_GetRagePotion(level);
	
	-- dps
	data.charge			= ai:GetSpellMaxRankForMe(SPELL_WAR_CHARGE);
	data.rend			= ai:GetSpellMaxRankForMe(SPELL_WAR_REND);
	data.execute		= ai:GetSpellMaxRankForMe(SPELL_WAR_EXECUTE);
	data.overpower 		= ai:GetSpellMaxRankForMe(SPELL_WAR_OVERPOWER);
	
	-- talents
	data._hasShieldSlam = Builds.Select(agent, "1.6.1", 148, agent.HasTalent, 0);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, data.sunder, false, true);;
	if (false == agent:HasAura(SPELL_WAR_DEFENSIVE_STANCE)) then
		threat = threat * 1.3;
	end
	ai:SetStdThreat(threat);
	Print("Tank std threat, x2", ai:GetStdThreat(), ai:GetStdThreat() * 2);
	
	ai:SetAmmo(ITEMID_ROUGH_ARROW);
	data.PullRotation = WarriorPullRotation;
	
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function WarriorLevelTank_Update(ai, goal)
	
	local data = ai:GetData();
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	local cmd = ai:CmdType();
	if (cmd == CMD_NONE or nil == party) then
		return GOAL_RESULT_Continue;
	end
	
	if (AI_IsIncapacitated(agent)) then
		goal:ClearSubGoal();
		-- agent:ClearMotion();
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
		
		AI_Replenish(agent, goal, 90.0, -1);
		
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
			Print(agent:GetName(), agent:GetClass(), "CMD_ENGAGE default update");
			ai:CmdSetInProgress();
		end
		
		local partyData = party:GetData();
		-- party has no attackers
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
		
		local bThreatCheck = agent:IsInDungeon() and partyData:HasTank();
		
		local target = Tank_GetLowestHpTarget(ai, agent, party, targets, bThreatCheck, ai:GetStdThreat());
		local bAllowThreatActions = target ~= nil;
		
		-- use tank's target if threat is too high
		if (nil == target and partyData:HasTank()) then
			local tank = partyData.tanks[1];
			if (tank:GetPlayer():IsInCombat()) then
				target = tank:GetPlayer():GetVictim();
			end
		end
		
		-- still nothing
		if (nil == target or not target:IsAlive()) then
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
		
		-- movement
		local area = partyData._holdPos;
		local bSwap = partyData.encounter and partyData.encounter.tankswap and target:GetName() == partyData.encounter.name;
		local _,threat = target:GetHighestThreat();
		local threatdiff = threat - target:GetThreat(agent);
		
		if (area and false == AI_TargetInHoldingArea(target, area) and (not bSwap or threatdiff < 1000)) then
			
			if (agent:GetDistance(area.dpspos.x, area.dpspos.y, area.dpspos.z) > 2.0) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, area.dpspos.x, area.dpspos.y, area.dpspos.z);
				return GOAL_RESULT_Continue;
			end
		
		else
		
			Dps_MeleeChase(ai, agent, target, bAllowThreatActions);
			
		end
		
		-- attacks
		if (bAllowThreatActions) then
			if (bSwap) then
				WarriorTankMaintainThreatRotation(ai, agent, goal, data, target);
			else
				WarriorTankDpsRotation(ai, agent, goal, data, target);
			end
		else
			agent:AttackStop();
		end
		
		return GOAL_RESULT_Continue;
		
	elseif (cmd == CMD_TANK) then
	
		-- do tank!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			goal:ClearSubGoal();
			agent:ClearMotion();
			ai:CmdSetInProgress();
			ai:UnsetAbsAngle();
			data.tankrot = nil;
			Print(agent:GetName(), "CMD_TANK begin.");
		end
		
		local guid = ai:CmdArgs();
		local target = GetUnitByGuid(agent, guid);
		
		-- target expired
		if (nil == target or false == target:IsAlive() or party:IsCC(target)) then
			ai:CmdComplete();
			agent:ClearMotion();
			agent:AttackStop();
			Print(agent:GetName(), "CMD_TANK complete.", type(target), target and not target:IsAlive(), target and party:IsCC(target), #partyData.attackers);
			return GOAL_RESULT_Continue;
		end
		
		-- changing target
		if (target ~= agent:GetVictim()) then
			agent:ClearMotion();
			agent:Attack(target);
		end
		
		local reverse = party:GetData().reverse;
		
		-- move
		
		local area = partyData._holdPos;
		if (area and false == AI_TargetInHoldingArea(target, area) and target:GetVictim() == agent) then
			
			if (agent:GetDistance(area.dpspos.x, area.dpspos.y, area.dpspos.z) > 2.0) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, area.dpspos.x, area.dpspos.y, area.dpspos.z);
				return GOAL_RESULT_Continue;
			end
			
		else
		
			local tpx,tpy,tpz = ai:GetPosForTanking(target);
			
			if (Tank_BringTargetToPos(ai, agent, target, ai:GetPosForTanking(target))) then
				if (false == agent:CanReachWithMelee(target)) then
					if (false == target:IsMoving() or target:GetVictim() ~= agent or Unit_IsCrowdControlled(target)) then
						if (agent:GetMotionType() ~= MOTION_CHASE and agent:GetMotionType() ~= MOTION_CHARGE) then
							agent:MoveChase(target, 2.0, 2.0, 1.0, 0.0, math.pi, false, true);
							data.tankrot = nil;
						end
					end
				else
					if (agent:GetMotionType() ~= MOTION_CHASE and agent:GetMotionType() ~= MOTION_CHARGE) then
						agent:MoveChase(target, 2.0, 2.0, 1.0, 0.0, math.pi, false, true);
					end
					if (agent:GetMotionType() == MOTION_CHASE and ai:IsCLineAvailable()) then
						if (data.tankrot == nil) then
							data.tankrot = ai:GetAngleForTanking(target, reverse, reverse);
						end
						if (data.tankrot) then
							if (data.tankrot ~= data.__oldrot or data.__oldori ~= target:GetOrientation()) then
								-- Print(data.tankrot, target:GetOrientation(), ai:IsUsingAbsAngle(), data.fliptankrot);
								data.__oldrot, data.__oldori = data.tankrot, target:GetOrientation();
							end
							local adiff = math.abs(target:GetOrientation() - data.tankrot);
							adiff = math.min(2*math.pi - adiff, adiff);
							if (adiff > 0.78) then
								if (not ai:IsUsingAbsAngle()) then
									ai:SetAbsAngle(data.tankrot);
									print("set angle", adiff);
								end
							elseif (ai:IsUsingAbsAngle()) then
								print("unset angle");
								ai:UnsetAbsAngle();
							end
						end
					end
				end
			end
			
		end
		
		-- do abilities
		if (WarriorTankRotation(ai, agent, goal, data, target) and false == ai:CmdIsRequirementMet()) then
			local threat = target:GetThreat(agent);
			if (threat >= ai:CmdGetProgress() - 0.01) then
				ai:CmdSetProgress(threat);
			else
				-- creature uses aggro reducing spells, set complete
				ai:CmdSetProgress(10000000.0);
			end
		end
	
	elseif (cmd == CMD_PULL) then
	
		-- do pull!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			ai:CmdSetInProgress();
			goal:AddSubGoal(GOAL_COMMON_Pull, 60, ai:CmdArgs());
		end
		if (goal:GetSubGoalNum() == 0) then
			ai:CmdComplete();
		end
	
	end

	return GOAL_RESULT_Continue;
	
end

local function WarriorTankShapeshift(agent, level)
	if (level >= 10) then
		if (FORM_DEFENSIVESTANCE ~= agent:GetShapeshiftForm()) then
			agent:CastSpell(agent, SPELL_WAR_DEFENSIVE_STANCE, false);
		end
	elseif (FORM_BATTLESTANCE ~= agent:GetShapeshiftForm()) then
		agent:CastSpell(agent, SPELL_WAR_BATTLE_STANCE, false);
	end
end

local function WarriorTankPotions(agent, goal, data)
	
	-- Rage Potion
	if (data.ragepot and goal:IsFinishTimer(ST_POT) and agent:CastSpell(agent, data.ragepot, false) == CAST_OK) then
		print("Rage Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

function WarriorTankRotation(ai, agent, goal, data, target)
	
	local level = agent:GetLevel();
	
	WarriorTankShapeshift(agent, level);
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local rage = agent:GetPowerPct(POWER_RAGE);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	if (data.grenade and party and agent:GetDistance(target) < 10.0 and false == target:IsMoving() and false == agent:IsMoving()) then
		
		if (level >= 10 and goal:IsFinishTimer(0) and hp > 50) then
			
			-- sapper charge
			if (Unit_AECheck(agent, 5.0, 2, false, partyData.attackers) and agent:CastSpell(agent, SPELL_GEN_GOBLIN_SAPPER_CHARGE, false) == CAST_OK) then
				print("Goblin Sapper Charge", agent:GetName(), target:GetName());
				goal:SetTimer(0, 300);
				goal:SetTimer(1, 60);
				return true;
			end
			
		elseif (goal:IsFinishTimer(1)) then
			
			-- throw dynamite
			if (Unit_AECheck(target, 5.0, 2, false, partyData.attackers) and agent:CastSpell(target, data.grenade, false) == CAST_OK) then
				print("Dynamite", agent:GetName(), target:GetName());
				goal:SetTimer(1, 60);
				return true;
			end
			
		end
	end
	
	-- Potions
	WarriorTankPotions(agent, goal, data);
	
	-- try to save ourselves
	if (hp < 30) then
		
		-- Shield Block
		if (level >= 16 and not agent:HasAura(SPELL_WAR_SHIELD_BLOCK) and agent:CastSpell(agent, SPELL_WAR_SHIELD_BLOCK, false) == CAST_OK) then
			-- print("Shield Block", agent:GetName());
			return true;
		end

	end
	
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
	
	if (agent:GetAttackersNum() > 3 and false == agent:HasAura(11350)) then
		agent:CastSpell(agent, 11350, true);
	end
	
	-- Taunt
	if (level >= 10 and target:GetVictim() and target:GetVictim() ~= agent and not target:HasAura(SPELL_WAR_TAUNT)) then
		local result = agent:CastSpell(target, SPELL_WAR_TAUNT, false);
		if (result == CAST_OK) then
			print("Taunt ", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	-- Revenge
	if (level >= 14 and agent:CastSpell(target, data.revenge, false) == CAST_OK) then
		-- print("Revenge", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Demoralizing Shout
	if (level >= 14 and false == target:HasAura(data.dshout) and agent:CastSpell(target, data.dshout, false) == CAST_OK) then
		-- print("Demoralizing Shout", agent:GetName(), target:GetName());
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

function WarriorTankMaintainThreatRotation(ai, agent, goal, data, target)
	
	local level = agent:GetLevel();
	
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
	
	WarriorTankShapeshift(agent, level);
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local rage = agent:GetPowerPct(POWER_RAGE);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	-- Potions
	WarriorTankPotions(agent, goal, data);
	
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
	
	-- Revenge
	if (level >= 14 and agent:CastSpell(target, data.revenge, false) == CAST_OK) then
		-- print("Revenge", agent:GetName(), target:GetName());
		return true;
	end
	
	-- Demoralizing Shout
	if (level >= 14 and false == target:HasAura(data.dshout) and agent:CastSpell(target, data.dshout, false) == CAST_OK) then
		-- print("Demoralizing Shout", agent:GetName(), target:GetName());
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

function WarriorTankDpsRotation(ai, agent, goal, data, target)
	
	local level = agent:GetLevel();
	
	if (FORM_BATTLESTANCE ~= agent:GetShapeshiftForm()) then
		agent:CastSpell(agent, SPELL_WAR_BATTLE_STANCE, false);
	end
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	local rage = agent:GetPowerPct(POWER_RAGE);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	-- Potions
	WarriorTankPotions(agent, goal, data);
	
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
		if (CAST_OK == agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 2.5) and CAST_OK == agent:CastSpell(target, SPELL_GEN_SHOOT_BOW, false)) then
			return true;
		end
		return false;
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
	if (level >= 4 and false == target:HasAura(data.rend) and agent:CastSpell(target, data.rend, false) == CAST_OK) then
		print("Rend", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
	
end


function WarriorPullRotation(ai, agent, target)
	
	local level = agent:GetLevel();
	WarriorTankShapeshift(agent, level);
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, SPELL_GEN_SHOOT_BOW, 5.0)) then
		return;
	end
	agent:CastSpell(target, SPELL_GEN_SHOOT_BOW, false);

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
