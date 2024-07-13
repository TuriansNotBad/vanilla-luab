--[[*******************************************************************************************
	Common functions for healers.
	Notes:
		<blank>
*********************************************************************************************]]

local SHOULD_HEAL_UNABLE_TO_CAST         =  0;
local SHOULD_HEAL_REQUIREMENT_NOT_MET    = -1;
local SHOULD_HEAL_TARGET_IS_LOW_PRIORITY = -2;
local SHOULD_HEAL_TARGET_IS_HOSTILE      = -3;

function Healer_GetHealPriority(target, mp, hot, bTopAll)
	
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
	
	if (bTopAll) then
		if (hp < 30) then
			return 5;
		end
		if (hp < 80 and hot and false == target:HasAura(hot) and ROLE_TANK ~= target:GetRole()) then
			return 3;
		end
		if (hp < 70) then
			return 3;
		end
	end
	
	-- only heal nontank with hots
	if (nil == hot or false == target:HasAura(hot)) then
		-- only take on really endangered nontanks
		if ((hp < 55 and target:GetAttackersNum() > 0) or hp < 40) then
			return 3;
		end
		-- should we spare mana for nontanks at all
		if (hp < 60 or (mp > 0.90 and hp < 70)) then
			return 1;
		end
	end
	return 0;

end

function Healer_ShouldHealTarget(ai, target, bTopAll)
	
	local agent 	= ai:GetPlayer();
	local mp 		= agent:GetPowerPct(POWER_MANA)/100.0;
	local curTarget = ai:GetHealTarget();
	local data 		= ai:GetData();
	local cmd       = ai:CmdType();
	
	if (AI_IsIncapacitated(agent) or cmd == CMD_DISPEL or agent:GetStandState() ~= STAND_STATE_STAND) then
		return SHOULD_HEAL_UNABLE_TO_CAST;
	end
	
	if (target:CanAttack(agent)) then
		return SHOULD_HEAL_TARGET_IS_HOSTILE;
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
		return SHOULD_HEAL_REQUIREMENT_NOT_MET;
	end
	
	-- judge by priority
	local curPrio = Healer_GetHealPriority(curTarget, mp, data.hot, bTopAll or false == agent:IsInCombat());
	local tarPrio = Healer_GetHealPriority(target, mp, data.hot, bTopAll or false == agent:IsInCombat());
	if (tarPrio > curPrio) then
		return mp;
	end
	return SHOULD_HEAL_TARGET_IS_LOW_PRIORITY;
	
end

function Healer_GetTargetList(tracked, targets)
	
	local list = {};
	if (targets) then
		for i = 1, #targets do
			
			local target = targets[i]:GetPlayer();;
			if (target:IsAlive() and target:GetHealthPct() < 95) then
				table.insert(list, target);
			end
			
		end
	end
	if (tracked) then
		for i = 1, #tracked do
			
			local target = tracked[i];
			if (target:IsAlive() and target:GetHealthPct() < 95) then
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
