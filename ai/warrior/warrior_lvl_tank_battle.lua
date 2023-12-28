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
	print();
	DebugPlayer_PrintTalentsNice(agent, true);
	print();
	
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
	
	-- talents
	data._hasShieldSlam = Builds.Select(agent, "1.6.1", 148, agent.HasTalent, 0);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, data.sunder, false, true);;
	if (false == agent:HasAura(SPELL_WAR_DEFENSIVE_STANCE)) then
		threat = threat * 1.3;
	end
	ai:SetStdThreat(threat);
	
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
	
	local cmd = ai:CmdType();
	if (cmd == -1 or nil == party) then
		return GOAL_RESULT_Continue;
	end
	
	if (false == agent:IsAlive()) then
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
			ai:CmdSetInProgress();
		end
		local hive = ai:GetPartyIntelligence();
		local data = hive:GetData();
		local attackers = data.attackers;
		if (not attackers[1]) then
			return GOAL_RESULT_Continue;
		end
		if (agent:GetMotionType() ~= MOTION_CHASE or agent:GetVictim() ~= attackers[1]) then
			agent:AttackStop();
			agent:ClearMotion();
			agent:Attack(attackers[1]);
			local angle = ai:CmdArgs();
			agent:MoveChase(attackers[1], 0.001, 0.1, 0.1, angle, math.rad(15), false, true);
		end
	
	elseif (cmd == CMD_TANK) then
	
		-- do tank!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			goal:ClearSubGoal();
			agent:ClearMotion();
			ai:CmdSetInProgress();
			ai:UnsetAbsAngle();
			data.tankrot = nil;
		end
		
		local guid = ai:CmdArgs();
		local target = GetUnitByGuid(agent, guid);
		
		-- target expired
		if (nil == target or false == target:IsAlive() or party:IsCC(target)) then
			ai:CmdComplete();
			agent:ClearMotion();
			agent:AttackStop();
			return GOAL_RESULT_Continue;
		end
		
		-- changing target
		if (target ~= agent:GetVictim()) then
			agent:ClearMotion();
			agent:Attack(target);
		end
		
		local reverse = party:GetData().reverse;
		
		-- move
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
	
	if (data.grenade and party and agent:GetDistance(target) < 10.0 and false == target:IsMoving()) then
		local partyData = party:GetData();
		
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
	
	if (agent:GetDistance(target) > 5.0) then
		return false;
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
