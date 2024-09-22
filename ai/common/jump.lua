--[[*******************************************************************************************
*********************************************************************************************]]

-- GOAL_COMMON_Jump = 15;
REGISTER_GOAL(GOAL_COMMON_Jump, "Jump");

--[[******************************************************
	Goal update
********************************************************]]
function Jump_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local x = goal:GetParam(0); -- destination x coordinate
	local y	= goal:GetParam(1); -- destination y coordinate
	local z = goal:GetParam(2); -- destination z coordinate
	local o = goal:GetParam(3); -- destination orientation
	
	-- and move
	if (goal:GetNumber(0) ~= 1 and not ai:IsMovingTo(x,y,z)) then
		agent:ClearMotion();
		agent:MovePoint(x,y,z,false);
	end
	
	-- arrived or interrupted
	if (agent:GetDistance(x,y,z) < 1 or agent:GetMotionType() ~= MOTION_POINT) then
		if (goal:GetNumber(0) ~= 1) then
			goal:SetNumber(0, 1);
			goal:SetTimer(0, 5);
			agent:ClearMotion();
		end
	end
	
	if (goal:GetNumber(0) == 1) then
		
		if (goal:IsFinishTimer(0)) then
			return GOAL_RESULT_Failed;
		end
		
		if (math.abs(agent:GetOrientation() - o) > 0.05) then
			if (not agent:IsMoving()) then
				agent:MoveFacing(o);
			end
		else
			
			if (goal:GetNumber(1) ~= 1) then
				goal:SetNumber(1, 1);
				ai:Jump(6, 10);
			end
			
		end
		
	end
	
	if (goal:GetNumber(1) == 1 and not ai:IsFalling()) then
		return GOAL_RESULT_Success;
	end
	
	return GOAL_RESULT_Continue;
	
end


--[[******************************************************
	Goal termination
********************************************************]]
function Jump_Terminate(ai, goal)
	ai:GetPlayer():ClearMotion();
end


--[[******************************************************
	No activate, no interrupt
********************************************************]]
function Jump_Interrupt(ai, goal)	return false; end
function Jump_Activate(ai, goal)	end
