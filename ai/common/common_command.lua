
local t_defaultCmdHandlers = {};

function Command_SetDefaultHandlers(cmd, fnbegin, fnupdate, fnend)
	t_defaultCmdHandlers[cmd] = {};
	t_defaultCmdHandlers[cmd].OnBegin = fnbegin;
	t_defaultCmdHandlers[cmd].Update  = fnupdate;
	t_defaultCmdHandlers[cmd].OnEnd   = fnend;
end

function Command_GetDefaultHandlers(cmd)
	return t_defaultCmdHandlers[cmd];
end

function Command_MakeTable(ai)
	
	local data = ai:GetData();
	data._commandTable = {};
	
	local register_command;
	register_command = function(cmd, fnbegin, fnupdate, fnend, bUseDefaultHandlers)
		if (bUseDefaultHandlers) then
			local dh = Command_GetDefaultHandlers(cmd);
			if (dh) then
				fnbegin  = fnbegin  or dh.OnBegin;
				fnupdate = fnupdate or dh.Update;
				fnend    = fnend    or dh.OnEnd;
			end
		end
		data._commandTable[cmd] = {OnBegin = fnbegin, Update = fnupdate, OnEnd = fnend};
		return register_command;
	end
	return register_command;
	
end

-- todo: if command issued before agent's top goal activate is run this will error
-- can happen with .reset chat command
function Command_GetTable(aidata)
	if (not aidata._commandTable) then
		error("CommandMgr: ai command table not defined");
	end
	return aidata._commandTable;
end

function Command_Complete(ai, reason)
	local cmd = ai:CmdType();
	if (cmd ~= CMD_NONE) then
		Print("CommandMgr:", CMD2STR[cmd], "end for", ai:GetPlayer():GetName(), "; Reason:", reason);
		local CommandHandlers = Command_GetTable(ai:GetData())[cmd];
		if (CommandHandlers and CommandHandlers.OnEnd) then
			CommandHandlers.OnEnd(ai);
		end
		ai:CmdComplete();
	end
	ai:GetPlayer():ClearMotion();
	ai:GetTopGoal():ClearSubGoal();
	Movement_ClearRequests(ai:GetData());
end

function Command_ClearAll(ai, reason)
	local cmd = ai:CmdType();
	if (cmd ~= CMD_NONE) then
		Print("CommandMgr:", CMD2STR[cmd], "end for", ai:GetPlayer():GetName(), "; Reason:", reason);
		local CommandHandlers = Command_GetTable(ai:GetData())[cmd];
		if (CommandHandlers and CommandHandlers.OnEnd) then
			CommandHandlers.OnEnd(ai);
		end
		ai:CmdFail();
	end
	ai:GetPlayer():ClearMotion();
	ai:GetTopGoal():ClearSubGoal();
	Movement_ClearRequests(ai:GetData());
end

local function _UpdateCcTarget(ai, party)
	if (ai:GetCCTarget()) then
		if (not Unit_IsCrowdControlled(ai:GetCCTarget())) then
			party:RemoveCC(ai:GetCCTarget():GetGuid());
			ai:SetCCTarget(nil);
		end
	else
		ai:SetCCTarget(nil);
	end
end

