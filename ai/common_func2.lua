-----------------------------------------------------------------------------------------------
-- Common LUA functions used by AI.
-- Useful functions that are not enough to be subgoals.
-- No encounter or class specific stuff here.
-----------------------------------------------------------------------------------------------

local enable_print = false;

--[[**************************************************************************
	If target doesn't have aura apply it.
	If aura to apply is nil use aura to check as aura to apply
	If bCheckOnApply is true, will not apply aura if its already applied
	If bNoCd is true, will ignore cooldown
****************************************************************************]]
function AI_ApplyAura(ai, target, bNoCd, bCheckOnApply, aura_check, aura_apply)
	if (false == target:IsAlive()) then
		return false;
	end
	aura_apply = aura_apply or aura_check;
	local agent = ai:GetPlayer();
	if (type(aura_check) ~= "number") then error("Not a number passed to AI_ApplyAura") end
	if (not target:HasAura(aura_check)) then
		if (bNoCd) then
			agent:RemoveSpellCooldown(aura_apply);
		end
		if (bCheckOnApply and target:HasAura(aura_apply)) then
			return false;
		end
		return agent:CastSpell(target, aura_apply, false);
	end
	return false;
end

local function AI_ApplyAuraLvl(ai, target, nocd, checkapply, spellID, level)
	if (ai:GetPlayer():GetLevel() >= level) then
		return AI_ApplyAura(ai, target,nocd, checkapply, spellID);
	end
	return false;
end

local function AI_TryCastSpellLvl(ai, target, spell, bAura, level)
	if (ai:GetPlayer():GetLevel() >= level) then
		if (bAura and target:HasAura(spell)) then
			return false;
		end
		return ai:GetPlayer():CastSpell(target, spell, false);
	end
	return false;
end


local function CheckAction(ai, agent, action, level, powerType, dist)
	
	-- check level
	if (action.lvl and action.lvl > level) then
		return false;
	end
	
	-- check power pct
	if (action.minPowerPct and agent:GetPowerPct(powerType) < action.minPowerPct) then
		return false;
	end
	
	-- check power pct
	if (action.maxPowerPct and agent:GetPowerPct(powerType) >= action.maxPowerPct) then
		return false;
	end
	
	-- check distance
	if (action.maxDist and action.maxDist < dist) then
		return false;
	end
	
	-- check talents
	if (action.reqTalent == false) then
		return false;
	end
	
	-- check melee
	if (action.isMelee and agent:GetCurrentSpellId(CURRENT_MELEE_SPELL) ~= -1) then
		return false;
	end
	
	return true;
	
end

function AI_DoAction(ai, actionTable, target)
	
	local agent = ai:GetPlayer();
	local powerType = agent:GetPowerType();
	local level = agent:GetLevel();
	local dist = agent:GetDistance(target);
	
	for i = 1, #actionTable do
	
		local action = actionTable[i];
		
		-- check level
		if (CheckAction(ai, agent, action, level, powerType, dist)) then
			
			local spellTarget = target;
			if (action.target == "self") then
				spellTarget = agent;
			end
			
			if (action[1] == nil) then
				error("AI_DoAction: spellID was nil .. " .. tostring(action.msg));
			end
			
			-- try do action
			if (action.isAura) then
			
				local result = AI_ApplyAura(ai, spellTarget, false, true, action[1]);
				if (result == CAST_OK) then
					if (enable_print and action.msg) then
						print(action.msg .. " aura apply success", agent:GetName(), spellTarget:GetName(), action[1], level, dist, agent:GetPowerPct(powerType));
					end
					return true;
				end
				
			else
			
				local result = agent:CastSpell(spellTarget, action[1], false);
				if (result == CAST_OK) then
					if (enable_print and action.msg) then
						print(action.msg .. " cast success", agent:GetName(), spellTarget:GetName(), action[1], level, dist, agent:GetPowerPct(powerType));
					end
					return true;
				end
				
			end
			
		end
		
	end
	
end


function AI_JoinBG(ai, bgtype)

	local agent = ai:GetPlayer();
	-- road to bg
	if (not agent:InBattleGround()) then
		
		-- join assigned queue
		if (not agent:InBattleGroundQueue(true)) then
			agent:JoinBattleGroundQueue(bgtype);
		end
		
		-- accept bg invite
		if (ai:HasBgInvite()) then
			ai:AcceptBgInvite();
		end
		
		return;
	end
	
end


function AI_LeaveBG(ai)

	if (ai:ShouldLeaveBg()) then
		local userT = ai:GetUserTbl();
		-- init timer
		if (userT._bgLeaveTimer == nil) then
			userT._bgLeaveTimer = os.time() + 5;
		end
		-- check timer
		if (os.time() < userT._bgLeaveTimer) then
			return;
		end
		ai:LeaveBattlefield();
		ai:GetUserTbl()._mustDelete = true;
		userT._bgLeaveTimer = nil;
	end
	
end


function AI_IsValidTarget(ai, target, nopfcheck)
	
	local x,y,z = target:GetPosition();
	if (nopfcheck == false and not ai:GetPlayer():DoesPathExist(x,y,z)) then
		return false;
	end
	return ai:IsValidHostileTarget(target) and target:IsAlive();	
	
end


function AI_GetClosestTarget(ai, attackers, nopfcheck)
	
	local agent = ai:GetPlayer();
	if (#attackers > 0) then
		
		local _closestTarget;
		local _closestDist = 99999999;
		for i = 1, #attackers do
			local dist = agent:GetDistance(attackers[i]);
			if (_closestDist > dist and AI_IsValidTarget(ai, attackers[i], nopfcheck)) then
				_closestDist = dist;
				_closestTarget = attackers[i];
			end
		end
		
		return _closestTarget, _closestDist;
		
	end
	
end



