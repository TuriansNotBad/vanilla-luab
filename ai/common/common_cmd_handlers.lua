
--------------------------------------------------
--                  CMD_FOLLOW
--------------------------------------------------

function Cmd_FollowSetParams(aidata, foodHp, drinkMp, replenishForm)
	aidata._cmdFollowParams = {foodHp = foodHp, drinkMp = drinkMp, replenishForm = replenishForm};
end

local function Cmd_FollowGetParams(aidata)
	if (not aidata._cmdFollowParams) then
		error("CommandMgr: ai must set follow params for CMD_FOLLOW using Cmd_FollowSetParams function");
	end
	return aidata._cmdFollowParams;
end

local function Cmd_FollowOnBegin(ai, agent, goal, party, data, partyData)
	agent:AttackStop();
	agent:ClearMotion();
	goal:ClearSubGoal();
end

local function Cmd_FollowOnEnd(ai)
	ai:GetPlayer():ClearMotion();
end

local function Cmd_FollowUpdate(ai, agent, goal, party, data, partyData)
	if (goal:GetSubGoalNum() > 0 or agent:IsNonMeleeSpellCasted()) then
		return;
	end
	
	local params = Cmd_FollowGetParams(data);
	AI_Replenish(agent, goal, params.foodHp, params.drinkMp, params.replenishForm);
	
	if (goal:GetSubGoalNum() == 0 and agent:GetMotionType() ~= MOTION_FOLLOW) then
		goal:ClearSubGoal();
		agent:ClearMotion();
		local guid, dist, angle = ai:CmdArgs();
		local target = GetPlayerByGuid(guid);
		if (target) then
			agent:MoveFollow(target, dist, angle);
		else
			Command_Complete(ai, "Follow target not found");
		end
	end
end

--------------------------------------------------
--                  CMD_ENGAGE
--------------------------------------------------

function Cmd_EngageSetParams(aidata, bRanged, interruptR, fnThreatActions, fnNonThreatActions)
	aidata._cmdEngageParams = {bRanged = bRanged, interruptR = interruptR, fnThreatActions = fnThreatActions, fnNonThreatActions = fnNonThreatActions};
end

local function Cmd_EngageGetParams(aidata)
	if (not aidata._cmdEngageParams) then
		error("CommandMgr: ai must set engage params for CMD_ENGAGE using Cmd_EngageSetParams function");
	end
	return aidata._cmdEngageParams;
end

local function Cmd_EngageOnBegin(ai, agent, goal, party, data, partyData)
	Print(agent:GetName(), agent:GetClass(), "CMD_ENGAGE OnBegin default handler");
	goal:ClearSubGoal();
	agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	agent:ClearMotion();
end

local function Cmd_EngageOnEnd(ai)
	ai:GetPlayer():ClearMotion();
end

 -- todo: allow killing totems when moving
local function Cmd_EngageUpdate(ai, agent, goal, party, data, partyData, fnThreatActionsOverride)
	
	-- do combat!
	-- party has no attackers
	local targets = data.targets or partyData.attackers;
	if (not targets[1]) then
		agent:AttackStop();
		-- agent:ClearMotion();
		-- goal:ClearSubGoal();
		-- Command_Complete(ai, "No attackers found");
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	local params = Cmd_EngageGetParams(data);
	local target;
	local bAllowThreatActions = true; 
	
	if (partyData.hostileTotems) then
		target = Dps_GetNearestTarget(agent, partyData.hostileTotems);
	end
	
	if (nil == target) then
		local bThreatCheck = agent:IsInDungeon() and partyData:HasTank() and not targets.ignoreThreat;
		
		if (params.interruptR) then
			target = Dps_GetFirstInterruptOrLowestHpTarget(ai, agent, party, targets, bThreatCheck, params.interruptR);
		else
			target = Dps_GetLowestHpTarget(ai, agent, party, targets, bThreatCheck);
		end
		bAllowThreatActions = target ~= nil;
	end
	
	-- use tank's target if threat is too high
	if (nil == target) then
		local _,tank = partyData:GetFirstActiveTank();
		if (tank and tank:IsInCombat()) then
			target = tank:GetVictim();
		end
	end
	
	-- still nothing
	if (nil == target or not target:IsAlive()) then
		agent:AttackStop();
		agent:ClearMotion();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
		agent:InterruptSpell(CURRENT_MELEE_SPELL);
		return;
	end
	
	if (agent:IsNonMeleeSpellCasted()) then
		if (data.channeledAoe and data.channeledAoePos) then
			local channeledSpell = agent:GetCurrentSpellId(CURRENT_CHANNELED_SPELL);
			if (channeledSpell > 0 and data.channeledAoe[channeledSpell]) then
				if (target:GetDistance(data.channeledAoePos[1], data.channeledAoePos[2], data.channeledAoePos[3]) > data.channeledAoe[channeledSpell]) then
					agent:InterruptSpell(CURRENT_CHANNELED_SPELL);
					Print("Cmd_EngageUpdate: interrupt channeled aoe", channeledSpell);
				end
			end
		end
		return;
	end
	
	-- movement
	Movement_Process(ai, goal, party, target, params.bRanged, bAllowThreatActions);
	
	-- attacks
	if (bAllowThreatActions) then
		if (fnThreatActionsOverride) then
			fnThreatActionsOverride(ai, agent, goal, party, data, partyData, target);
		else
			params.fnThreatActions(ai, agent, goal, party, data, partyData, target);
		end
	else
		agent:AttackStop();
		if (params.fnNonThreatActions) then
			params.fnNonThreatActions(ai, agent, goal, party, data, partyData, target);
		end
	end
	
	return;

