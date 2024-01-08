--[[*******************************************************************************************
	Common functions for healers.
	Notes:
		<blank>
*********************************************************************************************]]

function Healer_GetHealPriority(target, mp, hot)
	
	if (not target) then
		return 0;
	end
	
	local hp = target:GetHealthPct();
	if (target:IsTanking()) then
	
		-- never switch off unhealthy tank
		if (hp < 60) then
			return 4;
		end
		
		-- will switch to slightly hurt tank with nothing better todo
		if (hp < 85) then
			return 2;
		end
		
	end
	
	-- only heal nontank with hots
	if (nil == hot or false == target:HasAura(hot)) then
		-- only take on really endangered nontanks
		if ((hp < 55 and target:GetAttackersNum() > 0) or hp < 30) then
			return 3;
		end
		-- should we spare mana for nontanks at all
		if (hp < 50 or (mp > 0.90 and hp < 70)) then
			return 1;
		end
	end
	return 0;

end

function Healer_ShouldHealTarget(ai, target)
	
	local agent 	= ai:GetPlayer();
	local mp 		= agent:GetPowerPct(POWER_MANA)/100.0;
	local curTarget = ai:GetHealTarget();
	local data 		= ai:GetData();
	local cmd       = ai:CmdType();
	
	if (false == agent:IsAlive() or cmd == CMD_DISPEL or agent:GetStandState() ~= STAND_STATE_STAND) then
		return 0.0;
	end
	
	-- take on anyone
	if (nil == curTarget and not agent:IsInCombat()) then
		return mp;
	end
	
	-- avoid switching constantly
	if (ai:CmdType() == CMD_HEAL and not ai:CmdIsRequirementMet()) then
		if (curTarget and not curTarget:IsTanking()) then
			if (target:IsTanking() and target:GetHealthPct() < 25.0) then
				return mp;
			end
		end
		return 0.0;
	end
	
	-- judge by priority
	local curPrio = Healer_GetHealPriority(curTarget, mp, data.hot);
	local tarPrio = Healer_GetHealPriority(target, mp, data.hot);
	if (tarPrio > curPrio) then
		return mp;
	end
	return 0.0;
	
end

function Healer_GetTargetList(tracked, targets)
	
	local list = {};
	if (targets) then
		for i = 1, #targets do
			
			local target = targets[i]:GetPlayer();;
			if (target:GetHealthPct() < 95) then
				table.insert(list, target);
			end
			
		end
	end
	if (tracked) then
		for i = 1, #tracked do
			
			local target = tracked[i];
			if (target:GetHealthPct() < 95) then
				table.insert(list, target);
			end
			
		end
	end
	local function sort(a,b)
		local asymmetry = a:GetRole() ~= b:GetRole();
		local tank, nonTank;
		if (asymmetry) then
			tank = (a:GetRole() == ROLE_TANK and a) or (b:GetRole() == ROLE_TANK and b);
			nonTank = (a:GetRole() ~= ROLE_TANK and a) or (b:GetRole() ~= ROLE_TANK and b);
		end
		if (tank) then
			if (tank:GetHealthPct() > 70 and nonTank:GetHealthPct() < 35) then
				return b:GetRole() ~= ROLE_TANK;
			end
			return a:GetRole() == ROLE_TANK;
		end
		return a:GetHealthPct() < b:GetHealthPct()
	end
	table.sort(list, sort);
	return list;
	
end
