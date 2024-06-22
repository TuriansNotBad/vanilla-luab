--[[*******************************************************************************************
	Common functions for dps.
	Notes:
		<blank>
*********************************************************************************************]]

function Dps_GetLowestHpTarget(ai, agent, party, targets, threatCheck)
	
	local minDiff = ai:GetStdThreat();
	for i = 1, #targets do
		local target = targets[i];
		local _,tankThreat = target:GetHighestThreat();
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
		local _,tankThreat = target:GetHighestThreat();
		local diff  = tankThreat - target:GetThreat(agent);
		if (diff > ai:GetStdThreat() or false == threatCheck) and (nil == party or false == party:IsCC(target)) then
			if (target:GetDistance(agent) <= maxInterruptDist
			and target:IsCastingInterruptableSpell()
			and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
				return target;
			end
			if (hpTarget == nil and diff > minDiff) then
				hpTarget = target;
			end
		end
	end
	return hpTarget;
	
end

function Dps_RangedChase(ai, agent, target, bAttack)
	
	local defD = 12.0;
	local defMinD = 0.0;
	local defMaxD = 15.0;
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
	if (isOnWrongTarget or agent:GetMotionType() ~= MOTION_CHASE or ai:GetChaseDist() > 2.0) then
		agent:AttackStop();
		agent:ClearMotion();
		if (bAttack) then
			agent:Attack(target);
		end
		agent:MoveChase(target, 1.5, 2.0, 1.5, math.rad(math.random(160, 200)), math.pi/4.0, false, true);
		return;
	end
end

function Dps_OnEngageUpdate(ai, agent, goal, party, data, bRanged, interruptR, fnThreatActions)

	-- do combat!
	if (ai:CmdState() == CMD_STATE_WAITING) then
		Print(agent:GetName(), agent:GetClass(), "CMD_ENGAGE default update");
		ai:CmdSetInProgress();
	end
	
	local partyData = party:GetData();
	-- party has no attackers
	local targets = partyData.attackers;
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
	if (interruptR) then
		target = Dps_GetFirstInterruptOrLowestHpTarget(ai, agent, party, targets, agent:IsInDungeon(), interruptR);
	else
		target = Dps_GetLowestHpTarget(ai, agent, party, targets, agent:IsInDungeon());
	end
	local bAllowThreatActions = target ~= nil;
	
	-- use tank's target if threat is too high
	if (nil == target and partyData:HasTank()) then
		local tank = partyData.tanks[1];
		target = tank:GetPlayer():GetVictim();
	end
	
	-- still nothing
	if (nil == target or not target:IsAlive()) then
		agent:AttackStop();
		agent:ClearMotion();
		agent:InterruptSpell(CURRENT_GENERIC_SPELL);
		agent:InterruptSpell(CURRENT_MELEE_SPELL);
		-- Print("No target for", agent:GetName());
		return GOAL_RESULT_Continue;
	end
	
	if (agent:IsNonMeleeSpellCasted()) then
		return GOAL_RESULT_Continue;
	end
	
	-- movement
	if (bRanged) then
		if (target:GetDistance(agent) > 5.0 or false == ai:IsCLineAvailable() or target:GetVictim() == agent) then
			Dps_RangedChase(ai, agent, target, bAllowThreatActions);
		else
			local x,y,z = party:GetCLinePInLosAtD(agent, target, 10, 15, 1, not partyData.reverse);
			if (x) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, x, y, z);
				print("Move To", x, y, z);
				return GOAL_RESULT_Continue;
			else
				Dps_RangedChase(ai, agent, target, bAllowThreatActions);
			end
		end
	else
		Dps_MeleeChase(ai, agent, target, bAllowThreatActions);
	end
	
	-- attacks
	if (bAllowThreatActions) then
		fnThreatActions(ai, agent, goal, data, target);
	else
		agent:AttackStop();
	end
	
	return GOAL_RESULT_Continue;

end