end

--------------------------------------------------
--                  CMD_DISPEL
--------------------------------------------------

local function Cmd_DispelOnBegin(ai, agent, goal, party, data, partyData)
	agent:InterruptSpell(CURRENT_GENERIC_SPELL);
end

local function Cmd_DispelOnEnd(ai)
	local guid, key = ai:CmdArgs();
	if (AI_HasBuffAssignedTo(ai:GetPlayer(), guid, key)) then
		AI_UnpostBuff(guid, key);
	end
end

local function Cmd_DispelUpdate(ai, agent, goal, party, data, partyData)
	-- give buffs!
	local guid, key = ai:CmdArgs();
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	local target = GetPlayerByGuid(guid);
	if (nil == target or false == target:IsAlive()) then
		Command_Complete(ai, "Dispel target dead or not found");
		return;
	end
	
	if (agent:GetShapeshiftForm() == ai:GetForm()) then
		local spellid = data.dispels[key];
		-- AI_PostBuff(agent:GetGuid(), target:GetGuid(), "Dispel", true);
		goal:AddSubGoal(GOAL_COMMON_CastAlone, 5.0, guid, spellid, "Dispel", 5.0);
	end
end

--------------------------------------------------
--                  CMD_BUFF
--------------------------------------------------

local function Cmd_BuffOnBegin(ai, agent, goal, party, data, partyData)
	agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	goal:ClearSubGoal();
end

local function Cmd_BuffOnEnd(ai)
	local guid, key = ai:CmdArgs();
	if (AI_HasBuffAssignedTo(ai:GetPlayer(), guid, key)) then
		AI_UnpostBuff(guid, key);
	end
end

