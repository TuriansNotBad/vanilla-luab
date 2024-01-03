--[[*******************************************************************************************
	GOAL_FeralLevelDpsDps_Battle = 10005
	
	Dps balance druid leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_DruidFeralLevelDps_Battle, "FeralLevelDps");

local function GetForms()
	return {
		[FORM_CAT]  = SPELL_DRD_CAT_FORM,
		[FORM_BEAR] = SPELL_DRD_BEAR_FORM,
	};
end

local ST_POT = 0;

local function DruidUpdateForm(data, ai, agent, goal)
	
	local form = ai:GetForm();
	if (form == agent:GetShapeshiftForm() or agent:GetStandState() ~= STAND_STATE_STAND or agent:IsNonMeleeSpellCasted()) then
		return;
	end
	
	if (form ~= FORM_NONE and false == agent:HasEnoughPowerFor(data.forms[FORM_BEAR], true)) then
		return false;
	end

	if (agent:GetShapeshiftForm() ~= FORM_NONE and agent:GetShapeshiftForm() ~= form) then
		agent:CancelAura(GetSpellForForm(agent:GetShapeshiftForm()));
		return;
	end
	
	if (form ~= FORM_NONE) then
		agent:CastSpell(agent, GetSpellForForm(form), false);
	end

end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function FeralLevelDps_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	ai:SetRole(ROLE_MDPS);
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Mace);
	agent:LearnSpell(Proficiency.Mace2H);
	
	-- spec it
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	local gsi = GearSelectionInfo(
		0.0003, 1e-6, -- armor, damage
		GearSelectionWeightTable(ItemStat.Strength, 5, ItemStat.Intellect, 1), -- stats
		GearSelectionWeightTable(), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth", "Leather"},
		WeaponType = {"Mace2H", "Staff"},
		-- OffhandType = {"Holdable"},
	};
	if (specTbl.Copy == true) then
		ai:EquipDestroyAll();
		ai:EquipCopyFromMaster();
		ai:UpdateVisibilityForMaster();
	else
		if (level >= 29) then
			info.WeaponType = {};
			AI_SpecGenerateGear(ai, info, gsi, nil, true);
			ai:EquipItem(ITEMID_MANUAL_CROWD_PUMMELER, 0, 0);
			ai:UpdateVisibilityForMaster();
		else
			AI_SpecGenerateGear(ai, info, gsi, nil, true);
		end
	end
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	AI_SpecApplyTalents(ai, level, talentInfo.talents);
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	-- caster
	data.wrath = ai:GetSpellMaxRankForMe(SPELL_DRD_WRATH);
	
	-- bear
	data.maul   = ai:GetSpellMaxRankForMe(SPELL_DRD_MAUL);
	data.swipe  = ai:GetSpellMaxRankForMe(SPELL_DRD_SWIPE);
	data.demo   = ai:GetSpellMaxRankForMe(SPELL_DRD_DEMORALIZING_ROAR);
	data.bash   = ai:GetSpellMaxRankForMe(SPELL_DRD_BASH);
	
	-- cat
	data.fbite   = Builds.Select(ai, "1.3.1", SPELL_DRD_FEROCIOUS_BITE, ai.GetSpellMaxRankForMe);
	data.rip     = ai:GetSpellMaxRankForMe(SPELL_DRD_RIP);
	data.shred   = ai:GetSpellMaxRankForMe(SPELL_DRD_SHRED);
	data.claw    = ai:GetSpellMaxRankForMe(SPELL_DRD_CLAW);
	data.cower   = ai:GetSpellMaxRankForMe(SPELL_DRD_COWER);
	data.cfire   = ai:GetSpellMaxRankForMe(SPELL_DRD_FAERIE_FIRE_CAT); -- changed to faerie fire (feral) in 1.8
	
	-- buffs
	data.fire  = ai:GetSpellMaxRankForMe(SPELL_DRD_FAERIE_FIRE);
	data.thorns= ai:GetSpellMaxRankForMe(SPELL_DRD_THORNS);
	data.mark  = ai:GetSpellMaxRankForMe(SPELL_DRD_MARK_OF_THE_WILD);
	data.gift  = ai:GetSpellMaxRankForMe(SPELL_DRD_GIFT_OF_THE_WILD);
	data.motw  = level >= 50 and data.gift or data.mark;
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	
	-- talents
	data._hasCatFire = agent:HasTalent(1162, 0);
	
	data.UpdateShapeshift = DruidUpdateForm;
	data.forms = GetForms();
	ai:SetForm(FORM_NONE);
	
	local threatSpell = data.wrath;
	if (level >= 20) then
		threatSpell = data.shred;
	elseif (level >= 10) then
		threatSpell = data.maul
	end
	local _,threat = agent:GetSpellDamageAndThreat(agent, threatSpell, false, true, 1);
	ai:SetStdThreat(threat);
	
	local party = ai:GetPartyIntelligence();
	if (party) then
		local partyData = party:GetData();
		local type = BUFF_SINGLE;
		if (data.motw == data.gift) then
			type = BUFF_PARTY;
			partyData:RegisterBuff(agent, "ST: Mark of the Wild", 1, data.mark, BUFF_SINGLE, 5*6e4, {party = false, notauras = {21850, 21849}});
		end
		partyData:RegisterBuff(agent, "Mark of the Wild", 1, data.motw, type, 5*6e4, {party = true});
		partyData:RegisterBuff(agent, "Thorns", 1, data.thorns, BUFF_SINGLE, 3*6e4, {role = {[ROLE_TANK] = true}});
	end

