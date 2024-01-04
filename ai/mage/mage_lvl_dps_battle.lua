--[[*******************************************************************************************
	GOAL_MageLevelDps_Battle = 10004
	
	Mage dps leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_MageLevelDps_Battle, "MageLevelDps");

local ST_POT = 0;

--[[*****************************************************
	Goal activation.
*******************************************************]]
function MageLevelDps_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Dagger);
	agent:LearnSpell(Proficiency.Sword);
	
	local gsi = GearSelectionInfo(
		0.001, 0.001, -- armor, damage
		GearSelectionWeightTable(ItemStat.Intellect, 5, ItemStat.Stamina, 1, ItemStat.Spirit, 3), -- stats
		GearSelectionWeightTable(AURA_MOD_DAMAGE_DONE, 15), -- auras
		SpellSchoolMask.Frost --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth"},
		WeaponType = {"Staff"},--, "Dagger", "Sword"},
		-- OffhandType = {"Holdable"},
		RangedType = {"Wand"},
	};
	AI_SpecGenerateGear(ai, info, gsi, nil, true)
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	ai:SetRole(ROLE_RDPS);
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	
	AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	
	data.fireball   = ai:GetSpellMaxRankForMe(SPELL_MAG_FIREBALL);
	data.frostbolt  = ai:GetSpellMaxRankForMe(SPELL_MAG_FROSTBOLT);

	data.poly       = ai:GetSpellMaxRankForMe(SPELL_MAG_POLYMORPH);
	data.decurse    = SPELL_MAG_REMOVE_LESSER_CURSE;

	-- buff         
	data.frostA     = ai:GetSpellMaxRankForMe(SPELL_MAG_FROST_ARMOR);
	data.iceA       = ai:GetSpellMaxRankForMe(SPELL_MAG_ICE_ARMOR);
	data.mageA      = ai:GetSpellMaxRankForMe(SPELL_MAG_MAGE_ARMOR);

	data.brilliance = Builds.Select(ai, "1.4.2", SPELL_MAG_ARCANE_BRILLIANCE, ai.GetSpellMaxRankForMe);
	data.intellect  = ai:GetSpellMaxRankForMe(SPELL_MAG_ARCANE_INTELLECT);
	data.aint       = level >= 56 and data.brilliance or data.intellect;
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	
	if (level < 30) then
		data.armor = data.frostA;
	elseif (level < 34) then
		data.armor = data.iceA;
	else
		data.armor = data.mageA;
	end
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(2.0*threat);
	
	local party = ai:GetPartyIntelligence();
	if (party) then
		local partyData = party:GetData();
		local type = BUFF_SINGLE;
		if (data.aint == data.brilliance) then
			type = BUFF_PARTY;
		end
		partyData:RegisterBuff(agent, "Arcane Intellect", 1, data.aint, type, 5*6e4);
		partyData:RegisterCC(agent, data.poly);
	end

end

