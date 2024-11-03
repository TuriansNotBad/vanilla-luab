--[[*******************************************************************************************
	Common functions for healers.
	Notes:
		<blank>
*********************************************************************************************]]

local SHOULD_HEAL_UNABLE_TO_CAST         =  0;
local SHOULD_HEAL_REQUIREMENT_NOT_MET    = -1;
local SHOULD_HEAL_TARGET_IS_LOW_PRIORITY = -2;
local SHOULD_HEAL_TARGET_IS_HOSTILE      = -3;

function Healer_GetHealPriority(target, mp, hot, bTopAll)
	
	if (not target) then
		return 0;
	end
	
	local hp = target:GetHealthPct();
	if (target:IsTanking()) then
	
		-- never switch off unhealthy tank
		if (hp < 60) then
			return 4;
		end
		
		-- will switch to slightly hurt tank with nothing better todo
		if (hp < 85) then
			return 2;
		end
		
	end
	
	if (bTopAll) then
		if (hp < 30) then
			return 5;
		end
		if (hp < 80 and hot and false == target:HasAura(hot) and ROLE_TANK ~= target:GetRole()) then
			return 3;
		end
		if (hp < 70) then
			return 3;
		end
	end
	
	-- only heal nontank with hots
	if (nil == hot or false == target:HasAura(hot)) then
		-- only take on really endangered nontanks
		if ((hp < 55 and target:GetAttackersNum() > 0) or hp < 40) then
			return 3;
		end
		-- should we spare mana for nontanks at all
		if (hp < 60 or (mp > 0.90 and hp < 70)) then
			return 1;
		end
	end
	return 0;

end

function Healer_ShouldHealTarget(ai, target, bTopAll)
	
	local agent 	= ai:GetPlayer();
	local mp 		= agent:GetPowerPct(POWER_MANA)/100.0;
	local curTarget = ai:GetHealTarget();
	local data 		= ai:GetData();
	local cmd       = ai:CmdType();
	
	if (AI_IsIncapacitated(agent) or cmd == CMD_DISPEL or agent:GetStandState() ~= STAND_STATE_STAND or cmd == CMD_CC) then
		return SHOULD_HEAL_UNABLE_TO_CAST;
	end
	
	if (target:CanAttack(agent)) then
		return SHOULD_HEAL_TARGET_IS_HOSTILE;
	end
	
	-- take on anyone
	if (nil == curTarget and not agent:IsInCombat()) then
		return mp;
	end
	
	-- avoid switching constantly
	if (ai:CmdType() == CMD_HEAL and not ai:CmdIsRequirementMet()) then
		if (curTarget and not curTarget:IsTanking()) then
			if (target:IsTanking() and target:GetHealthPct() < 25.0) then
				return mp;
			end
		end
		return SHOULD_HEAL_REQUIREMENT_NOT_MET;
	end
	
	-- judge by priority
	local curPrio = Healer_GetHealPriority(curTarget, mp, data.hot, bTopAll or false == agent:IsInCombat());
	local tarPrio = Healer_GetHealPriority(target, mp, data.hot, bTopAll or false == agent:IsInCombat());
	if (tarPrio > curPrio) then
		return mp;
	end
	return SHOULD_HEAL_TARGET_IS_LOW_PRIORITY;
	
end

function Healer_GetTargetList(tracked, targets)
	
	local list = {};
	if (targets) then
		for i = 1, #targets do
			
			local target = targets[i]:GetPlayer();;
			if (target:IsAlive() and target:GetHealthPct() < 95) then
				table.insert(list, target);
			end
			
		end
	end
	if (tracked) then
		for i = 1, #tracked do
			
			local target = tracked[i];
			if (target:IsAlive() and target:GetHealthPct() < 95 and target:IsTargetableByHeal()) then
				table.insert(list, target);
			end
			
		end
	end
	local function sort(a,b)
		local asymmetry = a:GetRole() ~= b:GetRole();
		local tank, nonTank;
		if (asymmetry) then
			tank = (a:GetRole() == ROLE_TANK and a) or (b:GetRole() == ROLE_TANK and b);
			nonTank = (a:GetRole() ~= ROLE_TANK and a) or (b:GetRole() ~= ROLE_TANK and b);
		end
		if (tank) then
			if (tank:GetHealthPct() > 70 and nonTank:GetHealthPct() < 35) then
				return b:GetRole() ~= ROLE_TANK;
			end
			return a:GetRole() == ROLE_TANK;
		end
		return a:GetHealthPct() < b:GetHealthPct()
	end
	table.sort(list, sort);
	return list;
	
end

function Healer_AnyHealerOnTarget(healers, target)
	for i = 1, #healers do
		local ai = healers[i];
		if (ai:CmdType() == CMD_HEAL) then
			local guid = ai:CmdArgs();
			if (guid == target:GetGuid()) then
				return true;
			end
		end
	end
	return false;
end

--[[**************************************************************************
	Handle healing
****************************************************************************]]

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
	Print(agent:GetName(), "CMDHeal Reset");
	if (complete) then
		Print(agent:GetName(), "CMDHeal Complete");
		Command_Complete(ai, "CMD_HEAL completed");
	end
	return GOAL_RESULT_Continue;
end

