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

-- GOAL_COMMON_CastAlone = 10;
REGISTER_GOAL(GOAL_COMMON_CastAlone, "CastAlone");

local SN_CAST = 0;

--[[******************************************************
	Goal start
********************************************************]]
function CastAlone_Activate(ai, goal)
end

--[[******************************************************
	Goal update
********************************************************]]
function CastAlone_Update(ai, goal)
	
	local guid 	= goal:GetParam(0);
	local spell = goal:GetParam(1);
	local key = goal:GetParam(2);
	local bufferDist = goal:GetParam(3);
	local agent = ai:GetPlayer();
	local target = GetUnitByGuid(agent, guid);
	
	if (nil == target or false == target:IsAlive()) then
		return GOAL_RESULT_Failed;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted()) then
		return GOAL_RESULT_Continue;
	end
	
	if (goal:GetNumber(SN_CAST) == 1 and goal:IsFinishTimer(SN_CAST)) then
		return GOAL_RESULT_Success;
	end
	
	if (0 == goal:GetNumber(SN_CAST)) then
		if (CAST_OK ~= agent:IsInPositionToCast(target, spell, bufferDist)) then
			goal:AddSubGoal(GOAL_COMMON_MoveInPosToCast, 10.0, guid, spell, bufferDist);
		else
			goal:ClearSubGoal();
			agent:ClearMotion();
			local result = agent:CastSpell(target, spell, false);
			if (CAST_OK == result) then
				Print(agent:GetName(), "cast alone", key, spell, GetSpellName(spell), target:GetName());
				goal:SetNumber(SN_CAST, 1);
				goal:SetTimer(SN_CAST, 0.5); -- for spell batching
			elseif (CAST_NOTHING_TO_DISPEL and CAST_NOTHING_TO_DISPEL == result) then
				return GOAL_RESULT_Success;
			end
		end
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function CastAlone_Terminate(ai, goal)
	local agent = ai:GetPlayer();
	local guid 	= goal:GetParam(0);
	local key 	= goal:GetParam(2);
	
	AI_UnpostBuff(guid, key);
	if (ai:CmdType() == CMD_DISPEL) then
		-- Print("CmdCastAlone complete", agent:GetName());
		-- ai:CmdComplete();
		Command_Complete(ai, "CMD_DISPEL complete");
	end
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function CastAlone_Interupt(ai, goal)	return false;end
