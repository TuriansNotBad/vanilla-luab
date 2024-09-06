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
	local partyData = party:GetData();
	local encounter = partyData.encounter;
	local interruptFilter = encounter and encounter.interruptFilter;
	local hpTarget;
	local minDiff = ai:GetStdThreat();
	
	for i = 1, #targets do
		local target = targets[i];
		local tankThreat = Tank_GetTankThreat(party:GetData(), target);
		local diff  = tankThreat - target:GetThreat(agent);
		if (diff > ai:GetStdThreat() or false == threatCheck) and (nil == party or false == party:IsCC(target)) then
			
			-- check interruptable
			local interruptCheck;
			if (interruptFilter) then
				interruptCheck = interruptFilter(ai, agent, party, target, targets, threatCheck, maxInterruptDist);
			else
				interruptCheck = target:GetDistance(agent) <= maxInterruptDist and target:IsCastingInterruptableSpell();
			end
			
			if (interruptCheck and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
				return target;
			end
			
			-- save lowest health target
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
		Print("Dps_RangedChase:", agent:GetName(), target:GetName(), target:GetGuid(), "chase", target:GetDistanceEx(agent, 0));
		agent:MoveChase(target, defD, defMinT, defMaxT, 0.0, 3.14, true, false, true);
		return;
	end
	
	if (false == agent:IsInLOS(target)) then
		if (ai:GetChaseDist() > 1.01) then
			Print("Dps_RangedChase:", agent:GetName(), target:GetName(), "chase dist too far. No LoS.", ai:GetChaseDist());
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
			Print("Dps_RangedChase:", agent:GetName(), target:GetName(), "chase dist too close. Have LoS.", ai:GetChaseDist(), defD);
			ai:SetChaseValues(defD, defMinT, defMaxT);
		end
	end
	
end

function Dps_MeleeChase(ai, agent, target, bAttack, keepDist)
	if (AI_HasMotionAura(agent)) then
		return;
	end
	
	local isOnWrongTarget = (bAttack and not AI_IsAttackingTarget(agent, target)) or (false == bAttack and ai:GetChaseTarget() ~= target);
	local r = AI_GetDefaultChaseSeparation(target);
	if (isOnWrongTarget or (agent:GetMotionType() ~= MOTION_CHASE and agent:GetMotionType() ~= MOTION_CHARGE) or ai:GetChaseDist() > r + .1) then
		agent:AttackStop();
		agent:ClearMotion();
		if (bAttack) then
			agent:Attack(target);
		end
		-- Print("Dps_MeleeChase: ", agent:GetName(), "target", target:GetName());
		agent:MoveChase(target, r, r/2, r/2, math.rad(math.random(160, 200)), math.pi/4.0, false, true, false);
		return;
	end
end
