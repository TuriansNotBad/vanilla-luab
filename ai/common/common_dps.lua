--[[*******************************************************************************************
	Common functions for dps.
	Notes:
		<blank>
*********************************************************************************************]]

function Dps_GetLowestHpTarget(ai, agent, party, targets, threatCheck)
	
	local minDiff = ai:GetStdThreat() * 2;
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
			if (diff > minDiff) then
				hpTarget = target;
			end
		end
	end
	return hpTarget;
	
end

function Dps_RangedChase(ai, agent, target)
	
	local defD = 12.0;
	local defMinD = 0.0;
	local defMaxD = 15.0;
	local defMinT = defD - defMinD;
	local defMaxT = defMaxD - defD;
	
	if (agent:GetVictim() ~= target or agent:GetMotionType() ~= MOTION_CHASE) then
		agent:AttackStop();
		agent:ClearMotion();
		agent:Attack(target);
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

function Dps_MeleeChase(ai, agent, target)
	if (AI_HasMotionAura(agent)) then
		return;
	end
	if (agent:GetVictim() ~= target or agent:GetMotionType() ~= MOTION_CHASE or ai:GetChaseDist() > 2.0) then
		agent:AttackStop();
		agent:ClearMotion();
		agent:Attack(target);
		agent:MoveChase(target, 1.5, 2.0, 1.5, math.rad(math.random(160, 200)), math.pi/4.0, false, true);
		return;
	end
end