end

--[[*****************************************************
	Goal update.
*******************************************************]]
function FeralLevelDps_Update(ai, goal)

	local data = ai:GetData();
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	
	local cmd = ai:CmdType();
	if (cmd == -1 or nil == party) then
		return GOAL_RESULT_Continue;
	end
	
	DruidUpdateForm(data, ai, agent, goal);

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
		
		local level = agent:GetLevel();
		if (level < 10) then
			ai:SetForm(FORM_NONE);
		elseif (level < 20) then
			ai:SetForm(FORM_BEAR);
		else
			ai:SetForm(FORM_CAT);
		end
		
		local transformpct = agent:GetPowerCost(data.forms[FORM_BEAR]) * 100.0/agent:GetMaxPower(POWER_MANA);
		local manaThresh;
		if (agent:GetShapeshiftForm() == FORM_NONE) then
			manaThresh = 96.0;
		else
			manaThresh = 95.0 - transformpct;
		end
		AI_Replenish(agent, goal, 90.0, manaThresh, FORM_NONE);
		
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
			agent:InterruptSpell(CURRENT_MELEE_SPELL);
			-- Print("No target for", agent:GetName());
			return GOAL_RESULT_Continue;
		end
		
		if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		
		-- Potions
		DruidPotions(agent, goal, data);
		
		local level = agent:GetLevel();
		if (level < 10) then
			DruidLowLevelRotation(ai, agent, goal, ai:GetData(), target);
		elseif (level < 20) then
			DruidBearRotation(ai, agent, goal, ai:GetData(), target);
		else
			DruidCatRotation(ai, agent, goal, ai:GetData(), target);
		end
	
	elseif (cmd == CMD_BUFF) then
		
		if (ai:CmdState() == CMD_STATE_WAITING) then
			ai:CmdSetInProgress();
			goal:ClearSubGoal();
		end
		
		-- give buffs!
		local guid, spellid, key = ai:CmdArgs();
		if (false == agent:HasEnoughPowerFor(spellid, true)) then
			-- release assigned buff
			if (goal:GetActiveSubGoalId() ~= GOAL_COMMON_Replenish) then
				goal:ClearSubGoal();
			end
			AI_Replenish(agent, goal, 0.0, 99.0, FORM_NONE);
			return GOAL_RESULT_Continue;
		end
		
		if (goal:GetSubGoalNum() > 0) then
			return GOAL_RESULT_Continue;
		end
		
		ai:SetForm(FORM_NONE);
		local target = GetPlayerByGuid(guid);
		if (nil == target or false == target:IsAlive()) then
			ai:CmdComplete();
			goal:ClearSubGoal();
			return GOAL_RESULT_Continue;
		end
		
		if (agent:GetShapeshiftForm() == FORM_NONE) then
			goal:AddSubGoal(GOAL_COMMON_Buff, 20.0, guid, spellid, key);
		end
	
	end

	return GOAL_RESULT_Continue;
	
end

