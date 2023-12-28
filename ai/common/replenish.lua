--[[*******************************************************************************************
	Replenishes health out of combat via food and drink consumables.
	Agent's data.food and data.drink must be defined to desired spell ids.

	Example of use
	-- Eats till full health and mana
	goal:AddSubGoal(GOAL_COMMON_Replenish, -1);
*********************************************************************************************]]

-- GOAL_COMMON_Replenish = 3;
REGISTER_GOAL(GOAL_COMMON_Replenish, "Replenish");

--[[******************************************************
	Goal start
********************************************************]]
function Replenish_Activate(ai, goal)
	local agent = ai:GetPlayer();
	if (false == agent:IsInCombat()) then
		agent:ClearMotion();
	end
end

--[[******************************************************
	Goal update
********************************************************]]
function Replenish_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	if (agent:IsInCombat() or agent:GetVictim()) then
		return GOAL_RESULT_Success;
	end
	
	local needToEat = agent:GetHealthPct() < 100.0;
	local needToDrink = (agent:GetPowerType() == POWER_MANA or agent:GetClass() == CLASS_DRUID) and agent:GetPowerPct(POWER_MANA) < 100.0;
	
	local data = ai:GetData();
	local isEating = agent:HasAura(data.food);
	local isDrinking = agent:HasAura(data.water);
	
	if ((needToEat or needToDrink) and agent:GetMotionType() ~= MOTION_IDLE) then
		agent:ClearMotion();
	end
	
	if (false == isEating and needToEat) then
		if (CAST_OK == agent:CastSpell(agent, data.food, true)) then
			agent:RemoveSpellCooldown(data.food);
		end
	end
	
	if (false == isDrinking and needToDrink) then
		if (CAST_OK == agent:CastSpell(agent, data.water, true)) then
			agent:RemoveSpellCooldown(data.water);
		end
	end
	
	local _interruptEat = (not needToEat and not isEating) or agent:GetHealthPct() > 99.0;
	local _interruptDrink = (not needToDrink and not isDrinking) or agent:GetPowerPct(POWER_MANA) > 99.0 or agent:GetPowerType() ~= POWER_MANA; 
	local _interruptOkay = _interruptEat and _interruptDrink;
	
	if (_interruptOkay) then
		return GOAL_RESULT_Success;
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Replenish_Terminate(ai, goal)
	ai:GetPlayer():SetStandState(STAND_STATE_STAND);
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
********************************************************]]
function Replenish_Interupt(ai, goal)	return false;end
