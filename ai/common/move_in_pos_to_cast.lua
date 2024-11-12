--[[*******************************************************************************************
	Get within los and within max cast range of the target.
	On user to ensure buffer is < maxrange.
	Success as soon as spell can be cast.


	Parameter 0  Target to move to		guid
	Parameter 1  Spell Id				int
	Parameter 2  Max range buffer[yrd]	number	Successful if within (maxrange - buffer) distance

	Example of use
	-- Move in position to cast Frostbolt (Rank 1) with 5 yrd buffer
	goal:AddSubGoal( GOAL_COMMON_MoveInPosToCast, lifetime, guid, 116, 5.0 );
*********************************************************************************************]]
REGISTER_GOAL(GOAL_COMMON_MoveInPosToCast, "MoveInPosToCast");

--[[******************************************************
	Goal update
********************************************************]]
function MoveInPosToCast_Update(ai, goal)

	-- Get parameters
	local targetGuid 	= goal:GetParam(0);	-- spell target
	local spellId 		= goal:GetParam(1);	-- spell to cast
	local bufferDist 	= goal:GetParam(2);	-- go closer than max dist by this amount
	
	local agent 		= ai:GetPlayer();
	local target		= GetUnitByGuid(agent, targetGuid);
	
	-- target check
	if (nil == target) then
		return GOAL_RESULT_Success;
	end
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, spellId, bufferDist)) then
	
		if (not ai:IsFollowing(target)) then
			agent:ClearMotion();
			agent:MoveFollow(target, 0.1, 0.0);
		end
		return GOAL_RESULT_Continue;
	
	end
	
	-- made it
	agent:ClearMotion();
	return GOAL_RESULT_Success;
	
end


--[[******************************************************
	Goal termination
********************************************************]]
function MoveInPosToCast_Terminate(ai, goal)
	ai:GetPlayer():ClearMotion();
end


--[[******************************************************
	No activate, no interrupt
********************************************************]]
function MoveInPosToCast_Activate(ai, goal) end
function MoveInPosToCast_Interrupt(ai, goal)	return false; end
