
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
		if (spell:CheckCreatureType(attacker) and not Unit_IsCrowdControlled(attacker) and not party:IsCC(attacker)) then
			
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

function Unit_IsCrowdControlled(unit)
	return unit:HasAuraType(AURA_MOD_CONFUSE) or unit:HasAuraType(AURA_MOD_FEAR) or unit:HasAuraType(AURA_MOD_STUN);
end

--[[**************************************************************************
	Returns spellid for shifting into form
****************************************************************************]]
function GetSpellForForm(form)
	if (form == FORM_CAT) then
		return SPELL_DRD_CAT_FORM;
	elseif (form == FORM_BEAR) then
		return SPELL_DRD_BEAR_FORM;
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
