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

-- GOAL_COMMON_Pull = 2;
REGISTER_GOAL(GOAL_COMMON_Pull, "Pull");

local SN_X    = 0; -- Make distance to X coordinate
local SN_Y    = 1; -- Make distance to Y coordinate
local SN_Z    = 2; -- Make distance to Z coordinate
local SN_FAR  = 8; -- Flag to use far pull (usually caused by ranged enemies)
local SN_FLAG = 9; -- Flag to only attempt distancing once

--[[******************************************************
	Goal start
********************************************************]]
function Pull_Activate(ai, goal)
	
	-- get parameters
	local guid 	= goal:GetParam(0);	-- initial enemy guid
	
	local agent = ai:GetPlayer();
	local target = GetUnitByGuid(agent, guid);
	if (nil == target) then
		return;
	end
	-- coords for update
	local x,y,z = target:GetPosition();
	goal:SetNumber(SN_X, x);
	goal:SetNumber(SN_Y, y);
	goal:SetNumber(SN_Z, z);
	-- reset motion master if needed and go
	agent:ClearMotion();
	agent:Attack(target);
	agent:MoveChase(target, 2.0, 0.7, 1.0, 0.0, math.pi, false, true);
	-- print("Begin pull");
	
	if (nil == ai:GetData().PullRotation) then
		error("No pull rotation defined for agent " .. agent.GetName(agent));
	end
	
end

--[[******************************************************
	Goal update
********************************************************]]
function Pull_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local guid 	= goal:GetParam(0);	-- initial enemy guid
	local target = GetUnitByGuid(agent, guid);
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	if (nil == target) then
		goal:ClearSubGoal();
		return GOAL_RESULT_Failed;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted()) then
		return GOAL_RESULT_Continue;
	end
	
	if (false == target:IsAlive()) then
		goal:ClearSubGoal();
		print("Common pull interrupted due to lost target");
		return GOAL_RESULT_Success;
	end
	
	-- is current victim pulled yet
	if (target:GetVictim() == nil) then
		ai:GetData().PullRotation(ai, agent, target);
		return GOAL_RESULT_Continue;
	end
	
	-- target engaged
	local x = goal:GetNumber(SN_X); -- first target original X coord
	local y = goal:GetNumber(SN_Y); -- first target original Y coord
	local z = goal:GetNumber(SN_Z); -- first target original Z coord
	
	-- give 1 chance for GOAL_COMMON_FollowCLineRev to create space
	if (false == ai:IsCLineAvailable()) then
		return GOAL_RESULT_Success;
	end
	
	-- ranged detection...
	if (goal:GetNumber(SN_FAR) == 0) then
		for i,attacker in ipairs(partyData.attackers) do
			if (attacker:GetMotionType() == MOTION_IDLE) then
				goal:SetNumber(SN_FAR, 1);
				Print("Using far pull because of", attacker:GetName());
			end
		end
	end
	
	-- if (goal:GetParam(3) == nil) then
		local pullDist = 50;
		if (goal:GetNumber(8) == 1) then
			pullDist = 80;
		end
		if (agent:GetDistance(x,y,z) < pullDist) then
			if (0 == goal:GetNumber(SN_FLAG)) then
				goal:AddSubGoal(GOAL_COMMON_FollowCLineRev, 15, not partyData.reverse);
				goal:SetNumber(SN_FLAG, 1);
			end
		else
			-- distance reached, stop
			goal:ClearSubGoal();
		end
	-- else
		-- local x = goal:GetParam(3); -- tanking place X coord
		-- local y = goal:GetParam(4); -- tanking place Y coord
		-- local z = goal:GetParam(5); -- tanking place Z coord
		-- if (0 == goal:GetNumber(9) and agent:GetDistance(x,y,z) > 3 and agent:DoesPathExist(x,y,z)) then
			-- goal:AddSubGoal(GOAL_COMMON_MoveToSomewhere, 15, 0, 0, 1);
			-- goal:SetNumber(9, 1);
		-- end
	-- end
	
	-- once subgoal is done, we're done
	if (goal:GetSubGoalNum() == 0) then
		return GOAL_RESULT_Success;
	end
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Pull_Terminate(ai, goal)
	local agent = ai:GetPlayer();
	agent:ClearMotion();
	agent:AttackStop();
	print("Pull_Terminate", agent:GetName());
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function Pull_Interupt(ai, goal)	return false;end
