--[[*******************************************************************************************
*********************************************************************************************]]

-- GOAL_COMMON_Trade = 16;
REGISTER_GOAL(GOAL_COMMON_Trade, "Trade");

local SN_DONE      = 0;
local SN_STARTED   = 1;
local SN_ADDEDITEM = 2;
local SN_BEGAN     = 3;
local ST_PAUSE     = 0;

--[[******************************************************
	Goal start
********************************************************]]
function Trade_Activate(ai, goal)
end

--[[******************************************************
	Goal update
********************************************************]]
function Trade_Update(ai, goal)
	
	if (not goal:IsFinishTimer(ST_PAUSE)) then
		return GOAL_RESULT_Continue;
	end
	
	if (goal:GetNumber(SN_DONE) == 1 and not ai:TradeIsInProgress()) then
		return GOAL_RESULT_Success;
	end

	local guid,bag,slot = ai:CmdArgs();
	local target = GetPlayerByGuid(guid);
	if (not target) then
		Print("GOAL_COMMON_Trade failed, target not found -", guid);
		return GOAL_RESULT_Failed;
	end
	
	if (not ai:EquipHasItemInSlot(bag, slot, true)) then
		Print("GOAL_COMMON_Trade failed, item not found -", bag, slot);
		return GOAL_RESULT_Failed;
	end
	
	local agent = ai:GetPlayer();
	
	-- no trade in combat
	if (agent:IsInCombat()) then
		Print("GOAL_COMMON_Trade failed, agent is in combat");
		return GOAL_RESULT_Failed;
	end
	
	if (target:GetDistance(agent) > 2) then
		if (agent:GetMotionType() ~= MOTION_FOLLOW) then
			agent:MoveFollow(target, 1, 0);
		end
	else
		if (agent:GetMotionType() == MOTION_FOLLOW) then
			agent:ClearMotion();
		end
		-- initiate trade
		if (not ai:TradeIsInProgress()) then
			if (goal:GetNumber(SN_STARTED) == 1) then
				-- we've already initiated trade but no trade in progress found, bail
				Print("GOAL_COMMON_Trade: failed to initiate trade", guid, bag, slot);
				return GOAL_RESULT_Failed;
			else
				ai:TradeInitiate(guid);
				goal:SetTimer(ST_PAUSE, 2);
				goal:SetNumber(SN_STARTED, 1)
			end
		else
			
			-- send begin if we're not the initiator
			if (goal:GetNumber(SN_STARTED) == 0 and goal:GetNumber(SN_BEGAN) == 0) then
				ai:TradeBegin();
				goal:SetTimer(ST_PAUSE, 2);
				goal:SetNumber(SN_BEGAN, 1)
				return GOAL_RESULT_Continue;
			end
			
			if (not ai:TradeItemIsInTrade(bag, slot)) then
				
				if (goal:GetNumber(SN_ADDEDITEM) == 1) then
					-- we've already added item but it appears to have failed
					Print("GOAL_COMMON_Trade: failed to add item to trade", guid, bag, slot);
					return GOAL_RESULT_Failed;
				else
					ai:TradeAddItem(0, bag, slot);
					goal:SetTimer(ST_PAUSE, 2);
					goal:SetNumber(SN_ADDEDITEM, 1)
				end
				
			elseif (not ai:TradeIsAccepted()) then
				ai:TradeAccept();
				goal:SetTimer(ST_PAUSE, 3);
				
			elseif (goal:GetNumber(SN_DONE) ~= 1) then
				goal:SetNumber(SN_DONE, 1)
			end
			
		end
		
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Trade_Terminate(ai, goal)
	ai:GetPlayer():ClearMotion();
	ai:TradeCancel();
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function Trade_Interupt(ai, goal)	return false;end
