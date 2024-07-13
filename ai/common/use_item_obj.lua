--[[*******************************************************************************************
	Use an item at game object

	Parameter 0  Game object [Guid]
	Parameter 1  Item entry  [int]
	Parameter 2  Spell slot  [int] (0, 2)

	Example of use
	-- Use Hakkari Blood
	goal:AddSubGoal(GOAL_COMMON_UseItemObj, 10, flame, self.HakkariBlood, 0);
*********************************************************************************************]]

-- GOAL_COMMON_UseItemObj = 12;
REGISTER_GOAL(GOAL_COMMON_UseItemObj, "UseItemObj");

--[[******************************************************
	Goal update
********************************************************]]
function UseItemObj_Update(ai, goal)
	
	local guid 	= goal:GetParam(0);
	local item  = goal:GetParam(1);
	local spell = goal:GetParam(2);
	local agent = ai:GetPlayer();
	
	-- must have the item
	if (not agent:HasItemCount(item, 1)) then
		return GOAL_RESULT_Failed;
	end
	
	-- item could have cast time
	if (agent:IsNonMeleeSpellCasted()) then
		return GOAL_RESULT_Continue;
	end
	
	if (not agent:CanUseObj(guid)) then
		
		if (goal:GetSubGoalNum() == 0) then
			Print("GOAL_COMMON_UseItemObj: moving to object", agent:GetName(), guid);
			local x,y,z = agent:GetPositionOfObj(guid);
			goal:AddSubGoal(GOAL_COMMON_MoveTo, goal:GetLife(), x, y, z, false);
		end
	
	else
	
		if (agent:IsMoving() or goal:GetSubGoalNum() > 0) then
			Print("GOAL_COMMON_UseItemObj: stopping motion", agent:GetName(), guid);
			agent:ClearMotion();
			goal:ClearSubGoal();
			return GOAL_RESULT_Continue;
		end
		
		if (goal:GetNumber(0) == 0) then
			Print("GOAL_COMMON_UseItemObj: item used by", agent:GetName());
			agent:UseItem(guid, item, spell);
			goal:SetNumber(0, 1);
		else
			Print("GOAL_COMMON_UseItemObj: success", agent:GetName());
			return GOAL_RESULT_Success;
		end
		
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal start
********************************************************]]
function UseItemObj_Activate(ai, goal)Print("GOAL_COMMON_UseItemObj: activate", ai:GetPlayer():GetName());end

--[[******************************************************
	Goal terminate
********************************************************]]
function UseItemObj_Terminate(ai, goal) end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function UseItemObj_Interupt(ai, goal)	return false;end
