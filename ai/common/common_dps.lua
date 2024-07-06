--[[*******************************************************************************************
	Common functions for dps.
	Notes:
		<blank>
*********************************************************************************************]]

function Dps_GetNearestTarget(agent, targets)
	if (#targets == 0) then
		return;
	end
	local nearest = targets[1];
	local dist    = targets[1]:GetDistance(agent);
	for i = 2, #targets do
		local d = targets[i]:GetDistance(agent);
		if (d < dist) then
			nearest = targets[i];
			dist = d;
		end
	end
	return nearest;
end

function Dps_GetLowestHpTarget(ai, agent, party, targets, threatCheck)
	
	local minDiff = ai:GetStdThreat();
	for i = 1, #targets do
		local target = targets[i];
		local tankThreat = Tank_GetTankThreat(party:GetData(), target);
		local diff  = tankThreat - target:GetThreat(agent);
		if (diff > minDiff or false == threatCheck) and (nil == party or false == party:IsCC(target)) then
			return target;
		end
	end
	
end

function Dps_GetFirstInterruptOrLowestHpTarget(ai, agent, party, targets, threatCheck, maxInterruptDist)
	local hpTarget;
	local minDiff = ai:GetStdThreat();
	for i = 1, #targets do
		local target = targets[i];
		local tankThreat = Tank_GetTankThreat(party:GetData(), target);
		local diff  = tankThreat - target:GetThreat(agent);
		if (diff > ai:GetStdThreat() or false == threatCheck) and (nil == party or false == party:IsCC(target)) then
			if (target:GetDistance(agent) <= maxInterruptDist
			and target:IsCastingInterruptableSpell()
			and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
				return target;
			end
			if (hpTarget == nil) then
				hpTarget = target;
			end
		end
	end
	return hpTarget;
	
end

function Dps_RangedChase(ai, agent, target, bAttack)
	
	local defD = 18.0;
	local defMinD = 0.0;
	local defMaxD = 21.0;
	local defMinT = defD - defMinD;
	local defMaxT = defMaxD - defD;
	
	local isOnWrongTarget = (bAttack and agent:GetVictim() ~= target) or (false == bAttack and ai:GetChaseTarget() ~= target);
	if (isOnWrongTarget or agent:GetMotionType() ~= MOTION_CHASE) then
		agent:AttackStop();
		agent:ClearMotion();
		if (bAttack) then
			agent:Attack(target);
		end
		agent:MoveChase(target, defD, defMinT, defMaxT, math.rad(math.random(160, 200)), math.pi/4.0, true, false);
		return;
	end
	
	if (false == agent:IsInLOS(target)) then
		if (ai:GetChaseDist() > 1.01) then
			ai:SetChaseValues(1.0, 0.5, 0.5);
		end
	else
		-- local minD = math.min(defMinD, agent:GetDistance(target));
		-- minD = math.max(5.0, minD);
		-- local minT = defD - minD;
		-- Print(defMinT, defMinD, agent:GetDistance(target), ai:GetChaseUseAngle());
		-- if (agent:GetDistance(target) < 5.0) then
			-- if (false == ai:GetChaseUseAngle()) then
				-- Print(agent:GetName(), "is using chase angle now");
				-- ai:SetChaseUseAngle(true);
			-- end
		-- else
			-- if (true == ai:GetChaseUseAngle()) then
				-- Print(agent:GetName(), "is no longer using chase angle");
				-- ai:SetChaseUseAngle(false);
			-- end
		-- end
		if (ai:GetChaseDist() ~= defD) then
			ai:SetChaseValues(defD, defMinT, defMaxT);
		end
	end
	
end

function Dps_MeleeChase(ai, agent, target, bAttack)
	if (AI_HasMotionAura(agent)) then
		return;
	end
	
	local isOnWrongTarget = (bAttack and agent:GetVictim() ~= target) or (false == bAttack and ai:GetChaseTarget() ~= target);
	if (isOnWrongTarget or (agent:GetMotionType() ~= MOTION_CHASE and agent:GetMotionType() ~= MOTION_CHARGE) or ai:GetChaseDist() > 2.0) then
		agent:AttackStop();
		agent:ClearMotion();
		if (bAttack) then
			agent:Attack(target);
		end
		agent:MoveChase(target, 1.5, 2.0, 1.5, math.rad(math.random(160, 200)), math.pi/4.0, false, true);
		return;
	end
end

function Dps_OnEngageUpdate(ai, agent, goal, party, data, partyData, bRanged, interruptR, fnThreatActions)

	-- do combat!
	if (ai:CmdState() == CMD_STATE_WAITING) then
		Print(agent:GetName(), agent:GetClass(), "CMD_ENGAGE default update");
		ai:CmdSetInProgress();
		goal:ClearSubGoal();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
	end
	
	-- party has no attackers
	local targets = data.targets or partyData.attackers;
	if (not targets[1]) then
		agent:AttackStop();
		agent:ClearMotion();
		ai:CmdComplete();
		goal:ClearSubGoal();
		return GOAL_RESULT_Continue;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return GOAL_RESULT_Continue;
	end
	
	local target;
	local bAllowThreatActions = true; 
	
	if (partyData.hostileTotems) then
		target = Dps_GetNearestTarget(agent, partyData.hostileTotems);
	end
	
	if (nil == target) then
		local bThreatCheck = agent:IsInDungeon() and partyData:HasTank() and not targets.ignoreThreat;
		
		if (interruptR) then
			target = Dps_GetFirstInterruptOrLowestHpTarget(ai, agent, party, targets, bThreatCheck, interruptR);
		else
			target = Dps_GetLowestHpTarget(ai, agent, party, targets, bThreatCheck);
		end
		bAllowThreatActions = target ~= nil;
	end
	
	-- use tank's target if threat is too high
	if (nil == target and partyData:HasTank()) then
		local tank = partyData.tanks[1];
		if (tank:GetPlayer():IsInCombat()) then
			target = tank:GetPlayer():GetVictim();
		end
	end
	
	-- still nothing
	if (nil == target or not target:IsAlive()) then
		agent:AttackStop();
		agent:ClearMotion();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
		agent:InterruptSpell(CURRENT_MELEE_SPELL);
		return GOAL_RESULT_Continue;
	end
	
	if (agent:IsNonMeleeSpellCasted()) then
		return GOAL_RESULT_Continue;
	end
	
	-- movement
	local area = partyData._holdPos;
	local encounter = partyData.encounter;
	local distancingR = encounter and encounter.distancingR or 5.0;
	local rchrpos = encounter and encounter.rchrpos;
	if (area and false == AI_TargetInHoldingArea(target, area)) then
		
		if (agent:GetDistance(area.dpspos.x, area.dpspos.y, area.dpspos.z) > 2.0) then
			goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, area.dpspos.x, area.dpspos.y, area.dpspos.z);
			return GOAL_RESULT_Continue;
		end
	
	elseif (rchrpos) then
		
		-- if (bRanged or not bAllowThreatActions) then
			if (agent:GetDistance(rchrpos.x, rchrpos.y, rchrpos.z) > 3.0) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, rchrpos.x, rchrpos.y, rchrpos.z);
				return GOAL_RESULT_Continue;
			end
		-- else
			-- Dps_MeleeChase(ai, agent, target, bAllowThreatActions);
		-- end
		
	else
	
		if (bRanged) then
		
			if (false == AI_DistanceIfNeeded(ai, agent, goal, party, distancingR, target)) then
				Dps_RangedChase(ai, agent, target, bAllowThreatActions);
			end
			
		else
			Dps_MeleeChase(ai, agent, target, bAllowThreatActions);
		end
		
	end
	
	-- attacks
	if (bAllowThreatActions) then
		fnThreatActions(ai, agent, goal, party, data, partyData, target);
	else
		agent:AttackStop();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
		agent:InterruptSpell(CURRENT_MELEE_SPELL);
	end
	
	return GOAL_RESULT_Continue;

end
