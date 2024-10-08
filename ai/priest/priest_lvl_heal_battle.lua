--[[*******************************************************************************************
	GOAL_PriestLevelHeal_Battle = 10001
	
	Tank druid leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_PriestLevelHeal_Battle, "PriestLevelHeal");

-- local function print()end Print=print; fmtprint=print;

local ST_POT  = 0;
local ST_BOMB = 1;

local function CmdHealReset(ai, agent, goal, interrupt, complete)
	if (interrupt) then
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	end
	if (goal:GetActiveSubGoalId() ~= GOAL_COMMON_Replenish) then
		goal:ClearSubGoal();
	end
	ai:SetHealTarget(nil);
	goal:SetNumber(0, 0); -- reset saved target health
	goal:SetNumber(1, 0); -- reset saved spell effect
	print "CMDHeal Reset"
	if (complete) then
		print "CMDHeal Complete"
		Command_Complete(ai, "CMD_HEAL completed");
	end
	return GOAL_RESULT_Continue;
end

local function PriestPotions(agent, goal, data, defensePot)

	if (defensePot and false == agent:HasAura(defensePot)) then
		if (goal:IsFinishTimer(ST_POT) and agent:CastSpell(agent, defensePot, true) == CAST_OK) then
			print("Defense Potion", GetSpellName(defensePot), agent:GetName());
			goal:SetTimer(ST_POT, 120);
		end
		return;
	end
	
	local mp = agent:GetPowerPct(POWER_MANA);
	-- Rage Potion
	if (data.manapot and goal:IsFinishTimer(ST_POT) and mp < 50 and agent:CastSpell(agent, data.manapot, true) == CAST_OK) then
		print("Mana Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

local function PriestHealerCombat(ai, agent, goal, party, data, partyData, target)
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsInPositionToCast(target, data.smite, 2.0) ~= CAST_OK) then
		return false;
	end
	
	local level = agent:GetLevel();
	
	local targets = Data_GetAttackers(data, partyData);
	if (level >= 4 and data.attackmode == "aoe") then
		for i = 1,#targets do
			local target = targets[i];
			if (not target:HasAura(data.pain)) then
				if (agent:CastSpell(target, data.pain, false) == CAST_OK) then
					return true;
				end
			end
		end
	end

	if (targets.ignoreThreat) then
		if (level >= 10 and agent:CastSpell(target, data.mindblast, false) == CAST_OK) then
			return true;
		end
	end
	
	return agent:CastSpell(target, data.smite, false) == CAST_OK;
	
end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function PriestLevelHeal_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Dagger);
	
	agent:CancelAura(1460);

	
	local gsi = GearSelectionInfo(
		0.001, 0.001, -- armor, damage
		GearSelectionWeightTable(ItemStat.Intellect, 5, ItemStat.Stamina, 1, ItemStat.Spirit, 3), -- stats
		GearSelectionWeightTable(AURA_MOD_HEALING_DONE, 15, AURA_MOD_HEALING_DONE_PERCENT, 25), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth"},
		WeaponType = {"Mace", "Dagger"},
		OffhandType = {"Holdable"},
		RangedType = {"Wand"},
	};
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	AI_SpecEquipLoadoutOrRandom(ai, info, gsi, nil, true, Gear_GetLoadoutForLevel60(specTbl.Loadout));
	ai:SetRole(ROLE_HEALER);
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	
	AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data  = ai:GetData();
	data.grenade = Consumable_GetExplosive(level);
	
	data.gheal    = ai:GetSpellMaxRankForMe(SPELL_PRI_GREATER_HEAL);
	data.renew    = ai:GetSpellMaxRankForMe(SPELL_PRI_RENEW);
	data.fheal    = ai:GetSpellMaxRankForMe(SPELL_PRI_FLASH_HEAL);
	data.heal     = ai:GetSpellMaxRankForMe(SPELL_PRI_HEAL);
	data.lheal    = ai:GetSpellMaxRankForMe(SPELL_PRI_LESSER_HEAL);
	data.hot      = data.renew;
	
	data.fearward = ai:GetSpellMaxRankForMe(SPELL_PRI_FEAR_WARD);
	data.dispel   = ai:GetSpellMaxRankForMe(SPELL_PRI_DISPEL_MAGIC);
	data.pwf      = ai:GetSpellMaxRankForMe(SPELL_PRI_POWER_WORD_FORTITUDE);
	data.aepwf    = ai:GetSpellMaxRankForMe(SPELL_PRI_PRAYER_OF_FORTITUDE);
	data.innfire  = ai:GetSpellMaxRankForMe(SPELL_PRI_INNER_FIRE);
	
	data.shackle  = ai:GetSpellMaxRankForMe(SPELL_PRI_SHACKLE_UNDEAD);
	
	data.smite    = ai:GetSpellMaxRankForMe(SPELL_PRI_SMITE);
	data.mindblast= ai:GetSpellMaxRankForMe(SPELL_PRI_MIND_BLAST);
	data.pain     = ai:GetSpellMaxRankForMe(SPELL_PRI_SHADOW_WORD_PAIN);
	data.manaburn = ai:GetSpellMaxRankForMe(SPELL_PRI_MANA_BURN);
	
	data.fortitude = level >= 48 and data.aepwf or data.pwf;
	
	data.combatFn = PriestHealerCombat;
	
	data.heals = {};
	-- weak heals
	if (level < 16) then
		table.insert(data.heals, data.lheal);
	else
		if (level < 40) then
			table.insert(data.heals, ai:GetSpellOfRank(SPELL_PRI_HEAL, 1));
		end
		table.insert(data.heals, data.heal);
	end
	-- strong heals
	if (level >= 40) then
		if (level >= 52) then
			table.insert(data.heals, ai:GetSpellOfRank(SPELL_PRI_GREATER_HEAL, 3)); -- gheal 3
		end
		table.insert(data.heals, data.gheal);
	end
	data.weakestHeal = data.heals[1];
	assert(#data.heals > 0, "PriestLevelHeal_Activate: #data.heals > 0");
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_FLASK_OF_DISTILLED_WISDOM, level);
	
	data.dispels = {
		Magic = data.dispel,
		Disease = level >= 32 and SPELL_PRI_ABOLISH_DISEASE or SPELL_PRI_CURE_DISEASE,
	};
	
	local party = ai:GetPartyIntelligence();
	if (party) then
		local partyData = party:GetData();
		
		-- Shackle Undead, has to be permitted by encounter
		if (level >= 20) then
			data.ccspell = data.shackle;
			partyData:RegisterCC(agent, data.shackle);
		end
	
		local type = BUFF_SINGLE;
		if (data.fortitude == data.aepwf) then
			type = BUFF_PARTY;
		end
		-- Prior to patch 1.3 Prayer of Fortitude only applied to your party
		if (CVER < Builds["1.3.1"]) then
			if (data.fortitude == data.aepwf) then
				partyData:RegisterBuff(agent, "ST: Power Word: Fortitude", 1, data.pwf, BUFF_SINGLE, 5*6e4, {party = false, notauras = {21564, 21562}});
			end
			partyData:RegisterBuff(agent, "Power Word: Fortitude", 1, data.fortitude, type, 5*6e4, {party = type == BUFF_PARTY or nil});
		else
			partyData:RegisterBuff(agent, "Power Word: Fortitude", 1, data.fortitude, type, 5*6e4);
		end
		if (agent:GetRace() == RACE_DWARF and level >= 20) then
			local filter = {
				role = {[ROLE_TANK] = true, [ROLE_HEALER] = true},
				dungeon = {fear = true},
			};
			partyData:RegisterBuff(agent, "Fear Ward", 1, data.fearward, BUFF_SINGLE, 3*6e4, filter, true);
			partyData:RegisterBuff(agent, "Fear Ward NC", 1, data.fearward, BUFF_SINGLE, 3*6e4, {dungeon = {fear = true}});
		end
		if (level >= 14) then
			partyData:RegisterDispel(agent, "Disease");
		end
		if (level >= 18) then
			partyData:RegisterDispel(agent, "Magic");
		end
	end
	
	Movement_Init(data);
	data.ShouldInterruptPrecast = PriestLevelHeal_ShouldInterruptPrecast;
	data.InterruptCurrentHealingSpell = PriestLevelHeal_InterruptCurrentHealingSpell;
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(threat);
	
	-- Command params
	Cmd_EngageSetParams(data, true, nil, AI_DummyActions);
	Cmd_FollowSetParams(data, 90.0, 80.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
		(CMD_BUFF,   nil, nil, nil, true)
		(CMD_DISPEL, nil, nil, nil, true)
		(CMD_CC,     nil, nil, nil, true)
		(CMD_HEAL,   PriestLevelHeal_CmdHealOnBeginOrEnd, PriestLevelHeal_CmdHealUpdate, PriestLevelHeal_CmdHealOnBeginOrEnd, false)
		(CMD_SCRIPT, nil, nil, nil, true)
	;
	
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function PriestLevelHeal_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local data  = ai:GetData();
	if (agent:GetLevel() >= 12 and not agent:HasAura(data.innfire)) then
		agent:CastSpell(agent, data.innfire, false);
	end
	
	-- handle commands
	Command_DefaultUpdate(ai, goal);
	
	return GOAL_RESULT_Continue;
	
end

function PriestLevelHeal_CmdHealOnBeginOrEnd(ai)
	CmdHealReset(ai, ai:GetPlayer(), ai:GetTopGoal(), true);
end

function PriestLevelHeal_CmdHealUpdate(ai, agent, goal, party, data, partyData)
	-- do heal!
	if (false == agent:IsInCombat()) then
		AI_Replenish(agent, goal, 0.0, 30.0);
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return GOAL_RESULT_Continue;
	end

	local guid = ai:CmdArgs();
	local target = GetUnitByGuid(agent, guid);
	local isTank = target ~= nil and target:IsTanking();
	-- condition here to cancel healing charmed ones?
	if (not target or not target:IsAlive() or target:GetHealthPct() > 95 or target:CanAttack(agent)) then
		-- interrupt healing high health targets;
		Print("Redundant reset", target and target:GetName(), target and target:GetHealthPct(), target and target:CanAttack(agent));
		return CmdHealReset(ai, agent, goal, agent:IsInCombat(), true);
	end
	
	local hp = target:GetHealthPct();
	local hpdiff = target:GetMaxHealth() - target:GetHealth();
	ai:SetHealTarget(guid);
	
	local encounter = partyData.encounter;
	-- todo: target:GetVictim() - replace with target selection from cmd_engage handler
	Movement_Process(ai, goal, party, target:GetVictim(), true, false);
	
	-- interrupt preheals
	if (agent:IsNonMeleeSpellCasted()) then
		
		if (not PriestLevelHeal_InterruptPrecastHeals(agent, goal, target, isTank, hpdiff)
			and not PriestLevelHeal_InterruptBatchInvalidHeals(ai, agent, goal, partyData, target, goal:GetNumber(0), goal:GetNumber(1)))
		then
			return GOAL_RESULT_Continue;
		end
		
	end
	
	-- heal spell cast
	if (goal:GetNumber(1) > 0) then
		if (not ai:CmdIsRequirementMet()) then
			print"Progress"
			ai:CmdAddProgress();
		end
	end
	goal:SetNumber(0, 0); -- reset saved target health
	goal:SetNumber(1, 0); -- reset saved spell effect
	
	-- abandon healing nontanks that arent in immediate danger
	if (ai:CmdIsRequirementMet()) then
		-- if (agent:IsInCombat()) then
			if (not isTank and target:GetAttackersNum() == 0 and hp > 55) then
				print("req met reset");
				return CmdHealReset(ai, agent, goal, false, true);
			end
		-- end
	end
	
	PriestPotions(agent, goal, data, Data_GetDefensePotion(data, encounter));
	
	local maxThreat;
	if (partyData.attackers.ignoreThreat) then
		maxThreat = 5000.0;
	else
		if (target:IsTanking() and hp < 40) then
			maxThreat = 5000.0;
		else
			maxThreat = GetAEThreat(ai, agent, partyData, partyData.attackers);
		end
	end
	local spell,effect,effthreat = PriestLevelHeal_BestHealSpell(ai, agent, goal, data, target, hp, hpdiff, maxThreat, partyData);
	
	-- threat check not passed or just have no mana
	-- or if healing nontank hpdiff isn't low enough
	if (nil == spell) then
		return GOAL_RESULT_Continue;
	end
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, spell, 2.0)--[[and not rchrpos]]) then
		Movement_RequestMoveInPosToCast(data, guid, spell, 2.0);
		return GOAL_RESULT_Continue;
	end
	
	if (agent:CastSpell(target, spell, false) == CAST_OK) then
		Print("spell cast begin", GetSpellName(spell), spell, maxThreat, effect, effthreat, target:GetName(), hpdiff, target:GetHealthPct());
		goal:SetNumber(0, target:GetHealth()); -- remember target health at cast time
		goal:SetNumber(1, effect); -- remember healing amount of our spell
		-- if we're precasting we don't want this to block us from healing others
		-- this way we can interrupt any precast to put a hot on a dps or heal an actual low tank
		if (PriestLevelHeal_ShouldInterruptPrecast(agent, target, isTank, hpdiff) and not ai:CmdIsRequirementMet()) then
			print("Progress added");
			ai:CmdAddProgress();
		end
	end
	
	return GOAL_RESULT_Continue;

