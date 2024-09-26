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
	goal:AddSubGoal( GOAL_COMMON_FollowCLineRev, -1 );
*********************************************************************************************]]
REGISTER_GOAL(GOAL_COMMON_FollowCLineRev, "FollowCLineRev");

local SN_X = 0; -- destination x coordinate
local SN_Y = 1; -- destination y coordinate
local SN_Z = 2; -- destination z coordinate
local SN_S = 3; -- current segment of the line
local SN_L = 4; -- current line

local function GetNewPoint(agent, goal, party, l, s, r)
	local px,py,pz,ps,pl = party:GetNextCLineS(agent, l, s, r);
	
	goal:SetNumber(SN_X, px); -- destination x coordinate
	goal:SetNumber(SN_Y, py); -- destination y coordinate
	goal:SetNumber(SN_Z, pz); -- destination z coordinate
	goal:SetNumber(SN_S, ps); -- current segment of the line
	goal:SetNumber(SN_L, pl); -- current line
	return px,py,pz;
end

--[[******************************************************
	Goal activate
********************************************************]]
function FollowCLineRev_Activate(ai, goal)

	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	if (nil == party) then
		error("Agent has no party " .. agent:GetName());
	end
	
	if (not party:HasCLineFor(agent)) then
		error("Agent has no cline " .. agent:GetName());
	end
	
	-- get previous segment on the line
	local cx,cy,cz,cd,cs,cl = party:GetNearestCLineP(agent);
	GetNewPoint(agent, goal, party, cl, cs, goal:GetParam(0));
	Print(agent:GetName(), "begin follow cline", cl, "s", cs, cx, cy, cz);
	
end


--[[******************************************************
	Goal update
********************************************************]]
function FollowCLineRev_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	
	-- owner might leave our map
	local party = ai:GetPartyIntelligence();
	if (nil == party or false == party:HasCLineFor(agent)) then
		return GOAL_RESULT_Success;
	end
	
	local x = goal:GetNumber(SN_X); -- destination x coordinate
	local y	= goal:GetNumber(SN_Y); -- destination y coordinate
	local z = goal:GetNumber(SN_Z); -- destination z coordinate
	
	if (agent:GetDistance(x,y,z) < 1) then
		
		local r = goal:GetParam(0);
		local s = goal:GetNumber(SN_S); -- current segment of the line
		local l = goal:GetNumber(SN_L); -- current line
		-- out of points
		if ((s == 0 and r) or (not r and s + 1 == party:GetCLineLen(agent, l))--[[ and l == 0 ]]) then
			Print("FollowCLineRev_Update: out of points", r, "s", s, "l", l, agent:GetName());
			return GOAL_RESULT_Success;
		end
		
		-- update destination
		x,y,z = GetNewPoint(agent, goal, party, l, s, r);
		
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
function FollowCLineRev_Terminate(ai, goal)
	print("CLineRev terminated", ai:GetPlayer():GetName());
	ai:GetPlayer():ClearMotion();
end


--[[******************************************************
	No interrupt
********************************************************]]
function FollowCLineRev_Interrupt(ai, goal)	return false; end
