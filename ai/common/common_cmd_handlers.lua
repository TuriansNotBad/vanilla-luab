
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

function Cmd_EngageSetParams(aidata, bRanged, interruptR, fnThreatActions)
	aidata._cmdEngageParams = {bRanged = bRanged, interruptR = interruptR, fnThreatActions = fnThreatActions};
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
 
 -- todo: allow killing totems when moving
local function Cmd_EngageUpdate(ai, agent, goal, party, data, partyData)
	
	-- do combat!
	-- party has no attackers
	local targets = data.targets or partyData.attackers;
	if (not targets[1]) then
		agent:AttackStop();
		agent:ClearMotion();
		goal:ClearSubGoal();
		Command_Complete(ai, "No attackers found");
		return;
	end
	
	local area = partyData._holdPos;
	local encounter = partyData.encounter;
	local distancingR = encounter and encounter.distancingR or 5.0;
	local rchrpos = data.rchrpos or (encounter and encounter.rchrpos);
	local noTotemsToKill = true;--partyData.hostileTotems and #partyData.hostileTotems == 0;
	
	if (goal:GetSubGoalNum() > 0) then
		if (rchrpos and not noTotemsToKill) then
			goal:ClearSubGoal();
		end
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
		return;
	end
	
	-- movement
	if (area and false == AI_TargetInHoldingArea(target, area)) then
		
		if (agent:GetDistance(area.dpspos.x, area.dpspos.y, area.dpspos.z) > 2.0) then
			goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, area.dpspos.x, area.dpspos.y, area.dpspos.z);
			return;
		end
	
	elseif (rchrpos) then
		
		local shouldGoToSpot = params.bRanged or not bAllowThreatActions;
		if (not params.bRanged) then
			local meleeMode = rchrpos.melee;
			if (meleeMode == "ignore") then
				shouldGoToSpot = false;
			elseif (meleeMode == "dance") then
				-- already set to this mode
			else
				shouldGoToSpot = true;
			end
		end
		
		if (shouldGoToSpot and noTotemsToKill) then
			if (agent:GetDistance(rchrpos.x, rchrpos.y, rchrpos.z) > 3.0) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, rchrpos.x, rchrpos.y, rchrpos.z);
				return;
			end
		else
			if (params.bRanged) then
			
				if (false == AI_DistanceIfNeeded(ai, agent, goal, party, distancingR, target)) then
					Dps_RangedChase(ai, agent, target, bAllowThreatActions);
				end
				
			else
				Dps_MeleeChase(ai, agent, target, bAllowThreatActions);
			end
		end
		
	else
	
		if (params.bRanged) then
		
			if (false == AI_DistanceIfNeeded(ai, agent, goal, party, distancingR, target)) then
				Dps_RangedChase(ai, agent, target, bAllowThreatActions);
			end
			
		else
			Dps_MeleeChase(ai, agent, target, bAllowThreatActions);
		end
		
	end
	
	-- attacks
	if (bAllowThreatActions) then
		params.fnThreatActions(ai, agent, goal, party, data, partyData, target);
	else
		agent:AttackStop();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
		agent:InterruptSpell(CURRENT_MELEE_SPELL);
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

local function Cmd_ScriptUpdate(ai, agent, goal, party, data, partyData)
	if (data.script) then
		data.script.fn(ai, agent, goal, data, partyData);
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
-- Set default handlers
--------------------------------------------------
function Cmd_InitDefaultHandlers()
	Command_SetDefaultHandlers(CMD_FOLLOW, Cmd_FollowOnBegin, Cmd_FollowUpdate, Cmd_FollowOnEnd);
	Command_SetDefaultHandlers(CMD_ENGAGE, Cmd_EngageOnBegin, Cmd_EngageUpdate, nil);
	Command_SetDefaultHandlers(CMD_DISPEL, Cmd_DispelOnBegin, Cmd_DispelUpdate, Cmd_DispelOnEnd);
	Command_SetDefaultHandlers(CMD_BUFF  , Cmd_BuffOnBegin,   Cmd_BuffUpdate,   Cmd_BuffOnEnd);
	Command_SetDefaultHandlers(CMD_CC    , Cmd_CCOnBegin,     Cmd_CCUpdate,     Cmd_CCOnEnd);
	Command_SetDefaultHandlers(CMD_SCRIPT, nil,               Cmd_ScriptUpdate, nil);
	Command_SetDefaultHandlers(CMD_PULL  , Cmd_PullOnBegin,   Cmd_PullUpdate,   nil);
end