local function Cmd_BuffUpdate(ai, agent, goal, party, data, partyData)
	-- give buffs!
	local guid, spellid, key = ai:CmdArgs();
	if (false == agent:HasEnoughPowerFor(spellid, false)) then
		-- release assigned buff
		if (goal:GetActiveSubGoalId() ~= GOAL_COMMON_Replenish) then
			goal:ClearSubGoal();
		end
		if (#partyData.attackers == 0) then
			AI_Replenish(agent, goal, 0.0, 99.0);
		end
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	local target = GetPlayerByGuid(guid);
	if (nil == target or false == target:IsAlive()) then
		Command_Complete(ai, "Buff target dead or not found");
		return;
	end
	
	if (agent:GetShapeshiftForm() == ai:GetForm()) then
		goal:AddSubGoal(GOAL_COMMON_Buff, 20.0, guid, spellid, key);
	end
end

--------------------------------------------------
--                  CMD_CC
--------------------------------------------------

local function Cmd_CCOnBegin(ai, agent, goal, party, data, partyData)
	agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	agent:InterruptSpell(CURRENT_CHANNELED_SPELL);
	agent:AttackStop();
	agent:ClearMotion();
	goal:ClearSubGoal();
end

local function Cmd_CCOnEnd(ai)
	ai:GetTopGoal():ClearSubGoal();
end

local function Cmd_CCUpdate(ai, agent, goal, party, data, partyData)
	-- do cc!
	local guid = ai:CmdArgs();
	local target = GetUnitByGuid(agent, guid);
	
	if (nil == target or false == target:IsAlive() or (party and false == party:IsCC(target))) then
		Print("CMD_CC interrupted:", target, "is cc =", target and party:IsCC(target));
		Command_Complete(ai, "CMD_CC interrupted. target is gone or is no longer cc target");
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	ai:SetCCTarget(guid);
	goal:AddSubGoal(GOAL_COMMON_Cc, 20.0, guid, data.ccspell);
end

--------------------------------------------------
--                  CMD_SCRIPT
--------------------------------------------------

local function Cmd_ScriptOnBegin(ai, agent, goal, party, data, partyData)
	if (data.script and data.script.fnbegin) then
		data.script.fnbegin(ai, agent, goal, party, data, partyData, data.script);
	end
end

local function Cmd_ScriptOnEnd(ai)
	local data = ai:GetData();
	if (data.script and data.script.fnend) then
		data.script.fnend(ai, data.script);
	end
	data.script = nil;
end

local function Cmd_ScriptUpdate(ai, agent, goal, party, data, partyData)
	if (data.script) then
		data.script.fn(ai, agent, goal, party, data, partyData, data.script);
	else
		error(agent:GetName() .. " CMD_SCRIPT no data.script assigned");
	end
end

--------------------------------------------------
--                  CMD_PULL
--------------------------------------------------

local function Cmd_PullOnBegin(ai, agent, goal, party, data, partyData)
	goal:AddSubGoal(GOAL_COMMON_Pull, 60, ai:CmdArgs());
end

local function Cmd_PullUpdate(ai, agent, goal, party, data, partyData)
	if (goal:GetSubGoalNum() == 0) then
		Command_Complete(ai, "CMD_PULL complete");
	end
end

--------------------------------------------------
--                  CMD_TRADE
--------------------------------------------------

local function Cmd_TradeOnBegin(ai, agent, goal, party, data, partyData)
	local guid,bag,slot = ai:CmdArgs();
	local target = GetPlayerByGuid(guid);
	if (not target) then
		Command_Complete(ai, "CMD_TRADE failed, target not found - " .. tostring(guid));
		return;
	end
	
	if (not ai:EquipHasItemInSlot(bag, slot, true)) then
		Command_Complete(ai, "CMD_TRADE failed, item not found - " .. bag .. " " .. slot);
		return;
	end
	
	goal:AddSubGoal(GOAL_COMMON_Trade, 30, guid, bag, slot);
end

local function Cmd_TradeUpdate(ai, agent, goal, party, data, partyData)
	if (goal:GetSubGoalNum() == 0) then
		Command_Complete(ai, "CMD_TRADE finished");
	end
end

--------------------------------------------------
--                  CMD_LOOT
--------------------------------------------------

local function Cmd_LootOnBegin(ai, agent, goal, party, data, partyData)
	local guid,itemid = ai:CmdArgs();
	local target = GetUnitByGuid(agent, guid);
	if (not (target and target:IsDead())) then
		Command_Complete(ai, "CMD_LOOT failed, target not found - " .. tostring(guid));
		return;
	end
	
	goal:AddSubGoal(GOAL_COMMON_Loot, 30, guid, itemid);
end

local function Cmd_LootUpdate(ai, agent, goal, party, data, partyData)
	if (goal:GetSubGoalNum() == 0) then
		Command_Complete(ai, "CMD_LOOT finished");
	end
end

--------------------------------------------------
-- Set default handlers
--------------------------------------------------
function Cmd_InitDefaultHandlers()
	Command_SetDefaultHandlers(CMD_FOLLOW, Cmd_FollowOnBegin,    Cmd_FollowUpdate, Cmd_FollowOnEnd);
	Command_SetDefaultHandlers(CMD_ENGAGE, Cmd_EngageOnBegin,    Cmd_EngageUpdate, Cmd_EngageOnEnd);
	Command_SetDefaultHandlers(CMD_DISPEL, Cmd_DispelOnBegin,    Cmd_DispelUpdate, Cmd_DispelOnEnd);
	Command_SetDefaultHandlers(CMD_BUFF  , Cmd_BuffOnBegin,      Cmd_BuffUpdate,   Cmd_BuffOnEnd);
	Command_SetDefaultHandlers(CMD_CC    , Cmd_CCOnBegin,        Cmd_CCUpdate,     Cmd_CCOnEnd);
	Command_SetDefaultHandlers(CMD_SCRIPT, Cmd_ScriptOnBegin,    Cmd_ScriptUpdate, Cmd_ScriptOnEnd);
	Command_SetDefaultHandlers(CMD_PULL  , Cmd_PullOnBegin,      Cmd_PullUpdate,   nil);
	Command_SetDefaultHandlers(CMD_HEAL  , Cmd_HealOnBeginOrEnd, Cmd_HealUpdate,   Cmd_HealOnBeginOrEnd);
	Command_SetDefaultHandlers(CMD_TRADE , Cmd_TradeOnBegin,     Cmd_TradeUpdate,  nil);
	Command_SetDefaultHandlers(CMD_LOOT ,  Cmd_LootOnBegin,      Cmd_LootUpdate,   nil);
end
