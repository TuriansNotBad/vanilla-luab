--[[*******************************************************************************************
	Common encounter script functions
*********************************************************************************************]]

import 'ai/util.lua'

-- remember everyone's roles
function Encounter_PreprocessAgents(key, data, fnForEach)
	for i,ai in ipairs(data.agents) do
		local aidata = ai:GetData();
		if (nil == aidata[key]) then
			aidata[key] = ai:GetRole();
		end
		if (fnForEach) then
			fnForEach(ai, ai:GetPlayer(), aidata, data);
		end
	end
end

-- reset everyone's roles
function Encounter_RestoreAgents(key, data, fnOnRestore)
	for i,ai in ipairs(data.agents) do
		local agent = ai:GetPlayer();
		local aidata = ai:GetData();
		if (fnOnRestore) then
			fnOnRestore(ai, agent, aidata, data);
		end
		if (aidata[key]) then
			Command_ClearAll(ai, key .. ".RestoreAgents");
			ai:SetRole(aidata[key]);
			aidata[key] = nil;
		end
	end
end

-- sets a temporary role to ai
function Encounter_ChangeRole(ai, key, newRole)
	if (nil == ai:GetData()[key]) then
		error(key .. ".ChangeRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	ai:SetRole(newRole);
end

-- returns real role of ai
function Encounter_GetRealRole(ai, key)
	local data = ai:GetData();
	if (nil == data[key]) then
		error(key .. ".GetRealRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	return data[key];
end

-- resets agent role
function Encounter_RestoreRole(ai, key)
	local data = ai:GetData();
	if (data[key]) then
		ai:SetRole(data[key]);
		return;
	end
	error(key .. ".RestoreRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
end

function Encounter_MakeLOSTbl()
	
	local self = {};
	
	local function _new_los_spot_gpos(tbl)
		self[#self].gpos = tbl;
		return self;
	end
	
	local function _new_los_spot_tpos(tbl)
		self[#self].tpos = tbl;
		return _new_los_spot_gpos;
	end
	
	local function _new_los_spot(name)
		table.insert(self, {name = name, r = 25.0});
		return _new_los_spot_tpos;
	end
	
	local function _end()
		self.new,self.endtbl = nil,nil;
		return self;
	end
	
	self.new = _new_los_spot;
	self.endtbl = _end;
	return self;
end

function Encounter_MakeAreaTbl(losInfo)
	local self = {};
	local tempPts;
	local curName;
	
	local function _find_los(lostbl, losname)
		for i,v in ipairs(lostbl) do
			if (v.name == losname) then
				return v;
			end
		end
	end
	
	local function _new_shape_pt(a,b,c,d)
		if (type(a) == "table") then
			table.insert(tempPts, makePoint2d(a[1], a[2]));
			return _new_shape_pt;
		else
			if (#tempPts < 3) then
				error("Polygon doesn't have enough vertices");
			end
			local los = _find_los(losInfo, a);
			assert(los, "Couldn't find LOS info with name " .. tostring(a) .. " for area with name " .. tostring(curName));
			table.insert(self, {name=curName, shape=makePolygonArea(tempPts,b,c,d), los=los});
			curName,tempPts = nil,nil;
			return self;
		end
	end
	
	local function _new_area(name, tp)
		tempPts = {};
		curName = name;
		if (tp == SHAPE_POLYGON) then
			return _new_shape_pt;
		end
		error("Unknown shape type: "..tostring(tp));
	end
	
	local function _end()
		self.new,self.endtbl = nil,nil;
		return self;
	end
	
	self.new = _new_area;
	self.endtbl = _end;
	return self;
end

function Encounter_NewRangedList()
	return {
		IsRanged = function(self, unit)
			return self[unit:GetEntry()];
		end,
		Register = function(self, ...) 
			for i = 1,select("#",...) do self[select(i,...)] = true; end
		end
	};
end

function Encounter_PointInArea(x,y,z,area)
	return pointInArea(x,y,z,area.shape,true);
end

function Encounter_GetAreaForTargetPos(x,y,z,areaTbl)
	for i = 1,#areaTbl do
		if (Encounter_PointInArea(x,y,z,areaTbl[i])) then
			return areaTbl[i];
		end
	end
end

function Encounter_GetLosPositionsForTargetPos(x,y,z, areaTbl)
	for i = 1,#areaTbl do
		if (Encounter_PointInArea(x,y,z,areaTbl[i])) then
			return areaTbl[i].los;
		end
	end
end

function Encounter_GetLosPositionsForTarget(target, areaTbl)
	local x,y,z = target:GetPosition();
	return Encounter_GetLosPositionsForTargetPos(x,y,z,areaTbl)
end

function EncounterScript_OnEnd(encounter, hive, data)
	if (not encounter) then return; end
	
	data.encounterDoneLosBreakOnce = nil;
	data.forceCombatUpdate         = nil;
	data.bAnyRangedOutOfLos        = nil;
	Print("Encounter ended", encounter.name);
	
	if (encounter.script and encounter.script.OnEnd) then
		encounter.script:OnEnd(hive, data);
	end
end

function EncounterScript_Update(encounter, hive, data)
	if (not encounter) then return; end
	
	if (encounter.UseLosBreakForPull) then
		if (#data.attackers == 0) then
			data.encounterDoneLosBreakOnce = nil;
			data.forceCombatUpdate         = nil;
			data.bAnyRangedOutOfLos        = nil;
		else
			EncounterScript_LosBreakUpdate(hive, data, data.dungeon.AreaTbl, data.dungeon.RangedTbl);
		end
	end
	
	if (encounter.script and encounter.script.Update) then
		encounter.script:Update(hive, data);
	end
end

function EncounterScript_UpdatePostAgentProcess(encounter, hive, data)
	if (not encounter) then return; end
	
	if (encounter.script and encounter.script.UpdatePostAgentProcess) then
		encounter.script:UpdatePostAgentProcess(hive, data);
	end
end

function EncounterScript_LosBreakRemoveRangedAttackers(rangedTbl, attackers)
	local removed = false;
	local hasRanged = false;
	for i = #attackers,1,-1 do
		local target = attackers[i];
		if (rangedTbl:IsRanged(attackers[i]) and not Unit_IsCrowdControlled(target)) then
			hasRanged = true;
			-- remove ranged enemies not in los
			local victim = target:GetVictim();
			if (victim) then
				if (target:GetDistance(victim) > 40 or not target:IsInLOS(victim)) then
					table.remove(attackers, i);
					removed = true;
				end
			end
		end
	end
	return hasRanged,removed;
end

function EncounterScript_LosBreakUpdateAgents(hive, data, areaTbl, bHasRangedEnemies, bAnyRangedOutOfLos)
	data.bAnyRangedOutOfLos = bAnyRangedOutOfLos;
	if (not data.originalEnemyPos) then return; end
	
	-- local area;
	if (not bHasRangedEnemies) then
		-- area = Encounter_GetAreaForTargetPos(data.originalEnemyPos[1], data.originalEnemyPos[2], data.originalEnemyPos[3], areaTbl);
		-- if (not area or not area.all) then
			return;
		-- end
	end
	
	-- alter tank pulling behaviour
	local bOkToLosBreak = not data.encounterDoneLosBreakOnce;
	data.forceCombatUpdate = bHasRangedEnemies and #data.attackers == 0;
	
	local losPos;
	if (bOkToLosBreak) then
		-- losPos = area.los or Encounter_GetLosPositionsForTargetPos(data.originalEnemyPos[1], data.originalEnemyPos[2], data.originalEnemyPos[3], areaTbl);
		losPos = Encounter_GetLosPositionsForTargetPos(data.originalEnemyPos[1], data.originalEnemyPos[2], data.originalEnemyPos[3], areaTbl);
	end
	
	local bTankPulling = false;
	for i,ai in ipairs(data.agents) do
	
		local agent = ai:GetPlayer();
		local aidata = ai:GetData();
		if (ai:GetRole() == ROLE_TANK) then
		
			if (ai:CmdType() == CMD_PULL) then
				
				bTankPulling = true;
				local goal = ai:GetTopGoal();
				if (goal:GetActiveSubGoalId() == GOAL_COMMON_Pull) then
					-- pull to los pos
					local target = GetUnitByGuid(agent, ai:CmdArgs());
					local losPos = Encounter_GetLosPositionsForTargetPos(data.originalEnemyPos[1], data.originalEnemyPos[2], data.originalEnemyPos[3], areaTbl);
					if (losPos and target and target:GetVictim()) then
						goal:ClearSubGoal();
						goal:AddSubGoal(GOAL_COMMON_MoveTo, 20.0, losPos.tpos[1], losPos.tpos[2], losPos.tpos[3]);
						Print("Scholomance.Global.Update: redirecting pull", agent:GetName(), losPos.tpos[1], losPos.tpos[2], losPos.tpos[3]);
					end
				end
			
			elseif (ai:CmdType() == CMD_TANK and not data.encounterDoneLosBreakOnce) then
				data.encounterDoneLosBreakOnce = true;
				bOkToLosBreak = false;
				return;
			end
			
			-- set the timer, used by tank to avoid moving for precise LoS pulls
			if (bAnyRangedOutOfLos and ai:CmdType() == CMD_PULL) then
				ai:GetTopGoal():SetTimer(ST_TANKLOS, 10.0);
			end
			
		elseif ((bAnyRangedOutOfLos or bTankPulling) and bOkToLosBreak) then
			-- process non tanks
			if (losPos) then
				local goal = ai:GetTopGoal();
				goal:ClearSubGoal();
				Command_Complete(ai, "EncounterScript_LosBreakUpdateAgents: moving to gpos");
				goal:AddSubGoal(GOAL_COMMON_MoveTo, 20.0, losPos.gpos[1], losPos.gpos[2], losPos.gpos[3]);
			end
			data.encounterDoneLosBreakOnce = true;
		end
	
	end
	
end

function EncounterScript_LosBreakUpdate(hive, data, areaTbl, rangedTbl)
	EncounterScript_LosBreakUpdateAgents(hive, data, areaTbl, EncounterScript_LosBreakRemoveRangedAttackers(rangedTbl, data.attackers));
end
