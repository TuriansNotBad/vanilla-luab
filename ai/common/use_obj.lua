--[[*******************************************************************************************
	Use a game object.

	Parameter 0  Game object [Guid]

	Example of use
	-- Use some object
	goal:AddSubGoal(GOAL_COMMON_UseObj, 10, objectGuid);
*********************************************************************************************]]

-- GOAL_COMMON_UseObj = 12;
REGISTER_GOAL(GOAL_COMMON_UseObj, "UseObj");

--[[******************************************************
	Goal update
********************************************************]]
function UseObj_Update(ai, goal)
	
	local guid 	= goal:GetParam(0);
	local agent = ai:GetPlayer();
	
	if (not agent:CanUseObj(guid)) then
		
		if (goal:GetSubGoalNum() == 0) then
			local x,y,z = agent:GetPositionOfObj(guid);
			goal:AddSubGoal(GOAL_COMMON_MoveTo, goal:GetLife(), x, y, z, false);
		end
	
	else
		
		agent:UseObj(guid);
		return GOAL_RESULT_Success;
		
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal start
********************************************************]]
function UseObj_Activate(ai, goal) end

--[[******************************************************
	Goal terminate
********************************************************]]
function UseObj_Terminate(ai, goal) end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function UseObj_Interupt(ai, goal)	return false;end
