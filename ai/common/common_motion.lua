
function Movement_Init(data)
	data.move = {rq = {}};
end

function Movement_ClearRequests(data)
	if (data.move) then
		data.move.rq = {};
	end
end

local function Movement_HandleHoldArea(ai, agent, goal, target, area, role)
	
	if (not target or not area) then return false; end
	
	if (false == AI_TargetInHoldingArea(target, area)) then
		
		if (ROLE_TANK == role) then
			if (ai:CmdType() == CMD_ENGAGE) then
			
				local bSwap = Data_GetEncounterTankSwap(encounter) and target:GetName() == partyData.encounter.name;
				local _,threat = target:GetHighestThreat();
				local threatdiff = threat - target:GetThreat(agent);
				-- tank swap encounters shouldn't do this
				if (bSwap and threatdiff >= 1000) then
					return true;
				end
				
			elseif (ai:CmdType() == CMD_TANK) then
				
				-- active tank should roam after target if doesn't have aggro
				if (target:GetVictim() ~= agent) then
					return false;
				end
				
			end
		end
		
		if (agent:GetDistance(area.dpspos.x, area.dpspos.y, area.dpspos.z) > 2.0) then
			goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, area.dpspos.x, area.dpspos.y, area.dpspos.z);
		end
		return true;
		
	else
		
		-- force going into the area asap for ranged
		if (ROLE_RDPS == role or ROLE_HEALER == role) then
			if (agent:GetDistance(area.dpspos.x, area.dpspos.y, area.dpspos.z) > 2.0) then
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, area.dpspos.x, area.dpspos.y, area.dpspos.z);
				return true;
			end
		end
		
	end
	return false;
	
end

local function Movement_HandleRchrpos(ai, agent, goal, rchrpos, bRanged, bAllowThreatActions)
	
	-- never for active tanks
	if (not rchrpos) then return false; end
	
	local shouldGoToSpot = bRanged or not bAllowThreatActions;
	if (not bRanged) then
		local meleeMode = rchrpos.melee;
		if (meleeMode == "ignore") then
			shouldGoToSpot = false;
		elseif (meleeMode == "dance") then
			-- already set to this mode
		else
			shouldGoToSpot = true;
		end
	end
	
	if (shouldGoToSpot) then
		if (agent:GetDistance(rchrpos.x, rchrpos.y, rchrpos.z) > 3.0) then
			goal:AddSubGoal(GOAL_COMMON_MoveTo, 10.0, rchrpos.x, rchrpos.y, rchrpos.z);
		end
		return true;
	end
	return false;
	
end

function Movement_RequestMoveInPosToCast(data, guid, spell, buffer)
	data.move.rq.cast = {guid = guid, spell = spell, buffer = buffer or 2.0};
end

local function Movement_HandleMoveInPosToCast(goal, data, rchrpos)
	local cast = data.move.rq.cast
	local result = false;
	if (cast and not rchrpos) then
		goal:AddSubGoal(GOAL_COMMON_MoveInPosToCast, 10.0, cast.guid, cast.spell, cast.buffer);
		result = true;
	end
	data.move.rq.cast = nil;
	return result;
end

local function Movement_HandleDefaultChase(ai, agent, goal, party, data, target, role, distancingR, bRanged, bAllowThreatActions)
	
	-- tanks have their own chase movement
	if (CMD_TANK == ai:CmdType()) then
		Tank_CombatMovement(ai, agent, goal, target, data, party:GetData());
		return true;
	end
	
	local bHealer = ROLE_HEALER == role and CMD_HEAL == ai:CmdType();
	local bHealerCasting = bHealer and agent:IsNonMeleeSpellCasted();
	-- healer can't be interrupted by less important motion
	if (bHealerCasting) then
		local target = GetUnitByGuid(agent, ai:CmdArgs());
		if (target ~= nil and not data.ShouldInterruptPrecast(agent, target, target:IsTanking(), target:GetMaxHealth() - target:GetHealth())) then
			return false;
		end
	end
	
	if (bRanged) then
		
		-- healers never actually chase enemies in CMD_HEAL
		if (false == AI_DistanceIfNeeded(ai, agent, goal, party, distancingR, target) and not bHealer) then
			Dps_RangedChase(ai, agent, target, bAllowThreatActions);
		elseif (bHealerHealing) then
			data.InterruptCurrentHealingSpell(ai, agent, goal);
		end
		
	else
		Dps_MeleeChase(ai, agent, target, bAllowThreatActions and not agent:HasAuraType(AURA_MOD_STEALTH));
	end
	
	return true;
	
end

function Movement_Process(ai, goal, party, target, bRanged, bAllowThreatActions)
	
	local role  = ai:GetRole();
	local agent = ai:GetPlayer();
	
	local data      = ai:GetData();
	local partyData = party:GetData();
	
	local move = data.move;
	local rq   = move.rq;
	
	local encounter   = partyData.encounter;
	local holdarea    = Data_GetEncounterHoldArea(encounter);
	local rchrpos     = Data_GetRchrpos(data, encounter);
	local distancingR = holdarea and -1.0 or Data_GetEncounterDistancingR(encounter, 5.0);
	
	-- active tanks only care about hold area
	if (ai:CmdType() == CMD_TANK) then
		if          (Movement_HandleHoldArea(ai, agent, goal, target, holdarea, role))
		then elseif (Movement_HandleDefaultChase(ai, agent, goal, party, data, target, role, distancingR, bRanged, bAllowThreatActions))
		then
			return true;
		end
		
		return false;
	end
	
	if          (Movement_HandleHoldArea(ai, agent, goal, target, holdarea, role))
	then elseif (Movement_HandleRchrpos(ai, agent, goal, rchrpos, bRanged, bAllowThreatActions))
	then elseif (Movement_HandleMoveInPosToCast(goal, data, rchrpos))
	then elseif (Movement_HandleDefaultChase(ai, agent, goal, party, data, target, role, distancingR, bRanged, bAllowThreatActions))
	then
		return true;
	end
	
end