--[[*****************************************************
	Goal update.
*******************************************************]]
function MageLevelDps_Update(ai, goal)
	
	local data = ai:GetData();
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	local cmd = ai:CmdType();
	if (cmd == -1 or nil == party) then
		return GOAL_RESULT_Continue;
	end
	
	if (false == agent:IsAlive()) then
		goal:ClearSubGoal();
		agent:ClearMotion();
		ai:SetCCTarget(nil);
		return GOAL_RESULT_Continue;
	end
	
	if (0 == #partyData.attackers) then
		ai:SetCCTarget(nil);
	else
		-- update CC target
		-- could be better to merge with CMD_ENGAGE
		if (ai:CmdType() ~= CMD_CC) then
			local target = ai:GetCCTarget();
			if (target) then
				if (nil == target or false == target:IsAlive() or (party and false == party:IsCC(target))) then
					ai:SetCCTarget(nil);
				end
			end
		end
	end
	
	-- handle commands
	if (cmd == CMD_FOLLOW) then
	
		if (ai:CmdState() == CMD_STATE_WAITING) then
			print("mage CMD_FOLLOW");
			agent:AttackStop();
			agent:ClearMotion();
			ai:CmdSetInProgress();
			goal:ClearSubGoal();
		end
		
		if (goal:GetSubGoalNum() > 0 or agent:IsNonMeleeSpellCasted()) then
			return GOAL_RESULT_Continue;
		end
		
		AI_Replenish(agent, goal, 90.0, 70.0);
		
		-- armor
		MageSelfBuff(agent, data);
		
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
			print("mage cmd_engage");
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
		
		local target = Dps_GetLowestHpTarget(ai, agent, party, targets, agent:IsInDungeon());
		-- too high threat
		if (not target or not target:IsAlive()) then
			agent:AttackStop();
			agent:ClearMotion();
			agent:InterruptSpell(CURRENT_GENERIC_SPELL);
			-- Print("No target for", agent:GetName());
			return GOAL_RESULT_Continue;
		end
		
		if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		
		if (target:GetDistance(agent) > 5.0 or false == ai:IsCLineAvailable() or target:GetVictim() == agent) then
			Dps_RangedChase(ai, agent, target);
		else
			local x,y,z = party:GetCLinePInLosAtD(agent, target, 10, 15, 1, not partyData.reverse);
			if (x) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, x, y, z);
				print("Move To", x, y, z);
			else
				Dps_RangedChase(ai, agent, target);
			end
		end
		
		if (agent:IsMoving()) then
			return GOAL_RESULT_Continue;
		end
		
		MageDpsRotation(ai, agent, goal, ai:GetData(), target);
	
	elseif (cmd == CMD_BUFF) then
		
		if (ai:CmdState() == CMD_STATE_WAITING) then
			print("mage CMD_BUFF");
			ai:CmdSetInProgress();
			goal:ClearSubGoal();
		end
		
		-- give buffs!
		local guid, spellid, key = ai:CmdArgs();
		if (false == agent:HasEnoughPowerFor(spellid, false)) then
			-- release assigned buff
			if (goal:GetActiveSubGoalId() ~= GOAL_COMMON_Replenish) then
				goal:ClearSubGoal();
			end
			AI_Replenish(agent, goal, 0.0, 99.0);
			return GOAL_RESULT_Continue;
		end
		
		if (goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		
		local target = GetPlayerByGuid(guid);
		if (nil == target or false == target:IsAlive()) then
			ai:CmdComplete();
			goal:ClearSubGoal();
			return GOAL_RESULT_Continue;
		end
		
		goal:AddSubGoal(GOAL_COMMON_Buff, 20.0, guid, spellid, key);
		
	elseif (cmd == CMD_CC) then
		
		-- do cc!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			agent:InterruptSpell(CURRENT_GENERIC_SPELL);
			agent:AttackStop();
			agent:ClearMotion();
			ai:CmdSetInProgress();
			goal:ClearSubGoal();
			print("Begin CC");
		end
		
		local guid = ai:CmdArgs();
		local target = GetUnitByGuid(agent, guid);
		local party = ai:GetPartyIntelligence();
		if (nil == target or false == target:IsAlive() or (party and false == party:IsCC(target))) then
			ai:SetCCTarget(nil);
			ai:CmdComplete();
			goal:ClearSubGoal();
			print("End CC");
			return GOAL_RESULT_Continue;
		end
		
		if (goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		ai:SetCCTarget(guid);
		goal:AddSubGoal(GOAL_COMMON_Cc, 20.0, guid, data.poly);
		
	end

	return GOAL_RESULT_Continue;
	
end

local function MagePotions(agent, goal, data)
	
	local mp = agent:GetPowerPct(POWER_MANA);
	-- Rage Potion
	if (data.manapot and goal:IsFinishTimer(ST_POT) and mp < 50 and agent:CastSpell(agent, data.manapot, true) == CAST_OK) then
		print("Mana Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

function MageSelfBuff(agent, data)
	
	-- armor
	if (not agent:HasAura(data.armor)) then
		agent:CastSpell(agent, data.armor, false);
	end
	
end

function MageDpsRotation(ai, agent, goal, data, target)
	
	local level = agent:GetLevel();
	
	if (agent:IsNonMeleeSpellCasted()) then
		return false;
	end
	
	if (agent:IsMoving()) then
		return false;
	end
	
	local mana = agent:GetPowerPct(POWER_MANA);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	
	-- armor
	MageSelfBuff(agent, data);
	
	-- Potions
	MagePotions(agent, goal, data);
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, data.frostbolt, 2.5)) then
		-- print("pos fail", agent:IsInPositionToCast(target, data.frostbolt, 2.5));
		return false;
	end
	
	-- spammable
	if (level >= 4) then
		if (agent:CastSpell(target, data.frostbolt, false) == CAST_OK) then
			-- print("Frostbolt", agent:GetName(), target:GetName());
			return true;
		else
			-- print("cast fail", agent:CastSpell(target, data.frostbolt, false));
		end
	elseif (agent:CastSpell(target, data.fireball, false) == CAST_OK) then
		print("Fireball", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function MageLevelDps_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function MageLevelDps_Interrupt(ai, goal)

end
