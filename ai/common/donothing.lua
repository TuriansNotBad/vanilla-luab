--[[*******************************************************************************************
	Stops attacking and movement and does nothing.

	Example of use
	-- Does nothing, until replaced.
	ai:AddTopGoal( GOAL_COMMON_DoNothing, -1 );
*********************************************************************************************]]

-- GOAL_COMMON_DoNothing = 9;
REGISTER_GOAL(GOAL_COMMON_DoNothing, "DoNothing");


--[[******************************************************
	Goal start
********************************************************]]
function DoNothing_Activate(ai, goal)
	local agent = ai:GetPlayer();
	agent:AttackStop();
	agent:ClearMotion();
end


--[[******************************************************
	Goal update
********************************************************]]
function DoNothing_Update(ai, goal)
	return GOAL_RESULT_Continue;
end


--[[******************************************************
	Goal terminate
********************************************************]]
function DoNothing_Terminate(ai, goal) end


--[[******************************************************
--  Interrupt
--  Return true if interrupted.
--  If not interrupted, the interrupt is handled by the goal or logic part of the next layer above.
********************************************************]]
function DoNothing_Interupt(ai, goal)	return false;end

