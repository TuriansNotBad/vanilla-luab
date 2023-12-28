--[[*******************************************************************************************
	Pulls an enemy.
	Tries to pull far back to move ranged units if CLine is available.

	Parameter 0  Initial target [Guid]

	goal:SetNumber() usage.
		0: Make distance to X coordinate
		1: Make distance to Y coordinate
		2: Make distance to Z coordinate
		9: Flag to only attempt distancing once

	Example of use
	-- Pulls target
	goal:AddSubGoal(GOAL_COMMON_Pull, -1, target:GetGuid());
*********************************************************************************************]]

-- GOAL_COMMON_Buff = 4;
REGISTER_GOAL(GOAL_COMMON_Buff, "Buff");

--[[******************************************************
	Goal start
********************************************************]]
function Buff_Activate(ai, goal)
	local guid = goal:GetParam(0);
	local spell = goal:GetParam(1);
	local key = goal:GetParam(2);
	local target = GetPlayerByGuid(guid);
	
	if (target) then
		if (target:HasAura(spell)) then
			target:CancelAura(spell);
		end
		-- AI_PostBuff(ai:GetPlayer():GetGuid(), guid, key, true);
	end
end

--[[******************************************************
	Goal update
********************************************************]]
function Buff_Update(ai, goal)
	
	local guid 	= goal:GetParam(0);
	local spell = goal:GetParam(1);
	local key = goal:GetParam(2);
	local target = GetPlayerByGuid(guid);
	local agent = ai:GetPlayer();
	
	if (nil == target or false == target:IsAlive()) then
		return GOAL_RESULT_Failed;
	end
	
	if (target:HasAura(spell)) then
		return GOAL_RESULT_Success;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
		return GOAL_RESULT_Continue;
	end
	
	if (CAST_OK ~= agent:IsInPositionToCast(target, spell, 5.0)) then
		goal:AddSubGoal(GOAL_COMMON_MoveInPosToCast, 10.0, guid, spell, 5.0);
	else
		if (CAST_OK == agent:CastSpell(target, spell, false)) then
			Print(agent:GetName(), "buffed", target:GetName(), "with", key, "spell", spell, GetSpellName(spell));
		end
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Buff_Terminate(ai, goal)
	local agent = ai:GetPlayer();
	local guid 	= goal:GetParam(0);
	local key 	= goal:GetParam(2);
	
	AI_UnpostBuff(guid, key);
	if (ai:CmdType() == CMD_BUFF) then
		Print("CmdBuff complete", agent:GetName());
		ai:CmdComplete();
	end
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function Buff_Interupt(ai, goal)	return false;end
