--[[*******************************************************************************************
	Common functions for tanks.
	Notes:
		<blank>
*********************************************************************************************]]

function Tank_GetLowestHpTarget(ai, agent, party, targets, threatCheck, minDiff)
	
	for i = 1, #targets do
		local target = targets[i];
		local _,tankThreat = target:GetHighestThreat();
		local diff  = tankThreat - target:GetThreat(agent);
		if (diff > minDiff or false == threatCheck) and (nil == party or false == party:IsCC(target)) then
			return target;
		end
	end
	
end

function Tank_AnyTankOnTarget(tanks, target)
	for i = 1, #tanks do
		local ai = tanks[i];
		if (ai:CmdType() == CMD_TANK and ai:CmdArgs() == target:GetGuid()) then
			return true;
		end
	end
	return false;
end

function Tank_GetTankOnTarget(tanks, target)
	for i = 1, #tanks do
		local ai = tanks[i];
		if (ai:CmdType() == CMD_TANK and ai:CmdArgs() == target:GetGuid()) then
			return ai;
		end
	end
	return nil;
end

function Tank_GetMinTankThreat(tanks, target)
	local minThreat = 999999.0;
	for i = 1, #tanks do
		local ai = tanks[i];
		local agent = ai:GetPlayer();
		local threat = target:GetThreat(agent);
		if (agent:GetVictim() == target and threat < minThreat) then
			minThreat = threat
		end
	end
	return minThreat;
end

function Tank_GetTankThreat(data, target)
	if (data.encounter and data.encounter.tankswap) then
		return Tank_GetMinTankThreat(data.tanks, target);
	end
	local _,threat = target:GetHighestThreat();
	return threat;
end

function Tank_AnyTankPulling(tanks)
	for i = 1, #tanks do
		local ai = tanks[i];
		if (ai:CmdType() == CMD_PULL) then
			return true;
		end
	end
	return false;
end

function Tank_GetTargetList(targets, tanks)
	
	-- make a list of targets in descending order of priority to get a tank on
	local list = {};
	for i = 1, #targets do
		local target = targets[i];
		-- score targets
		-- if target can't be tanked do not consider it - don't insert
		-- if target already has a tank on it we do not consider it - don't insert
		if (target:CanHaveThreatList() and not Tank_AnyTankOnTarget(tanks, target)) then
			-- if target is not attacking a tank - 1
			local targetVictim = target:GetVictim();
			if (nil == targetVictim or targetVictim:GetRole() ~= ROLE_TANK) then
				table.insert(list, {1, 1, target});
			else
				-- rating based on threatMaxNotTank/threatTankMax;
				local threatMaxNotTank, threatTankMax = target:GetHighestThreat();
				if (threatTankMax == 0) then
					table.insert(list, {1, 1, target});
				else
					table.insert(list, {threatMaxNotTank, threatTankMax, target});
				end
			end
			-- if target is far less likely to switch. Max points at CanReachWithMeleeAttack. Reduce to min of 0.5. Best handled when considering momentum.
			-- MAYBE: if target is about to die reduce points
		end
	end
	table.sort(list, function(a,b) return (a[2] - a[1]) < (b[2] - b[1]); end);
	return list;
	
end

function Tank_ShouldTankTarget(ai, target, threatNotTank, threatTank, aoeTarget)
	
	if (nil == target or ai:CmdType() == CMD_PULL) then
		return false;
	end
	
	local agent = ai:GetPlayer();
	
	if (AI_IsIncapacitated(agent)) then
		return false;
	end
	
	local curTarget = ai:CmdType() == CMD_TANK and GetUnitByGuid(agent, ai:CmdArgs()) or agent:GetVictim();
	if (nil == curTarget) then
		-- Print("Switching target because I had no target", agent:GetName(), ai:CmdType(), ai:CmdType() > 0 and ai:CmdArgs());
		return true, 0.0;
	end
	
	if (curTarget:GetVictim() ~= agent) then
		return false;
	end
	
	local curThreatNotTank, curThreatTank = curTarget:GetHighestThreat();
	
	local curThreatDiff 		= curThreatTank - curThreatNotTank;
	local threatDiff 			= threatTank - threatNotTank;
	local stdThreat	 			= aoeTarget > 0 and aoeTarget or ai:GetStdThreat() * 2;
	local bCriticalThreat 		= threatDiff < ai:GetStdThreat() * 2;
	local bCurCriticalThreat 	= ai:CmdType() == CMD_TANK and curThreatDiff < ai:GetStdThreat() * 2;
	
	-- tank was dpsing target (or idling) when other tank switched target or died (or never existed)
	if (curTarget == target) then
		return true, threatTank + stdThreat;
	end
	
	if (target:GetVictim() and target:GetVictim():GetRole() ~= ROLE_TANK --[[and curThreatDiff > ai:GetStdThreat()]]) then
		Print("Switching target cos its attacking non tank and mine is ok =", curThreatDiff, curThreatTank, curThreatNotTank, ai:GetStdThreat(), target:GetName());
		return true, 0.0;
	end
	
	if (bCurCriticalThreat) then
		Print("Rejecting target cos mine is critical diff =", curThreatDiff, curThreatTank, curThreatNotTank, ai:GetStdThreat() * 2, target:GetName());
		return false;
	end
	
	if (bCriticalThreat) then
		Print("Switching target due to critical threat diff =", threatDiff, threatTank, threatNotTank, ai:GetStdThreat() * 2, target:GetName());
		return true, threatTank + ai:GetStdThreat() * 2;
	end
	
	local distRate = 1.0;
	if (not agent:CanReachWithMelee(target)) then
		distRate = 1 - agent:GetDistance(target)/30.0;
	end
	
	if (distRate < 0.6) then
		-- Print("Rejecting target due to distance", distRate);
		return false;
	end
	
	if ((ai:CmdType() ~= CMD_TANK or ai:CmdIsRequirementMet()) and curThreatTank - threatTank > stdThreat) then
		-- Print("Switching target for aoe ctt =", curThreatTank, "tt =", threatTank, "std =", stdThreat, "dist = ", distRate);
		return true, threatTank + stdThreat;
	end
	return false;
	
end

function Tank_BringTargetToPos(ai, agent, target, x, y, z)
	
	if (x and target:GetDistanceEx(x,y,z,2) > 4) then
		
		-- can't do anything
		if (target:GetVictim() ~= agent and false == target:HasAuraType(AURA_MOD_TAUNT)) then
			return true;
		end
		
		if (Unit_IsCrowdControlled(target)) then
			return true;
		end
		
		local agentD = agent:GetDistance(x,y,z);
		if (agent:GetMotionType() ~= MOTION_POINT and agentD > 1) then
			agent:ClearMotion();
			agent:MovePoint(x,y,z,false);
			Print("Tank_BringTargetToPos: moving to point. Distance =", agentD, target:GetDistanceEx(x,y,z,2), agent:GetName());
			return false;
		end
		
		if (agentD <= 1 and agent:CanReachWithMelee(target)) then
			Print("Tank_BringTargetToPos: standing at point but targetD =", target:GetDistanceEx(x,y,z,2), "agentD =", agentD, agent:GetName());
			return true;
		end
		
		return false;
	end
	return true;
	
end
