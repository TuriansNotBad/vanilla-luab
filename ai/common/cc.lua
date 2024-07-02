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

-- GOAL_COMMON_Cc = 5;
REGISTER_GOAL(GOAL_COMMON_Cc, "Cc");

--[[******************************************************
	Goal start
********************************************************]]
function Cc_Activate(ai, goal)
	local guid = goal:GetParam(0);
	ai:SetCCTarget(guid);
	print("Cc_Activate CC");
end

--[[******************************************************
	Goal update
********************************************************]]
function Cc_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local guid 	= goal:GetParam(0);
	local spell = goal:GetParam(1);
	local target = GetUnitByGuid(agent, guid);
	local data = ai:GetData();
	
	if (nil == target or false == target:IsAlive() or false == agent:IsAlive()) then
		return GOAL_RESULT_Failed;
	end
	
	if (target:HasAura(spell)) then
		return GOAL_RESULT_Success;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
		if (agent:GetCurrentSpellId() == spell) then
			local party = ai:GetPartyIntelligence();
			if (party and false == party:IsCC(target)) then
				Print(agent:GetName(), "interrupt casting CC on target that is no longer CC");
				agent:InterruptSpell(CURRENT_GENERIC_SPELL);
			end
		end
		return GOAL_RESULT_Continue;
	end
	if (CAST_OK ~= agent:IsInPositionToCast(target, spell, 5.0)) then
		Print("In position CC", agent:IsInPositionToCast(target, spell, 5.0));
		goal:AddSubGoal(GOAL_COMMON_MoveInPosToCast, 10.0, guid, spell, 5.0);
	else
		local result = agent:CastSpell(target, spell, false);
		if (CAST_OK == result) then
			Print(agent:GetName(), "ccd", target:GetName(), "with spell", spell, GetSpellName(spell));
		-- else
			-- Print("CC result", result);
		end
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Cc_Terminate(ai, goal)
	local agent = ai:GetPlayer();
	if (ai:CmdType() == CMD_CC) then
		Print("CmdCC complete", agent:GetName());
		Command_Complete(ai, "CMD_CC complete");
	end
	print("Cc_Terminate CC");
end

--[[******************************************************
--  Interrupt
--  Return true if handled.
--  If not handled, the interrupt is sent to the goal or logic part of the next layer above.
********************************************************]]
function Cc_Interupt(ai, goal)	return false;end
