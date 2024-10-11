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

-- GOAL_COMMON_Totem = 11;
REGISTER_GOAL(GOAL_COMMON_Totem, "Totem");

local SN_CAST = 0;

--[[******************************************************
	Goal start
********************************************************]]
function Totem_Activate(ai, goal)
	local guid 	= goal:GetParam(0);
	local dist  = goal:GetParam(3);
	local angle = goal:GetParam(4);
	local agent = ai:GetPlayer();
	local target = GetUnitByGuid(agent, guid);
	if (target) then
		agent:ClearMotion();
		agent:MoveFollow(target, dist, angle);
	end
end

--[[******************************************************
	Goal update
********************************************************]]
function Totem_Update(ai, goal)
	
	local guid 	= goal:GetParam(0);
	local spell = goal:GetParam(1);
	local slot  = goal:GetParam(2);
	local agent = ai:GetPlayer();
	local target = GetUnitByGuid(agent, guid);
	
	if (nil == target) then
		return GOAL_RESULT_Failed;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
		return GOAL_RESULT_Continue;
	end
	
	if (1 == goal:GetNumber(SN_CAST) and goal:IsFinishTimer(SN_CAST) and nil ~= agent:GetTotemEntry(slot)) then
		return GOAL_RESULT_Success;
	end
	
	if (agent:GetDistance(target) <= goal:GetParam(3) + 1.0 and agent:GetMotionType() == MOTION_FOLLOW) then
		agent:ClearMotion();
	end
	
	if (0 == goal:GetNumber(SN_CAST) and false == agent:IsMoving() and false == target:IsMoving()) then
		if (CAST_OK == agent:CastSpell(agent, spell, true)) then
			goal:SetNumber(SN_CAST, 1);
			goal:SetTimer(SN_CAST, 0.5); -- for spell batching
		end
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Totem_Terminate(ai, goal)
	local agent = ai:GetPlayer();
	agent:ClearMotion();
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function Totem_Interupt(ai, goal)	return false;end