function Command_DefaultUpdate(ai, goal)
	
	local data = ai:GetData();
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	local cmd = ai:CmdType();
	if (cmd == CMD_NONE or nil == party) then
		if (AI_IsIncapacitated(agent)) then
			_UpdateCcTarget(ai, party);
			if (data.IncapacitatedUpdate) then
				data.IncapacitatedUpdate(ai, agent, goal, party, data, partyData);
			end
		end
		return false;
	end
	
	-- update CC target
	if (Command_GetTable(data)[CMD_CC]) then
		if (0 == #partyData.attackers) then
			ai:SetCCTarget(nil);
		else
			if (ai:CmdType() ~= CMD_CC) then
				local target = ai:GetCCTarget();
				if (target) then
					if (nil == target or false == target:IsAlive() or (party and false == party:IsCC(target))) then
						ai:SetCCTarget(nil);
					end
				end
			end
		end
	end
	
	if (AI_IsIncapacitated(agent)) then
		if (data.IncapacitatedUpdate) then
			data.IncapacitatedUpdate(ai, agent, goal, party, data, partyData);
		end
		goal:ClearSubGoal();
		ai:SetHealTarget(nil);
		_UpdateCcTarget(ai, party);
		Command_ClearAll(ai, "Agent incapacitated");
		agent:ClearMotion();
		agent:StopMoving();
		return false;
	end
	
	if (Data_GetShouldSelfDefense(data, partyData)) then
		if (agent:GetAttackersNum() > 0 and Data_GetAgentSelfDefenseFn(data)) then
			Data_GetAgentSelfDefenseFn(data)(ai, agent, goal, party, data, partyData);
		end
	end
	
	if (data.UpdateShapeshift) then
		data:UpdateShapeshift(ai, agent, goal);
	end
	
	if (data.flask and false == agent:HasAura(data.flask)) then
		agent:CastSpell(agent, data.flask, true);
	end
	
	local CommandHandlers = Command_GetTable(data)[cmd];
	if (CommandHandlers) then
		if (ai:CmdState() == CMD_STATE_WAITING) then
			ai:CmdSetInProgress();
			if (CommandHandlers.OnBegin) then
				CommandHandlers.OnBegin(ai, agent, goal, party, data, partyData);
			end
		end
		CommandHandlers.Update(ai, agent, goal, party, data, partyData);
	end
	
	return true;
	
end

function Command_IssueFollow(ai, party, targetGuid, D, A)
	Command_ClearAll(ai, "New command");
	party:CmdFollow(ai, targetGuid, D, A);
	Print("CommandMgr: CMD_FOLLOW to", ai:GetPlayer():GetName(), "target =", targetGuid, ", D =", D, " A =", A, CMD_FOLLOW, ai:CmdType());
end

function Command_IssueEngage(ai, party)
	Command_ClearAll(ai, "New command");
	party:CmdEngage(ai, 0);
	Print("CommandMgr: CMD_ENGAGE to", ai:GetPlayer():GetName());
end

function Command_IssueBuff(ai, party, targetGuid, spellid, key)
	Command_ClearAll(ai, "New command");
	AI_PostBuff(ai:GetPlayer():GetGuid(), targetGuid, key, true);
	party:CmdBuff(ai, targetGuid, spellid, key);
	Print("CommandMgr: CMD_BUFF to", ai:GetPlayer():GetName(), "target =", targetGuid, "spell =", spellid, "key =", key);
end

function Command_IssueDispel(ai, party, targetGuid, key)
	Command_ClearAll(ai, "New command");
	AI_PostBuff(ai:GetPlayer():GetGuid(), targetGuid, "Dispel", true);
	party:CmdDispel(ai, targetGuid, key);
	Print("CommandMgr: CMD_DISPEL to", ai:GetPlayer():GetName(), "target =", targetGuid, "key =", key);
end

function Command_IssueHeal(ai, party, targetGuid, nHeals)
	Command_ClearAll(ai, "New command");
	party:CmdHeal(ai, targetGuid, nHeals);
	Print("CommandMgr: CMD_HEAL to", ai:GetPlayer():GetName(), "target =", targetGuid, "nHeals =", nHeals);
end

function Command_IssueScript(ai, party, script)
	Command_ClearAll(ai, "New command");
	if (script) then
		ai:GetData().script = script;
	end
	party:CmdScript(ai);
	Print("CommandMgr: CMD_SCRIPT to", ai:GetPlayer():GetName());
end

function Command_IssueCc(ai, party, target)
	Command_ClearAll(ai, "New command");
	party:CmdCC(ai, target:GetGuid());
	Print("CommandMgr: CMD_CC to", ai:GetPlayer():GetName(), "for target", target:GetName());
end

function Command_IssuePull(ai, party, target)
	Command_ClearAll(ai, "New command");
	party:CmdPull(ai, target:GetGuid());
	Print("CommandMgr: CMD_PULL to", ai:GetPlayer():GetName(), "for target", target:GetName());
end

function Command_IssueTank(ai, party, target, threatTarget)
	Command_ClearAll(ai, "New command");
	party:CmdTank(ai, target:GetGuid(), threatTarget);
	Print("CommandMgr: CMD_TANK to", ai:GetPlayer():GetName(), "for target", target:GetName(), "threat target =", threatTarget);
end

function Command_IssueTrade(ai, party, target, bag, slot)
	Command_ClearAll(ai, "New command");
	party:CmdTrade(ai, target:GetGuid(), bag, slot);
	Print("CommandMgr: CMD_TRADE to", ai:GetPlayer():GetName(), "for target", target:GetName(), "bag, slot", bag, slot);
end

function Command_IssueLoot(ai, party, target, itemid)
	Command_ClearAll(ai, "New command");
	party:CmdLoot(ai, target:GetGuid(), itemid);
	Print("CommandMgr: CMD_LOOT to", ai:GetPlayer():GetName(), "for target", target, "itemid", itemid);
end
