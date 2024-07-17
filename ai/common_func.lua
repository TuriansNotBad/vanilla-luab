
function Party_GetCCTarget(spellid, party, attackers, minCount, allowNonRanged)
	
	if (#attackers < minCount) then
		return nil;
	end
	
	local spell = Spell_GetSpellFromId(spellid);
	if (nil == spell) then
		error("Party_GetCCTarget: spell " .. tostring(spellid) .. "doesn't exist");
	end
	
	local contender;
	-- local agent = ai:GetPlayer();
	for i = #attackers, 1, -1 do
	
		local attacker = attackers[i];
		-- print(i, attacker:GetAttackersN());
		-- Print(spell:CheckCreatureType(attacker), Unit_IsCrowdControlled(attacker), party:IsCC(attacker), attacker:IsRanged(), contender, allowNonRanged)
		if (spell:CheckCreatureType(attacker) and not Unit_IsCrowdControlled(attacker) and not party:IsCC(attacker) and not attacker:IsImmuneToSpell(spellid)) then
			
			if (attacker:IsPlayer()) then
				return attacker;
			end
			
			if (attacker:IsRanged()) then
				return attacker;
			end
			
			if (nil == contender) then
				contender = attacker;
			end
			
		end
		
	end
	
	if (allowNonRanged) then
		-- print("Returns " .. contender:GetName())
		return contender;
	end
	
end

function AI_Replenish(agent, goal, hpThresh, mpThresh, form)
	
	if (agent:GetLevel() < 5 or agent:IsInCombat()) then
		return;
	end
	
	local mpCheck = mpThresh >= 0 and agent:GetPowerPct(POWER_MANA) < mpThresh;
	if ((agent:GetHealthPct() < hpThresh or mpCheck) and goal:GetSubGoalNum() == 0) then
		if (form) then
			local ai = agent:GetAI();
			if (ai) then ai:SetForm(form); end
			if (form ~= agent:GetShapeshiftForm()) then
				return;
			end
		end
		goal:AddSubGoal(GOAL_COMMON_Replenish, 60);
	end

end

function AI_GetDefaultChaseSeparation(target)
	local cr = target:GetCombatReach();
	local r  = target:GetBoundingRadius();
	return math.max(1.0, (cr - r)/2);
end

function AI_DistanceIfNeeded(ai, agent, goal, party, dist2close, atkTarget)
	if (ai:IsCLineAvailable() and 0 == agent:GetAttackersNum()) then
		local data = party:GetData();
		local enemy = Unit_GetFirstEnemyInR(agent, dist2close, false, data.attackers);
		if (enemy) then
			local seekDist = atkTarget and 18 - enemy:GetDistance(atkTarget) or 15;
			if (seekDist - 3 > 2) then
				local x,y,z = party:GetCLinePInLosAtD(agent, enemy, atkTarget or enemy, seekDist - 3, seekDist, 1, not data.reverse);
				if (x) then
					goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, x, y, z);
					print(agent:GetName(), "distancing", x, y, z);
					return true;
				end
			end
		end
	end
	return false;
end

function Unit_AECheck(agent, r, minCount, checkCC, attackers)
	
	local result = 0;
	for i = 1, #attackers do
		local attacker = attackers[i];
		if (attacker:GetDistance(agent) <= r) then
			if (checkCC and Unit_IsCrowdControlled(attacker)) then
				return false;
			end
			result = result + 1;
		end
	end
	return minCount <= result;
	
end

function Unit_AECCCheck(agent, party, r, attackers)
	
	for i = 1, #attackers do
		local attacker = attackers[i];
		if (attacker:GetDistance(agent) <= r) then
			if (party:IsCC(attacker) or Unit_IsCrowdControlled(attacker)) then
				return false;
			end
		end
	end
	return true;
	
end

function Unit_GetFirstEnemyInR(agent, r, includeCC, attackers)
	
	for i = 1, #attackers do
		local attacker = attackers[i];
		if (attacker:GetDistance(agent) <= r) then
			if (includeCC or false == Unit_IsCrowdControlled(attacker)) then
				return attacker;
			end
		end
	end
	
end

function Unit_IsCrowdControlled(unit)
	return unit:HasAuraType(AURA_MOD_CONFUSE) or unit:HasAuraType(AURA_MOD_FEAR) or unit:HasAuraType(AURA_MOD_STUN);
end