end

function PriestLevelHeal_BestHealSpell(ai, agent, goal, data, target, hp, hpdiff, maxThreat, partyData)
	
	local heals = data.heals;
	local maxheal = Data_GetHealModeMax(data, partyData) or #partyData.attackers == 0;
	local targetIsTank = target:IsTanking() or (target:GetRole() == ROLE_TANK and target:GetAttackersNum() > 0);
	
	-- avoid div by zero
	local threatDiv = math.max(#partyData.attackers, 1);
	
	-- pick the strongest spell that makes sense
	if (targetIsTank) then
		-- emergency heal?
		-- if (hp < 30) then
			-- return data.fheal, agent:GetSpellDamageAndThreat(target, data.fheal, true, false);
		-- end
		-- find first spell that we've enough mana for
		local threatFail = true;
		for i = #heals, 1, -1 do
			local id = heals[i];
			if (agent:GetPowerCost(id) < agent:GetPower(POWER_MANA)) then
				local value, threat = agent:GetSpellDamageAndThreat(target, id, true, false);
				threat = threat/threatDiv;
				if (threat < maxThreat) then
					threatFail = false;
				end
				-- shouldn't get too close...
				if ((value <= hpdiff or value / target:GetMaxHealth() < .5) and threat < maxThreat) then
					return id, value, threat;
				else
					-- Print("Spell", GetSpellName(id), id, " is too strong for this tank hp -", target:GetMaxHealth(), value, hpdiff, threat < maxThreat, target:GetName());
				end
			end
		end
		if (threatFail) then
			-- Print("Priest threat check failed");
		end
	end
	
	-- renew if not super urgent
	if (data.renew and agent:IsInCombat() and hp > 35 and not maxheal) then
		if (target:GetAttackersNum() == 0) then
			if (not target:HasAura(data.renew)) then
				return data.renew, agent:GetSpellDamageAndThreat(target, data.renew, true, false);
			elseif (not targetIsTank) then
				CmdHealReset(ai, agent, goal, false, true); -- do not linger
				return nil, nil, nil;
			end
			-- Print(agent:GetName(), "failed to pick renew, target already has = ", target:HasAura(data.renew));
		end
	end
	
	if (data.renew and maxheal and hp >= 70 and target:GetRole() ~= ROLE_TANK) then
		if (not target:HasAura(data.renew)) then
			return data.renew, agent:GetSpellDamageAndThreat(target, data.renew, true, false);
		else
			CmdHealReset(ai, agent, goal, false, true); -- do not linger
			return nil, nil, nil;
		end
	end
	
	-- find weakest spell
	for i = #heals, 1, -1 do
		local id = heals[i];
		if (agent:GetPowerCost(id) < agent:GetPower(POWER_MANA)) then
			local value, threat = agent:GetSpellDamageAndThreat(target, id, true, false);
			threat = threat/threatDiv;
			-- Print("Picking spell for", target:GetName(), "ratio =", value/hpdiff, "threat =", threat, maxThreat, GetSpellName(id), i);
			if (value / hpdiff < 1.1 and threat < maxThreat) then
				Print("Chose spell", id, value, threat, "missing", hpdiff, hp, target:GetName());
				return id, value, threat;
			end
		end
	end
	
	-- have to use something...
	if (agent:GetPowerCost(heals[1]) < agent:GetPower(POWER_MANA)) then
		local value, threat = agent:GetSpellDamageAndThreat(target, heals[1], true, false);
		threat = threat/threatDiv;
		if (threat < maxThreat) then
			return heals[1], value, threat;
		end
	end
	
	-- non combat backup
	if (#partyData.attackers == 0) then
		return heals[1], agent:GetSpellDamageAndThreat(target, heals[1], true, false);
	end
	
	-- Print(agent:GetName(), "failed to pick any heal spell, threat/mana/targethp check fail", agent:GetPowerPct(POWER_MANA), target:GetHealthPct(), target:GetName());
	return nil, nil, nil;
	
end

function PriestLevelHeal_ShouldInterruptPrecast(agent, target, precastable, hpdiff)
	if (precastable and agent:IsCastingHeal() and agent:IsInCombat()) then
	
		local spell = agent:GetCurrentSpellId();
		-- local weakest = weakestHealId == nil or spell == weakestHealId;
		local effect = agent:GetSpellDamageAndThreat(target, spell, true, false);
		return hpdiff < effect;
		
	end
	return false;
end

function PriestLevelHeal_InterruptCurrentHealingSpell(ai, agent, goal)
	agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	goal:SetNumber(0, 0); -- reset saved target health
	goal:SetNumber(1, 0); -- reset saved spell effect
end

function PriestLevelHeal_InterruptPrecastHeals(agent, goal, target, precastable, hpdiff)
	if (PriestLevelHeal_ShouldInterruptPrecast(agent, target, precastable, hpdiff) and agent:GetSpellCastLeft() < 250) then
		print"Interrupt precast"
		PriestLevelHeal_InterruptCurrentHealingSpell(ai, agent, goal);
		return true;
	end
	return false;
end

function PriestLevelHeal_InterruptBatchInvalidHeals(ai, agent, goal, partyData, target, castHealth, castEffect)
	
	-- never cast any spells
	if (castEffect <= 0) then
		return false;
	end
	
	if (target:GetHealthPct() > 99.0) then
		return true;
	end
	
	if (agent:IsCastingHeal()) then
	
		-- only check if health is higher by 10% or more
		if ((target:GetHealth() - castHealth)/target:GetMaxHealth() < 0.1) then
			return false;
		end
		
		local hpdiff = target:GetMaxHealth() - target:GetHealth();
		-- if (castEffect/hpdiff < 1.0) then
			-- return false;
		-- end
	
		local spell = agent:GetCurrentSpellId();
		local partyData = ai:GetPartyIntelligence():GetData();
		-- no longer care for threat checks here
		local newSpell = PriestLevelHeal_BestHealSpell(ai, agent, goal, ai:GetData(), target, target:GetHealthPct(), hpdiff, 9999999, partyData);
		if (newSpell ~= spell) then
			fmtprint("Spell %s %d interrupted due to batching diff=%.2f, eff=%.2f, new=%d",
				GetSpellName(spell), spell, hpdiff, castEffect, newSpell and newSpell or 0);
			PriestLevelHeal_InterruptCurrentHealingSpell(ai, agent, goal);
			return true;
		end
		
	end
	return false;
	
end

function GetAEThreat(ai, agent, partyData, targets)
	local minDiff = 99999999;
	if (#targets < 1) then return minDiff; end
	for idx,target in ipairs(targets) do
		if (not Unit_IsCrowdControlled(target)) then
			-- local tankThreat = Tank_GetTankThreat(partyData, target);
			local _,tankThreat = target:GetHighestThreat();
			local diff = (tankThreat - ai:GetStdThreat()) - target:GetThreat(agent);
			if (diff < minDiff) then
				minDiff = diff;
			end
		end
	end
	return math.max(0, minDiff);
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function PriestLevelHeal_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function PriestLevelHeal_Interrupt(ai, goal)

end
