--[[*******************************************************************************************
*********************************************************************************************]]

-- GOAL_COMMON_Loot = 17;
REGISTER_GOAL(GOAL_COMMON_Loot, "Loot");

--[[******************************************************
	Goal update
********************************************************]]
function Loot_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local guid,itemid = goal:GetParam(0),goal:GetParam(1);
	local corpse = GetUnitByGuid(agent, guid);
	
	if (not (corpse and corpse:IsDead())) then
		Print("GOAL_COMMON_Loot failed, corpse not found. Guid =", guid);
		return GOAL_RESULT_Failed;
	end
	
	if (not agent:CanLootCorpse(corpse,0)) then
		Print("GOAL_COMMON_Loot failed, nothing to loot. Guid =", guid);
		return GOAL_RESULT_Failed;
	end
	
	-- pretend like we need to be close
	if (agent:GetDistance(corpse) > 2) then
		if (false == ai:IsFollowing(corpse)) then
			agent:ClearMotion();
			agent:MoveFollow(corpse,.1,.1);
		end
	else
		-- loot
		if (agent:IsMoving() or agent:GetMotionType() == MOTION_FOLLOW) then
			agent:ClearMotion();
			agent:StopMoving();
		end
		agent:LootCorpse(corpse, itemid);
		return GOAL_RESULT_Success;
	end
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Loot_Terminate(ai, goal)
	ai:GetPlayer():ClearMotion();
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function Loot_Interupt(ai, goal)	return false;end
function Loot_Activate(ai, goal)	end
