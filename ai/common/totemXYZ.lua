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

-- GOAL_COMMON_TotemXYZ = 14;
REGISTER_GOAL(GOAL_COMMON_TotemXYZ, "TotemXYZ");

local SN_CAST = 0;
local SN_X = 1;
local SN_Y = 2;

--[[******************************************************
	Goal start
********************************************************]]
function TotemXYZ_Activate(ai, goal)
	local x,y,z	= goal:GetParam(0), goal:GetParam(1), goal:GetParam(2);
	local dist  = goal:GetParam(5);
	local angle = goal:GetParam(6);
	
	local destX = x + dist * math.cos(angle);
	local destY = y + dist * math.sin(angle);
	goal:SetNumber(SN_X, destX);
	goal:SetNumber(SN_Y, destY);
	
	local agent = ai:GetPlayer();
	agent:ClearMotion();
	agent:MovePoint(destX,destY,z,false);
end

--[[******************************************************
	Goal update
********************************************************]]
function TotemXYZ_Update(ai, goal)
	
	local spell = goal:GetParam(3);
	local slot  = goal:GetParam(4);
	local agent = ai:GetPlayer();
	local x,y = goal:GetNumber(SN_X), goal:GetNumber(SN_Y);
	local myX,myY = agent:GetPosition();
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
		return GOAL_RESULT_Continue;
	end
	
	if (1 == goal:GetNumber(SN_CAST) and goal:IsFinishTimer(SN_CAST) and nil ~= agent:GetTotemEntry(slot)) then
		return GOAL_RESULT_Success;
	end
	
	if (0 == goal:GetNumber(SN_CAST) and (dist2sqr(x,y,myX,myY) < 3 or agent:GetMotionType() ~= MOTION_POINT)) then
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
function TotemXYZ_Terminate(ai, goal)
	local agent = ai:GetPlayer();
	agent:ClearMotion();
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function TotemXYZ_Interupt(ai, goal)	return false;end