--[[**************************************************************************
	Returns spellid for shifting into form
****************************************************************************]]
function GetSpellForForm(form)
	-- druid
	if (form == FORM_CAT) then
		return SPELL_DRD_CAT_FORM;
	elseif (form == FORM_BEAR) then
		return SPELL_DRD_BEAR_FORM;
	-- warrior
	elseif (form == FORM_DEFENSIVESTANCE) then
		return SPELL_WAR_DEFENSIVE_STANCE;
	elseif (form == FORM_BATTLESTANCE) then
		return SPELL_WAR_BATTLE_STANCE;
	elseif (form == FORM_BERSERKERSTANCE) then
		return SPELL_WAR_BERSERKER_STANCE;
	end
	error("GetSpellForForm: spell not defined for form " .. tostring(form));
end

--[[**************************************************************************
	Returns table containing the entire spell chain
****************************************************************************]]
local function AI_GetEntireSpellChain(ai, spellID)
	local first = ai:GetSpellChainFirst(spellID);
	local current = spellID;
	local result = {spellID};
	while (true) do
		
		local previous = ai:GetSpellChainPrev(current);
		if (current == previous) then
			break;
		end
		current = previous;
		table.insert(result, current);
		-- print(current);
		
		if (current == first) then
			break;
		end
		
	end
	return result;
end

--[[**************************************************************************
	Cancel the entire spell chain
****************************************************************************]]
function AI_CancelAuraSpellChain(ai, spellID)
	local t = AI_GetEntireSpellChain(ai, spellID);
	local agent = ai:GetPlayer();
	for i = 1, #t do
		agent:CancelAura(t[i]);
	end
end

--[[**************************************************************************
	Cancel agent buffs
****************************************************************************]]
function AI_CancelAgentBuffs(ai)
	-- druid
	AI_CancelAuraSpellChain(ai, SPELL_DRD_MARK_OF_THE_WILD);
	AI_CancelAuraSpellChain(ai, SPELL_DRD_GIFT_OF_THE_WILD);
	AI_CancelAuraSpellChain(ai, SPELL_DRD_THORNS);
	-- mage
	AI_CancelAuraSpellChain(ai, SPELL_MAG_ARCANE_INTELLECT);
	Builds.Select(ai, "1.4.2", SPELL_MAG_ARCANE_BRILLIANCE, AI_CancelAuraSpellChain);
	AI_CancelAuraSpellChain(ai, SPELL_PRI_PRAYER_OF_FORTITUDE);
	AI_CancelAuraSpellChain(ai, SPELL_MAG_FROST_ARMOR);
	AI_CancelAuraSpellChain(ai, SPELL_MAG_ICE_ARMOR);
	AI_CancelAuraSpellChain(ai, SPELL_MAG_MAGE_ARMOR);
	-- priest
	AI_CancelAuraSpellChain(ai, SPELL_PRI_POWER_WORD_FORTITUDE);
	AI_CancelAuraSpellChain(ai, SPELL_PRI_PRAYER_OF_FORTITUDE);
end

function AI_HasMotionAura(agent)
	return agent:HasAuraType(AURA_MOD_FEAR);
end

function AI_IsIncapacitated(agent)
	return not agent:IsAlive() or agent:HasLostControl();
end

function AI_IsAvailableToCast(ai, agent, target, spellid)
	-- agent has control
	if (agent:HasLostControl() or false == agent:IsAlive()) then
		return false;
	end
	-- cast is not possible
	if (not agent:HasEnoughPowerFor(spellid, true) or not agent:IsSpellReady(spellid)) then
		return false;
	end
	return true;
end

function AI_TargetInHoldingArea(target, area)
	if (area.tp == "circle") then
		return target:GetDistance(area.pos.x, area.pos.y, area.pos.z) < area.r;
	end
	error("AI_TargetInHoldingArea: area type NYI, type = " .. area.tp);
end

function GetDungeon(map)
	local data = t_dungeons[map];
	if (nil == data) then
		return;
	end
	return data.encounters;
end

function GetEncounter(map, party, partyData)

	local data = GetDungeon(map);
	if (nil == data) then
		return;
	end
	
	for i,encounter in ipairs(data) do
		if (encounter.test and encounter.test(party, partyData)) then
			return encounter;
		end
	end
	
	for i,attacker in ipairs(partyData.attackers) do
		for i,encounter in ipairs(data) do
			if (encounter.name == attacker:GetName()) then
				return encounter;
			end
		end
	end
	
end

function AI_DummyActions() return false; end
