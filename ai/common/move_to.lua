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
	goal:AddSubGoal( GOAL_COMMON_MoveTo, -1 );
*********************************************************************************************]]

-- GOAL_COMMON_MoveTo = 6;
REGISTER_GOAL(GOAL_COMMON_MoveTo, "MoveTo");

--[[******************************************************
	Goal update
********************************************************]]
function MoveTo_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local x = goal:GetParam(0); -- destination x coordinate
	local y	= goal:GetParam(1); -- destination y coordinate
	local z = goal:GetParam(2); -- destination z coordinate
	
	-- and move
	if (not ai:IsMovingTo(x,y,z)) then
		agent:ClearMotion();
		agent:MovePoint(x,y,z,false);
	end
	
	-- arrived or interrupted
	if (agent:GetDistance(x,y,z) < 1 or agent:GetMotionType() ~= MOTION_POINT) then
		return GOAL_RESULT_Success;
	end
	
	return GOAL_RESULT_Continue;
	
end


--[[******************************************************
	Goal termination
********************************************************]]
function MoveTo_Terminate(ai, goal)
	ai:GetPlayer():ClearMotion();
end


--[[******************************************************
	No activate, no interrupt
********************************************************]]
function MoveTo_Interrupt(ai, goal)	return false; end
function MoveTo_Activate(ai, goal)	end