function Healer_BestHealSpell(ai, agent, goal, data, target, hp, hpdiff, maxThreat, partyData)
	
	local heals = data.heals;
	local maxheal = Data_GetHealModeMax(data, partyData) or #partyData.attackers == 0;
	local targetIsTank = target:IsTanking() or (target:GetRole() == ROLE_TANK and target:GetAttackersNum() > 0);
	
	-- avoid div by zero
	local threatDiv = math.max(#partyData.attackers, 1);
	
	-- pick the strongest spell that makes sense
	if (targetIsTank) then
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
	if (data.hot and agent:IsInCombat() and hp > 35 and not maxheal) then
		if (target:GetAttackersNum() == 0) then
			if (not target:HasAura(data.hot)) then
				return data.hot, agent:GetSpellDamageAndThreat(target, data.hot, true, false);
			elseif (not targetIsTank) then
				CmdHealReset(ai, agent, goal, false, true); -- do not linger
				return nil, nil, nil;
			end
			-- Print(agent:GetName(), "failed to pick hot, target already has = ", target:HasAura(data.hot), data.hot);
		end
	end
	
	if (data.hot and maxheal and hp >= 70 and target:GetRole() ~= ROLE_TANK) then
		if (not target:HasAura(data.hot)) then
			return data.hot, agent:GetSpellDamageAndThreat(target, data.hot, true, false);
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


function Healer_InterruptCurrentHealingSpell(ai, agent, goal)
	agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	goal:SetNumber(0, 0); -- reset saved target health
	goal:SetNumber(1, 0); -- reset saved spell effect
end

function Healer_ShouldInterruptPrecast(agent, target, precastable, hpdiff)
	if (precastable and agent:IsCastingHeal() and agent:IsInCombat()) then
	
		local spell = agent:GetCurrentSpellId();
		-- local weakest = weakestHealId == nil or spell == weakestHealId;
		local effect = agent:GetSpellDamageAndThreat(target, spell, true, false);
		return hpdiff < effect;
		
	end
	return false;
end

function Healer_InterruptPrecastHeals(agent, goal, target, precastable, hpdiff)
	if (Healer_ShouldInterruptPrecast(agent, target, precastable, hpdiff) and agent:GetSpellCastLeft() < 250) then
		Print(agent:GetName(), "Interrupt precast");
		Healer_InterruptCurrentHealingSpell(ai, agent, goal);
		return true;
	end
	return false;
end

function Healer_InterruptBatchInvalidHeals(ai, agent, goal, partyData, target, castHealth, castEffect)
	
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
		-- no longer care for threat checks here
		local choose_spell = ai:GetData().SelectHealSpell or Healer_BestHealSpell;
		local newSpell = choose_spell(ai, agent, goal, ai:GetData(), target, target:GetHealthPct(), hpdiff, 9999999, partyData);
		if (newSpell ~= spell) then
			fmtprint("Spell %s %d interrupted due to batching diff=%.2f, eff=%.2f, new=%d",
				GetSpellName(spell), spell, hpdiff, castEffect, newSpell and newSpell or 0);
			Healer_InterruptCurrentHealingSpell(ai, agent, goal);
			return true;
		end
		
	end
	return false;
	
end

function Cmd_HealOnBeginOrEnd(ai)
	CmdHealReset(ai, ai:GetPlayer(), ai:GetTopGoal(), true);
end

function Cmd_HealUpdate(ai, agent, goal, party, data, partyData)
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
		Print(agent:GetName(), "Redundant reset", target and target:GetName(), target and target:GetHealthPct(), target and target:CanAttack(agent));
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
		
		if (not Healer_InterruptPrecastHeals(agent, goal, target, isTank, hpdiff)
			and not Healer_InterruptBatchInvalidHeals(ai, agent, goal, partyData, target, goal:GetNumber(0), goal:GetNumber(1)))
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
	
	data.UsePotions(agent, goal, data, Data_GetDefensePotion(data, encounter));
	
	local maxThreat;
	if (partyData.attackers.ignoreThreat) then
		maxThreat = 5000.0;
	else
		if (target:IsTanking() and hp < 50) then
			maxThreat = 5000.0;
		else
			maxThreat = Dps_GetAEThreat(ai, agent, partyData.attackers, ai:GetStdThreat());
		end
	end
	local choose_spell = ai:GetData().SelectHealSpell or Healer_BestHealSpell;
	local spell,effect,effthreat = choose_spell(ai, agent, goal, data, target, hp, hpdiff, maxThreat, partyData);
	
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
		Print(agent:GetName(), "spell cast begin", GetSpellName(spell), spell, maxThreat, effect, effthreat, target:GetName(), hpdiff, target:GetHealthPct());
		goal:SetNumber(0, target:GetHealth()); -- remember target health at cast time
		goal:SetNumber(1, effect); -- remember healing amount of our spell
		-- if we're precasting we don't want this to block us from healing others
		-- this way we can interrupt any precast to put a hot on a dps or heal an actual low tank
		if (Healer_ShouldInterruptPrecast(agent, target, isTank, hpdiff) and not ai:CmdIsRequirementMet()) then
			print("Progress added");
			ai:CmdAddProgress();
		end
	end
	
	return GOAL_RESULT_Continue;

end
