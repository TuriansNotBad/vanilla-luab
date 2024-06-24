--[[*******************************************************************************************
	Follow CLine in reverse.
	Party and CLine must exist.
	Success when out of points or CLine no longer valid.


	goal:SetNumber() usage:
		0： destination x coordinate
		1： destination y coordinate
		2： destination z coordinate
		3： current segment of the line
		4: current line

	Example of use
	-- Follows CLine in reverse until out of points
	goal:AddSubGoal( GOAL_COMMON_GotoCLinePos, -1 );
*********************************************************************************************]]
-- local GOAL_COMMON_GotoCLinePos = 6;
-- REGISTER_GOAL(GOAL_COMMON_GotoCLinePos, "GotoCLinePos");

local SN_X = 0; -- destination x coordinate
local SN_Y = 1; -- destination y coordinate
local SN_Z = 2; -- destination z coordinate
local SN_S = 3; -- current segment of the line
local SN_L = 4; -- current line

--[[******************************************************
	Goal activate
********************************************************]]
function GotoCLinePos_Activate(ai, goal)

	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	if (nil == party) then
		error("Agent has no party " .. agent:GetName());
	end
	
	if (not party:HasCLineFor(agent)) then
		error("Agent has no cline " .. agent:GetName());
	end
	
	local guid = goal:GetParam(0);
	local target = GetUnitByGuid(agent, guid);
	
	-- get previous segment on the line
	local partyData = party:GetData();
	if (target) then
		local x,y,z = party:GetCLinePInLosAtD(agent, target, target, 10, 15, 1, not goal:GetParam(1));
		if (x) then
			goal:SetNumber(SN_X, x);
			goal:SetNumber(SN_Y, y);
			goal:SetNumber(SN_Z, z);
		end
	end
	print"CLineGoto Active"
	
end


--[[******************************************************
	Goal update
********************************************************]]
function GotoCLinePos_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local x = goal:GetNumber(SN_X); -- destination x coordinate
	
	if (x == 0) then
		return GOAL_RESULT_Failed;
	end
	
	local y	= goal:GetNumber(SN_Y); -- destination y coordinate
	local z = goal:GetNumber(SN_Z); -- destination z coordinate
	
	if (agent:GetDistance(x,y,z) < 1) then
		return GOAL_RESULT_Success;
	end
	
	-- and move
	if (not ai:IsMovingTo(x,y,z)) then
		agent:ClearMotion();
		agent:MovePoint(x,y,z,false);
	end
	return GOAL_RESULT_Continue;
	
end


--[[******************************************************
	Goal termination
********************************************************]]
function GotoCLinePos_Terminate(ai, goal)
	print("CLineRev terminated");
	ai:GetPlayer():ClearMotion();
end


--[[******************************************************
	No interrupt
********************************************************]]
function GotoCLinePos_Interrupt(ai, goal)	return false; end
