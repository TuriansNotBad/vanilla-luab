
--------------------------------------------------------------------
--                      Trapped in the Room
--------------------------------------------------------------------

local function Scholomance_TrappedAI_HandleMovement(agent, goal, targets, door)
	if (#targets == 0) then
		-- move to waypoint if no enemies
		local x,y,z = door.go[1], door.go[2], door.go[3];
		local bShouldMove = agent:GetDistance(x,y,z) > 5.0;
		if (bShouldMove and goal:GetSubGoalNum() == 0) then
			goal:AddSubGoal(GOAL_COMMON_MoveTo, 15, x, y, z);
			Print("Scholomance_TrappedAI: move to", x,y,z);
		end
		return bShouldMove;
	else
		-- cancel motion, let chase motion take over
		if (agent:GetMotionType() == MOTION_POINT and goal:GetSubGoalNum() > 0) then
			Print("Scholomance_TrappedAI: clearing motion");
			goal:ClearSubGoal();
		end
	end
	return false;
end

local function Scholomance_TrappedAI_Begin(ai, agent, goal, party, data, partyData, script)
	-- begin moving towards door to draw enemies
	agent:AttackStop();
	local gowp = script.door.go;
	goal:AddSubGoal(GOAL_COMMON_MoveTo, 5, gowp[1], gowp[2], gowp[3]);
	data["Scholomance_TrappedAI_TimeNoTargets"] = 0;
end

local function Scholomance_TrappedAI_End(ai, script)
	local data = ai:GetData();
	data["Scholomance_TrappedAI_TimeNoTargets"] = nil;
	data.targets    = nil;
	data.attackmode = nil;
	ai:GetPlayer():ClearMotion();
	if (ai:GetRole() == ROLE_SCRIPT) then
		Encounter_RestoreRole(ai, script.key);
	end
end

local function Scholomance_TrappedAI(ai, agent, goal, party, data, partyData, script)
	
	-- waiting for jump goal to finish
	if (script.done) then
		if (goal:GetSubGoalNum() == 0) then
			Command_Complete(ai, "Scholomance_TrappedAI: finished");
			Print("Scholomance_TrappedAI: has finished", agent:GetName());
		end
		return;
	end
	
	data.targets    = nil;
	data.attackmode = nil;
	local door  = script.door;
	local bOpen = GetObjectGOState(agent, door.guid) == 0;
	
	if (bOpen) then
		data.script.doorOpened = true;
		-- We're free to go
		-- Find Gandling
		goal:ClearSubGoal();
		local uGandling = AI_FindAttackerWithEntry(partyData.attackers, script.entryBoss);
		if (uGandling) then
			local _,__,gz = uGandling:GetPosition();
			local x,y,z = agent:GetPosition();
			if (z > script.bottomFloorMaxZ and gz < script.bottomFloorMaxZ) then
				-- perform jump off
				Print("Scholomance_TrappedAI: should jump off -", agent:GetName());
				script.done = true;
				goal:AddSubGoal(GOAL_COMMON_Jump, 20, door.jmp[1], door.jmp[2], door.jmp[3], door.jmp[4]);
			end
		end
		
		if (not script.done) then
			Print("Scholomance_TrappedAI: agent is done, no jump", agent:GetName());
			script.done = true;
			goal:AddSubGoal(GOAL_COMMON_MoveTo, 20, door.jmp[1], door.jmp[2], door.jmp[3]);
		end
		return;
	end
	
	local targets = GetUnitsAroundEx(agent,70.0,9.0,true,false,REP_HOSTILE,script.entry,true,false);
	if (#targets > 4) then
		Print("Scholomance_TrappedAI: Agent has more than 4 targets!", #targets, agent:GetName());
		for k,v in next,targets do
			Print(k,v,v:GetName(),v:GetPosition(),v:GetDistance(agent));
		end
		error("Scholomance_TrappedAI: Agent has more than 4 targets");
	end
	if (Scholomance_TrappedAI_HandleMovement(agent, goal, targets, door)) then
		return;
	end
	
	if (#targets == 0) then
		
		if (data["Scholomance_TrappedAI_TimeNoTargets"] == 0) then
			data["Scholomance_TrappedAI_TimeNoTargets"] = os.clock();
		end
		
		-- check for stuck script
		if (not bOpen) then
			if (os.clock() - data["Scholomance_TrappedAI_TimeNoTargets"] > 5) then
				Print("Scholomance_TrappedAI:", agent:GetName(), "is stuck");
				agent:UseObj(door.guid);
			end
		end
		return;
		
	end
	data["Scholomance_TrappedAI_TimeNoTargets"] = 0;
	
	-- see if any targets not engaged yet
	local t_noTargetList = {};
	targets.ignoreThreat = true;
	for i = 1,#targets do
		local target = targets[i];
		if (not target:GetVictim()) then
			table.insert(t_noTargetList, target);
		end
	end
	table.sort(t_noTargetList, function(a,b) return a:GetDistance(agent) > b:GetDistance(agent); end);
	
	-- attack farthest out of combat target if any
	data.attackmode = "aoe";
	if (#t_noTargetList > 0) then
		data.targets = {agent:GetVictim() or t_noTargetList[1], ignoreThreat = true};
	else
		data.targets = targets;
	end
	
	-- everyone should define CMD_ENGAGE handler
	Command_GetTable(data)[CMD_ENGAGE].Update(ai, agent, goal, party, data, partyData, data.combatFn);
	
end

local Script_ScholoTrappedAI = {
	name = "Scholomance_TrappedAI",
	key             = nil, -- Encounter key for Encounter_RestoreRole
	done            = nil, -- Stop updating script if true
	door            = nil, -- Gate info table agent is locked behind
	entry           = nil, -- Risen Guardian entry
	entryBoss       = nil, -- Gandling entry
	bottomFloorMaxZ = nil, -- Max Z value at which we consider unit to be on bottom floor
	doorOpened      = nil, -- True if door was opened at any point (to detect teleporting to the same room before CMD is over)
};

function Script_ScholoTrappedAI.Possess(hive, ai, data, key, door, bottomFloorMaxZ, entry, entryBoss)
	if (not Data_IsAgentRunningScript(ai, ai:GetData(), Script_ScholoTrappedAI.name)) then
		Command_Complete(ai, "Scholomance_TrappedAI: taking control");
		Print("Scholomance_TrappedAI: taking control of", ai:GetPlayer():GetName(), door.guid);
		AI_IsolateAgent(ai:GetPlayer(), hive, data.agents);
		if (ROLE_SCRIPT ~= ai:GetRole()) then
			Encounter_ChangeRole(ai, key, ROLE_SCRIPT);
		end
		-- setup script
		local script = table.clone(Script_ScholoTrappedAI);
		script.fnbegin         = Scholomance_TrappedAI_Begin;
		script.fnend           = Scholomance_TrappedAI_End;
		script.fn              = Scholomance_TrappedAI;
		script.key             = key;
		script.door            = door;
		script.entry           = entry;
		script.entryBoss       = entryBoss;
		script.bottomFloorMaxZ = bottomFloorMaxZ;
		Command_IssueScript(ai, hive, script);
	end
end

function Script_ScholoTrappedAI.GetDoorGuid(ai, aidata)
	if (Data_IsAgentRunningScript(ai, aidata, Script_ScholoTrappedAI.name)) then
		return aidata.script.door.guid;
	end
end

function Script_ScholoTrappedAI.HasDoorBeenOpened(ai, aidata)
	if (Data_IsAgentRunningScript(ai, aidata, Script_ScholoTrappedAI.name)) then
		return aidata.script.doorOpened;
	end
end

function Script_GetScholomanceTrappedAI()
	return Script_ScholoTrappedAI;
end

--------------------------------------------------------------------
--                          Mana Burn
--------------------------------------------------------------------

local function Scholomance_ManaBurnAI_Begin(ai, agent, goal, party, data, partyData, script)
	-- begin moving towards door to draw enemies
	agent:AttackStop();
end

local function Scholomance_ManaBurnAI_End(ai, script)
	local data = ai:GetData();
	data.targets = nil;
	ai:GetPlayer():ClearMotion();
	ai:GetPlayer():AttackStop();
	if (ai:GetRole() == ROLE_SCRIPT) then
		Encounter_RestoreRole(ai, script.key);
	end
end

local function Scholomance_ManaBurnAI(ai, agent, goal, party, data, partyData, script)
	
	if (script.done) then
		Command_Complete(ai, "Scholomance_ManaBurnAI: finished");
		return;
	end
	
	local bHealer = Encounter_GetRealRole(ai, script.key) == ROLE_HEALER;
	
	-- is target there and has enough mana
	local target = GetUnitByGuid(agent, script.guid);
	if (not target or not target:IsAlive() or target:GetPower(POWER_MANA) < script.manaThresh) then
		script.done = true;
		local endMsg = {"Scholomance_ManaBurnAI: Target no longer valid, "};
		if (target) then
			endMsg[2] = "Alive - " .. tostring(target:IsAlive());
			endMsg[3] = "Mana - " .. tostring(target:GetPower(POWER_MANA)) .. " Threshold - " .. tostring(script.manaThresh);
		else
			endMsg[2] = "target is nil";
		end
		Print(table.concat(endMsg));
		return;
	end
	
	-- is everyone healthy
	if (bHealer) then
		if (partyData.ScholoGandling_IsAnyAgentHurt) then
			script.done = true;
			Print("Scholomance_ManaBurnAI: party member is hurt, ending");
			return;
		end
	end
	
	data.targets = {target, ignoreThreat = true};
	
	-- everyone should define CMD_ENGAGE handler
	Command_GetTable(data)[CMD_ENGAGE].Update(ai, agent, goal, party, data, partyData, AI_DummyActions);
	
	local nonTankThreat,tankThreat = target:GetHighestThreat();
	local highestThreat = tankThreat > nonTankThreat and tankThreat or nonTankThreat;
	if (highestThreat - target:GetThreat(agent) < 100) then
		return;
	end
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsInPositionToCast(target, script.spellid, 2.0) ~= CAST_OK) then
		return;
	end
	agent:CastSpell(target, script.spellid, false);
	
end

local Script_ScholoManaBurnAI = {
	name = "Scholomance_ManaBurnAI",
	key           = nil, -- Encounter key for Encounter_RestoreRole
	guid          = nil, -- Target guid
	spellid       = nil, -- Spell to cast
	manaThresh    = 500, -- If target has less than this mana - stop command
	partyHpThresh =  50, -- If healer, if anyone in party below this HP - stop command
};

function Script_ScholoManaBurnAI.Possess(hive, ai, key, spellid, targetGuid, partyHpThresh, manaThresh)
	if (not Data_IsAgentRunningScript(ai, ai:GetData(), Script_ScholoManaBurnAI.name)) then
		Command_Complete(ai, "Scholomance_ManaBurnAI: taking control");
		Print("Scholomance_ManaBurnAI: taking control of", ai:GetPlayer():GetName());
		if (ROLE_SCRIPT ~= ai:GetRole()) then
			Encounter_ChangeRole(ai, key, ROLE_SCRIPT);
		end
		-- setup script
		local script = table.clone(Script_ScholoManaBurnAI);
		script.fnbegin       = Scholomance_ManaBurnAI_Begin;
		script.fnend         = Scholomance_ManaBurnAI_End;
		script.fn            = Scholomance_ManaBurnAI;
		script.key           = key;
		script.spellid       = spellid;
		script.guid          = targetGuid;
		if (partyHpThresh) then
			script.partyHpThresh = partyHpThresh;
		end
		if (manaThresh) then
			script.manaThresh = manaThresh;
		end
		Command_IssueScript(ai, hive, script);
	end
end

function Script_GetScholomanceManaBurnAI()
	return Script_ScholoManaBurnAI;
end

--------------------------------------------------------------------
--                          Kite Gandling
--------------------------------------------------------------------

local function Scholomance_KiteAI_Begin(ai, agent, goal, party, data, partyData, script)
	-- begin moving towards door to draw enemies
	agent:AttackStop();
end

local function Scholomance_KiteAI_End(ai, script)
	local data = ai:GetData();
	ai:GetPlayer():ClearMotion();
	ai:GetPlayer():AttackStop();
	if (ai:GetRole() == ROLE_SCRIPT) then
		Encounter_RestoreRole(ai, script.key);
	end
end

local function Scholomance_KiteAI(ai, agent, goal, party, data, partyData, script)
	
	if (script.done) then
		Command_Complete(ai, "Scholomance_KiteAI: finished");
		return;
	end
	
	local target = GetUnitByGuid(agent, script.guid);
	if (not target or not target:IsAlive() or target:GetVictim() ~= agent) then
		script.done = true;
		Print("Scholomance_KiteAI: Target no longer valid or not after me", agent:GetName());
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then return; end
	
	local tank;
	for i,ai in ipairs(partyData.agents) do
		if (ai:CmdType() == CMD_TANK and ai:GetRole() ~= ROLE_SCRIPT) then
			tank = ai:GetPlayer();
			break;
		end
	end
	
	if (tank) then
		
		if (not ai:IsFollowing(tank)) then
			Print("Scholomance_KiteAI: Follow tank", agent:GetName(), tank:GetName());
			agent:ClearMotion();
			agent:MoveFollow(tank, 0, 0);
		end
	
	else
	
		local tx,ty,tz = target:GetPosition();
		local mx,my,mz = agent:GetPosition();
		local bx,by,bz = 195.72,-18.14,75.59;
		local wx,wy,wz,wo = 181.342, -24.320, 88.9997, 1.563;
		local bUpperFloor = mz > 83.0;
		local bTargetUpperFloor = tz > 83.0;
		local bSameFloor = bUpperFloor == bTargetUpperFloor;
		
		if (bSameFloor) then
			
			if (agent:GetDistance(wx,wy,wz) > 5.0) then
				if (not ai:IsMovingTo(wx,wy,wz)) then
					Print("Scholomance_KiteAI: moving to top pos", agent:GetName());
					agent:ClearMotion();
					agent:MovePoint(wx,wy,wz,false);
				end
			else
				if (goal:GetSubGoalNum() == 0) then	
					Print("Scholomance_KiteAI: jump off", agent:GetName());
					agent:ClearMotion();
					goal:AddSubGoal(GOAL_COMMON_Jump,10,wx,wy,wz,wo);
					return;
				end
			end
		
		elseif (not bUpperFloor) then
			
			if (agent:GetDistance(bx,by,bz) > 3.0) then
				if (not ai:IsMovingTo(bx,by,bz)) then
					Print("Scholomance_KiteAI: moving to bottom pos", agent:GetName());
					agent:ClearMotion();
					agent:MovePoint(bx,by,bz,false);
				end
			end
		
		elseif (bUpperFloor) then
			
			if (agent:GetDistance(wx,wy,wz) > 5.0) then
				if (not ai:IsMovingTo(wx,wy,wz)) then
					Print("Scholomance_KiteAI: moving to top pos", agent:GetName());
					agent:ClearMotion();
					agent:MovePoint(wx,wy,wz,false);
				end
			end
			
		end
	
	end
	
	if (data.hot and not agent:HasAura(data.hot) and agent:GetHealthPct() < 99.0) then
		agent:CastSpell(agent, data.hot, false);
	end
	
end

local Script_ScholoKiteAI = {
	name = "Scholomance_KiteAI",
	key           = nil, -- Encounter key for Encounter_RestoreRole
	guid          = nil, -- Target guid
};

function Script_ScholoKiteAI.Possess(hive, ai, key, targetGuid)
	if (not Data_IsAgentRunningScript(ai, ai:GetData(), Script_ScholoKiteAI.name)) then
		Command_Complete(ai, "Scholomance_KiteAI: taking control");
		Print("Scholomance_KiteAI: taking control of", ai:GetPlayer():GetName());
		if (ROLE_SCRIPT ~= ai:GetRole()) then
			Encounter_ChangeRole(ai, key, ROLE_SCRIPT);
		end
		-- setup script
		local script = table.clone(Script_ScholoKiteAI);
		script.fnbegin       = Scholomance_KiteAI_Begin;
		script.fnend         = Scholomance_KiteAI_End;
		script.fn            = Scholomance_KiteAI;
		script.key           = key;
		script.guid          = targetGuid;
		Command_IssueScript(ai, hive, script);
	end
end

function Script_GetScholomanceKiteAI()
	return Script_ScholoKiteAI;
end