function DruidPotions(agent, goal, data)
	
	if (agent:GetShapeshiftForm() ~= FORM_NONE) then
		return;
	end
	
	local mp = agent:GetPowerPct(POWER_MANA);
	-- Rage Potion
	if (data.manapot and goal:IsFinishTimer(ST_POT) and mp < 80 and agent:CastSpell(agent, data.manapot, true) == CAST_OK) then
		print("Mana Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

local function DruidApplyItemBuffs(ai, agent, goal, data, level)
	
	-- crowd pummeler, could check if equipped
	if (level >= 29 and false == agent:HasAura(SPELL_GEN_PUMMELER)) then
		if (agent:HasEnoughPowerFor(data.forms[FORM_BEAR], true)) then
			goal:AddSubGoal(GOAL_COMMON_CastInForm, 10.0, agent:GetGuid(), SPELL_GEN_PUMMELER, FORM_NONE);
			return true;
		end
	end
	
	return false;
	
end

function DruidCatRotation(ai, agent, goal, data, target)

	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	Dps_MeleeChase(ai, agent, target);
	
	local level = agent:GetLevel();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	local cp = agent:GetComboPoints();
	
	-- item buffs
	if (DruidApplyItemBuffs(ai, agent, goal, data, level)) then
		return true;
	end
	
	ai:SetForm(FORM_CAT);
	
	-- Pick Faerie Fire
	if (data._hasCatFire) then
		if (false == target:HasAura(data.cfire) and agent:CastSpell(target, data.cfire, false) == CAST_OK) then
			print("Feral Fire (Cat)", agent:GetName(), target:GetName());
			return true;
		end
	elseif (level >= 18 and false == target:HasAura(data.fire) and agent:HasEnoughPowerFor(data.forms[FORM_BEAR], true)) then
		goal:AddSubGoal(GOAL_COMMON_CastInForm, 10.0, target:GetGuid(), data.fire, FORM_NONE);
		return true;
	end
	
	if (target:GetDistance(agent) > 5.0) then
		return false;
	end
	
	-- Finisher
	if (cp == 5) then
		if (data.fbite and level >= 32 and agent:CastSpell(target, data.fbite, false) == CAST_OK) then
			print("Ferocious Bite", agent:GetName(), target:GetName());
			return true;
		end
		if (agent:CastSpell(target, data.rip, false) == CAST_OK) then
			print("Rip", agent:GetName(), target:GetName());
			return true;
		end
		return false;
	end
	
	-- shred, must be behind
	if (level >= 22 and agent:CastSpell(target, data.shred, false) == CAST_OK) then
		print("Shred", agent:GetName(), target:GetName());
		return true;
	end
	
	-- claw
	if (agent:CastSpell(target, data.claw, false) == CAST_OK) then
		print("Claw", agent:GetName(), target:GetName());
		return true;
	end

end

function DruidBearRotation(ai, agent, goal, data, target)

	ai:SetForm(FORM_BEAR);
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsNextSwingSpellCasted()) then
		return false;
	end
	
	Dps_MeleeChase(ai, agent, target);
	
	local level = agent:GetLevel();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	-- enrage
	if (level >= 12 and agent:CastSpell(agent, SPELL_DRD_ENRAGE, false) == CAST_OK) then
		print("Enrage", agent:GetName());
		return true;
	end
	
	if (target:GetDistance(agent) > 5.0) then
		return false;
	end
	
	-- Demoralizing Roar
	if (false == target:HasAura(data.demo) and agent:CastSpell(target, data.demo, false) == CAST_OK) then
		print("Demoralizing Roar", agent:GetName(), target:GetName());
		return true;
	end
	
	-- bash
	if (level >= 14 and agent:CastSpell(target, data.bash, false) == CAST_OK) then
		print("Bash", agent:GetName(), target:GetName());
		return true;
	end
	
	-- swipe
	if (level >= 16 and Unit_AECheck(agent, 5.0, 3, true, partyData.attackers)) then
		if (agent:CastSpell(target, data.swipe, false) == CAST_OK) then
			print("Swipe", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	-- maul
	if (agent:CastSpell(target, data.maul, false) == CAST_OK) then
		print("Maul", agent:GetName(), target:GetName());
		return true;
	end

end

function DruidLowLevelRotation(ai, agent, goal, data, target)
	
	ai:SetForm(FORM_NONE);
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsMoving()) then
		return false;
	end
	
	if (agent:HasEnoughPowerFor(data.wrath, false)) then
		Dps_RangedChase(ai, agent, target);
	else
		Dps_MeleeChase(ai, agent, target);
	end
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, data.wrath, 2.5)) then
		-- print("pos fail", agent:IsInPositionToCast(target, data.frostbolt, 2.5));
		return false;
	end
	
	-- spammable
	if (agent:CastSpell(target, data.wrath, false) == CAST_OK) then
		print("Wrath", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function FeralLevelDps_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function FeralLevelDps_Interrupt(ai, goal)

end
