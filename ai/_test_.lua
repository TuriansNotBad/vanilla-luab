local t_agentInfo = {
	{"Cha",LOGIC_ID_Party,"LvlTank"}, -- warrior tank (human/orc, others untested, will likely have no melee weapon)
	-- {"Pri",LOGIC_ID_Party,"LvlHeal"}, -- priest healer
	-- {"Ahc",LOGIC_ID_Party,"LvlTankSwapOnly"}, -- warrior tank (human/orc, others untested, will likely have no melee weapon)
	{"Gert",LOGIC_ID_Party,"LvlDps"}, -- mage
	{"Mokaz",LOGIC_ID_Party,"LvlDps"}, -- rogue
	-- {"Fawarrie",LOGIC_ID_Party,"FeralLvlDps"}, -- cat
	-- {"Thia",LOGIC_ID_Party,"FeralLvlDps"}, -- cat
	{"Kanda",LOGIC_ID_Party,"LvlDps"}, -- shaman
	-- {"Kanda",LOGIC_ID_Party,"LvlHeal"}, -- shaman
	-- {"Man",LOGIC_ID_Party,"LvlTank"}, -- warrior tank
	-- {"Zakom",LOGIC_ID_Party,"LvlDps"}, -- rogue
	-- {"Ahc",LOGIC_ID_Party,"LvlTank"}, -- warrior tank (human/orc, others untested, will likely have no melee weapon)
	-- {"Cynt",LOGIC_ID_Party,"LvlDps"}, -- mage
	-- {"Heswarlock",LOGIC_ID_Party,"LvlDps"}, -- Warlock
	-- {"Dan",LOGIC_ID_Party,"LvlHeal"}, -- priest healer
	-- {"Nad",LOGIC_ID_Party,"LvlHeal"}, -- priest healer 
	-- {"Deepdip",LOGIC_ID_Party,"FeralLvlWeakDps"}, 	
};

if (Util_DoesFileOpenForReading '__botlist.txt') then
	import '__botlist.txt';
	t_agentInfo = t_botListInfo;
end

local Hive_FormationRectGetAngle;

local function Hive_CanPullTarget(hive, data, target)
	if (data.disablePull) then
		return false;
	end
	if (data.encounter and data.encounter.pull) then
		return true;
	end
	return hive:CanPullTarget(target);
end

local function GetBuffAgentsTbl(data, target, key)
	data = data[key];
	local t = {};
	if (not data) then
		return t;
	end
	for i = #data, 1, -1 do
		local agent = GetPlayerByGuid(data[i]);
		if (nil == agent or nil == agent:GetAI()) then
			table.remove(data, i);
		elseif (agent:IsAlive() and (data.spellid == nil or (agent:HasEnoughPowerFor(data.spellid, true) and agent:IsSpellReady(data.spellid)))) then
			table.insert(t, agent);
		end
	end
	if (#data == 0) then
		-- data.buffs[key] = nil;
		return t;
	end
	-- it would be ideal to have a mixed sort between mana and distance
	-- but at the very least pick an agent that has enough mana to cast
	-- and isn't on cooldown if that's a consideration, ever?
	local function sort(a, b)
		-- if (a:HasEnoughPowerFor(data.spellid, false) and false == b:HasEnoughPowerFor(data.spellid, false)) then
			-- return true;
		-- end
		-- if (b:HasEnoughPowerFor(data.spellid, false) and false == a:HasEnoughPowerFor(data.spellid, false)) then
			-- return false;
		-- end
		if (a:GetStandState() == STAND_STATE_STAND and b:GetStandState() ~= STAND_STATE_STAND) then
			return true;
		end
		if (b:GetStandState() == STAND_STATE_STAND and a:GetStandState() ~= STAND_STATE_STAND) then
			return false;
		end
		return a:GetDistance(target) < b:GetDistance(target);
	end
	table.sort(t, sort);
	return t;
end

local function filter_check(filter, ai, agent, caster, encounter)
	if (nil == filter) then
		return true;
	end
	if (filter.dungeon) then
		local dungeon = t_dungeons[agent:GetMapId()];
		if (not dungeon or not dungeon.encounters) then
			return false;
		end
		if (filter.dungeon.fear ~= dungeon.encounters.fear) then
			return false;
		end
	end
	if (filter.encounter) then
		if (not encounter) then
			return false;
		end
		if (filter.encounter.fear ~= encounter.fear) then
			return false;
		end
	end
	if (filter.role and filter.role[ai:GetRole()] ~= true) then
		return false;
	end
	if (filter.party ~= nil and filter.party ~= caster:IsInSameSubGroup(agent)) then
		return false;
	end
	if (filter.notauras) then
		for i = 1, #filter.notauras do
			if (agent:HasAura(filter.notauras[i])) then
				return false;
			end
		end
	end
	return true;
end

-- data is the partyData.buffs table
local function GetClosestBuffAgent(data, targetai, target, key, filter, encounter)
	local t = GetBuffAgentsTbl(data, target, key);
	for i = 1, #t do
		local agent = t[i];
		if (false == agent:CanAttack(target) and agent:GetRole() ~= ROLE_SCRIPT) then
			local ai = agent:GetAI();
			local cmd = ai:CmdType();
			local healmax = encounter and encounter.healmax;
			if (not healmax or ai:GetRole() ~= ROLE_HEALER) then
			
				local healTarget = (cmd == CMD_HEAL or nil) and GetUnitByGuid(agent, ai:CmdArgs());
				local hot = ai:GetData().hot;
				local healPriority = Healer_GetHealPriority(healTarget, agent:GetPowerPct(POWER_MANA), hot, healmax);
				
				local healLowPrio = healTarget and not healmax and healPriority < 3;
				if (cmd == CMD_FOLLOW or cmd == CMD_NONE or cmd == CMD_ENGAGE or healLowPrio) then
					if (AI_IsAvailableToCast(ai, agent, target, data[key].spellid) and filter_check(filter, targetai, target, agent, encounter)) then
						return agent;
					end
				end
				
			end
		end
	end
end

local function _DispelCanDoHostile(spellid, key, agent)
	if (key == "Magic" and agent:GetClass() == CLASS_PRIEST) then
		return true;
	end
	return false;
end

-- data is the partyData.dispel table
local function GetClosestDispelAgent(data, targetai, target, key, friendly, encounter)
	if (not data[key]) then
		return;
	end
	local t = GetBuffAgentsTbl(data, target, key);
	for i = 1, #t do
		local agent = t[i];
		local ai = agent:GetAI();
		local aidata = ai:GetData();
		local spellid = aidata.dispels[key];
		if ((false == agent:CanAttack(target) or false == friendly or _DispelCanDoHostile(spellid, key, agent)) and agent:GetRole() ~= ROLE_SCRIPT) then
		
			local cmd = ai:CmdType();
			local healmax = encounter and encounter.healmax;
			
			if (not healmax or ai:GetRole() ~= ROLE_HEALER) then
				local healTarget = (cmd == CMD_HEAL or nil) and GetUnitByGuid(agent, ai:CmdArgs());
				local hot = aidata.hot;
				local healPriority = Healer_GetHealPriority(healTarget, agent:GetPowerPct(POWER_MANA), hot, healmax);
				
				-- Print("Dispel search: heal target, heal priority =", healTarget and healTarget:GetName(), healPriority);
				
				local healLowPrio = healTarget and not healmax and healPriority < 3;
				-- Print(cmd, cmd == CMD_HEAL and Healer_GetHealPriority(healTarget, agent:GetPowerPct(POWER_MANA)));
				if (cmd == CMD_FOLLOW or cmd == CMD_NONE or cmd == CMD_ENGAGE or healLowPrio) then
					local valid = --[[friendly or]] not target:IsImmuneToSpell(spellid);
					if (spellid and valid and AI_IsAvailableToCast(ai, agent, target, spellid)) then
						return agent;
					end
				end
			end
			
		end
	end
end

local function RegisterBuff(data, agent, key, str, spellid, type, time, filter, combat)
	local data = data.buffs;
	data[key] = data[key] or {str = -1, spellid = 0, type = BUFF_SINGLE, time = 0};
	-- if i'm reregistering delete old entry
	local myOldIdx = table_ifind(data[key], agent:GetGuid());
	if (myOldIdx > 0) then table.remove(data[key], myOldIdx); end
	if (str < data[key].str) then return; end
	if (str > data[key].str) then
		data[key] = {str = str, spellid = spellid, type = type, time = time, filter = filter, combat = combat};
	end
	table.insert(data[key], agent:GetGuid());
end

local function RegisterDispel(data, agent, key)
	local data = data.dispel;
	data[key] = data[key] or {};
	if (table_ifind(data[key], agent:GetGuid()) ~= 0) then
		return;
	end
	table.insert(data[key], agent:GetGuid());
end

local function HasTank(data)
	if (#data.tanks > 0) then
		for i,ai in ipairs(data.tanks) do
			if (not ai:GetPlayer():HasAuraType(AURA_MOD_CHARM)) then
			-- if (not AI_IsIncapacitated(ai:GetPlayer())) then
				return true;
			end
		end
	end
	return false;
end

local function GetFirstActiveTank(data, bAllowPull)
	for i,ai in ipairs(data.tanks) do
		if (ai:CmdType() == CMD_TANK) then
			return ai, ai:GetPlayer();
		end
		if (bAllowPull and ai:CmdType() == CMD_PULL) then
			return ai, ai:GetPlayer();
		end
	end
end

local function RegisterCC(data, agent, spellid, isfear)
	table.insert(data.ccAgents, {agent:GetGuid(), spellid, isfear = isfear or false});
end

local function ResetAgentFull(data, ai, hive)
	local agent = ai:GetPlayer();
	local guid = agent:GetGuid();
	
	Print("Hive: ResetAgentFull begin. Agent", guid);
	-- remove my cc registration
	for i = #data.ccAgents,1,-1 do
		local ccentry = data.ccAgents[i];
		if (guid == ccentry[1]) then
			Print("Hive: ResetAgentFull - unregistered cc", GetSpellName(ccentry[2]));
			table.remove(data.ccAgents, i);
		end
	end
	-- unassign any cc assigned to me
	local cc = hive:GetCC();
	for i = 1, #data.cc do
		local ai = data.cc[i].agent;
		local agent = ai:GetPlayer();
		local target = data.cc[i].target;
		if (agent:GetGuid() == guid) then
			Print("Hive: ResetAgentFull - unassigned cc target", target:GetGuid(), target:GetName());
			hive:RemoveCC(target:GetGuid());
		end
	end
	local function unregister_table(data, guid, tablekey)
		data = data[tablekey];
		for k,v in next,data do
			for i = #v,1,-1 do
				if (v[i] == guid) then
					Print("Hive: ResetAgentFull - unregister tbl", tablekey, k);
					table.remove(v, i);
				end
			end
			if (#v == 0) then
				data[k] = nil;
				Print("Hive: ResetAgentFull - table is empty, removed", tablekey, k);
			end
		end
	end
	-- Unregister buffs
	unregister_table(data, guid, "buffs");
	-- Unregister dispels
	unregister_table(data, guid, "dispel");
	-- Remove me from the board
	AI_UnpostAllBuffsForCaster(guid);
	Print("Hive: ResetAgentFull end. Agent", guid);
end

function Hive_Init(hive)
	Cmd_InitDefaultHandlers();
	hive:LoadInfoFromLuaTbl(t_agentInfo);
	local data = hive:GetData();
	data.ccAgents = {};
	data.buffs = {};
	data.dispel = {};
	data.RegisterBuff = RegisterBuff;
	data.RegisterCC = RegisterCC;
	data.RegisterDispel = RegisterDispel;
	data.ResetAgentFull = ResetAgentFull;
	data.HasTank = HasTank;
	data.GetFirstActiveTank = GetFirstActiveTank;
	data.dungeon = nil;
	data.encounter = nil;
	-- local item = Item_GetItemFromId(12048);
	-- item:PrintRandomEnchants();
	-- Items_PrintItemsOfType(ItemClass.Weapon, ItemSubclass.WeaponAxe2, -1);
end

local function FillTrackedForMap(agent, tracked)
	local t = t_dungeons[agent:GetMapId()];
	if (t == nil or t.trackedunit == nil) then
		return;
	end
	t = t.trackedunit;
	for i,npcinfo in ipairs(t) do
		local unit = GetUnitByGuidEx(agent, npcinfo.e, npcinfo.c);
		if (unit and unit:IsAlive()) then
			table.insert(tracked, unit);
		end
	end
end

local function FillTrackedAttackers(attackers, tracked)
	for i,unit in ipairs(tracked) do
		local t = unit:GetAttackers();
		for j,attacker in ipairs(t) do
			if (table_ifind(attackers, attacker) == 0) then
				table.insert(attackers, attacker);
			end
		end
	end
end

local function Hive_UpdateMapInfo(hive, data)
	
	local player = data.owner or (data.agents[1] and data.agents[1]:GetPlayer());
	if (not player) then
		return;
	end
	
	local mapId = player:GetMapId();
	if (mapId ~= data._currentMapId) then
	
		Print("Hive: Map change from", data._currentMapId, "to", mapId);
		data.dungeon = GetDungeon(mapId);
		
		if (data.dungeon and data.dungeon.OnLoad) then
			data.dungeon:OnLoad(hive, data, player);
		end
		
		data._currentMapId = mapId;
		hive:InitTriggersForMap(mapId);
		
	end
	
end

function Hive_Update(hive)
	
	local data = hive:GetData();
	data.hostileTotems = {};
	data.attackers = hive:GetAttackers();
	data.agents = hive:GetAgents();
	data.owner = nil;
	data.anyAgentInCombat = false;
	table.sort(data.attackers, function(a, b) return a:GetHealth() < b:GetHealth(); end);
	data.healers = {};
	data.tanks = {};
	data.rdps = {};
	data.mdps = {};
	data.tracked = {};
	data.healTargets = {};
	data.cc = hive:GetCC();
	data.forcedCc = {min = 1};
	data._needTremor = nil;
	data._needPoisonCleansing = nil;
	data._holdPos = nil;
	data.threatGrpMax = nil;
	
	local ownerGuid = hive:GetOwnerGuid()
	local ownerVictim;
	if (ownerGuid) then
		data.owner = GetPlayerByGuid(ownerGuid);
		if (data.owner) then
			table.insert(data.tracked, data.owner);
			ownerVictim = data.owner:GetVictim();
			-- if (ownerVictim) then
				-- local x,y,z = hive:GetCLinePInLosAtD(data.owner, ownerVictim, 10, 15, 1, false);
				-- local px,py,pz = data.owner:GetPosition();
				-- Print(x,y,z, "you (", px,py,pz, ") D =", ownerVictim:GetDistance(data.owner));
				-- Print("you (", px,py,pz, ")");
			-- end
			-- local x,y,z = data.owner:GetPosition();
			-- fmtprint("x = %.3f, y = %.3f, z = %.3f", x, y, z);
			-- fmtprint("%.3f, %.3f, %.3f", x, y, z);
			-- Debug_PrintTable(GetObjectsNear(data.owner, x,y,z,5,true))
			-- Print(data.owner:GetCurrentSpellId(3));
			if (not data.attackers[1]) then
				-- odd bug with owner victim being stuck on ally due to gnomeregan irradiated status
				if (ownerVictim and ownerVictim:GetReactionTo(data.owner) < REP_FRIENDLY) then
					data.attackers[1] = ownerVictim;
				end
			end
		end
		for i,attacker in ipairs(data.attackers) do
			-- attacker:Kill();
			-- attacker:SetHealthPct(100.0);
		end
	end
	
	-- check for new engagement
	if (#data.attackers == 0) then
		if (not data.newEngagementStart) then
			data.newEngagementStart = true;
			data.originalEnemyPos   = nil;
			data.hasEnemies         = nil;
		end
	elseif (not data.hasEnemies) then
		data.newEngagementStart = nil;
		data.originalEnemyPos   = {data.attackers[1]:GetPosition()};
		data.hasEnemies         = true;
	end
	
	-- fill tracked
	do
		local agent = data.owner or (data.agents[1] and data.agents[1]:GetPlayer());
		if (agent) then
			Hive_UpdateMapInfo(hive, data);
			FillTrackedForMap(agent, data.tracked);
			FillTrackedAttackers(data.attackers, data.tracked);
			data.dungeon = GetDungeon(agent:GetMapId());
			local encounter = GetEncounter(agent:GetMapId(), party, data);
			-- data.encounter = GetEncounter(agent:GetMapId(), data.attackers);
			
			local function encounter_changed(old, new)
				if (not old and not new) then return false; end
				if (not old and new) then return true; end
				if (old and not new) then return true; end
				if (old.name ~= new.name) then return true; end
				return false;
			end
			
			local function on_encounter_changed(old, new, hive, data)
				
				EncounterScript_OnEnd(old, hive, data);
				
				data.encounter = new;
				Print("~~~~~~~~~~ ENCOUNTER CHANGED to", new and new.name, "from", old and old.name);
				
				if (new and new.script and new.script.OnBegin) then
					new.script:OnBegin(hive, data);
				end
				
			end
			
			if (encounter_changed(data.encounter, encounter)) then
				on_encounter_changed(data.encounter, encounter, hive, data);
			end
			
			if (encounter) then
				if (encounter.fear or encounter.sleep or encounter.charm) then
					data._needTremor = true;
				end
				if (encounter.poison) then
					data._needPoisonCleansing = true;
				end
				if (encounter.hold_area) then
					data._holdPos = encounter.hold_area;
				end
				if (encounter.summonTotems) then
					for i = 1, #encounter.summonTotems do
						local x,y,z = agent:GetPosition();
						local totems = GetUnitsWithEntryNear(agent, encounter.summonTotems[i], x, y, z, 30.0, true, true);
						if (totems[1]) then
							table.insert(data.hostileTotems, totems[1]);
						end
					end
				end
				if (encounter.enemyPrio) then
					local function sortprio(a,b)
						local prioa = encounter.enemyPrio[a:GetEntry()] or 0;
						local priob = encounter.enemyPrio[b:GetEntry()] or 0;
						return prioa > priob;
					end
					table.sort(data.attackers, sortprio);
				end
				EncounterScript_Update(encounter, hive, data);
			end
		end
	end
	
	for i = 1, #data.agents do
		local ai = data.agents[i];
		local agent = ai:GetPlayer();
		if (agent:IsInCombat()) then
			data.anyAgentInCombat = true;
		end
		if (not data.hasEnemies) then
			-- if (agent:GetHealthPct() < 30) then
				agent:SetHealthPct(100.0);
			-- end
			agent:SetPowerPct(POWER_MANA, 100.0);
			-- agent:SetPowerPct(POWER_RAGE, 100.0);
		else
			-- agent:SetHealthPct(40.0);
		end
		local role = ai:GetRole();
		if (role == ROLE_TANK) then
			table.insert(data.tanks, ai);
		elseif (role == ROLE_HEALER) then
			table.insert(data.healers, ai);
		elseif (role == ROLE_RDPS) then
			table.insert(data.rdps, ai);
		elseif (role == ROLE_MDPS) then
			table.insert(data.mdps, ai);
		end
		-- print(data.owner:GetDistance(agent));
		-- io.write(agent:GetName() .. " " .. tostring(agent:HasLostControl()) .. " ");
	end
	-- Print"";
	
	EncounterScript_UpdatePostAgentProcess(data.encounter, hive, data);
	
	if (#data.attackers == 0 and not data.forceCombatUpdate) then
		Hive_OOCUpdate(hive, data);
	else
		Hive_CombatUpdate(hive, data);
	end
	
end

local function IssueBuffCommands(hive, data, agents, iscombat)
	for i = 1, #agents do
		
		local ai = agents[i];
		local agent = ai.GetPlayer and ai:GetPlayer() or ai;
		
		if (agent:IsPlayer()) then
			for key,buff in next, data.buffs do
				if ((not iscombat == not buff.combat)
				and agent:IsAlive()
				and agent:GetAuraTimeLeft(buff.spellid) < buff.time
				and false == AI_HasBuffAssigned(agent:GetGuid(), key, buff.type))
				then
					local ally = GetClosestBuffAgent(data.buffs, ai, agent, key, buff.filter, data.encounter);
					if (ally) then
						local allyAi = ally:GetAI();
						-- if (allyAi:CmdType() == CMD_FOLLOW) then
							-- AI_PostBuff(ally:GetGuid(), agent:GetGuid(), key, true);
							-- hive:CmdBuff(allyAi, agent:GetGuid(), buff.spellid, key);
							Command_IssueBuff(allyAi, hive, agent:GetGuid(), buff.spellid, key);
							Print("CmdDBuff issued to", ally:GetName(), key, agent:GetName());
						-- end
					end
				end
			end
		end
		
	end
end

local function ShouldIssueDispel(hive, data, target, friendly, nonCombat)
	
	local dispelFilter = Data_GetDispelFilter(nil, data);
	if (nonCombat or not dispelFilter) then
		return nil;
	end
	return dispelFilter(target, hive, data, agents, friendly);
	
end

-- todo: threat check
local function IssueDispelCommands(hive, data, agents, friendly, nonCombat)
	
	if (data.bAnyRangedOutOfLos or (data.threatGrpMax and data.threatGrpMax < 20)) then
		-- Print("Dispel is blocked", data.bAnyRangedOutOfLos, data.threatGrpMax);
		return;
	end
	
	local function DoIssue(ai, agent, key)
		-- print("Key", key, agent:GetName(), agent:HasLostControl());
		if (AI_HasBuffAssigned(agent:GetGuid(), "Dispel", BUFF_SINGLE)) then
			return true;
		end
		
		local check_should_dispel = key ~= "Poison" or false == agent:HasAura(SPELL_DRD_ABOLISH_POISON);
		if (check_should_dispel) then
			check_should_dispel = key ~= "Disease" or false == agent:HasAura(SPELL_PRI_ABOLISH_DISEASE);
		end
		
		if (check_should_dispel) then
			local ally = GetClosestDispelAgent(data.dispel, ai, agent, key, friendly, data.encounter);
			if (ally) then
				local allyAi = ally:GetAI();
				-- if (allyAi:CmdType() == CMD_FOLLOW) then
					-- AI_PostBuff(ally:GetGuid(), agent:GetGuid(), "Dispel", true);
					-- hive:CmdDispel(allyAi, agent:GetGuid(), key);
					Command_IssueDispel(allyAi, hive, agent:GetGuid(), key);
					Print("CmdDispel issued to", ally:GetName(), key, agent:GetName(), "Rep =", agent:GetReactionTo(ally), ally:CanAttack(agent));
					-- not currently allowed to dispel multiple types at the same time
					return true;
				-- end
			end
		end
	end
	
	for i = 1, #agents do
		
		local ai = agents[i];
		local agent = ai.GetPlayer and ai:GetPlayer() or ai;
		
		if (agent:IsAlive() and data._needTremor ~= true) then
			data._needTremor = agent:HasAuraWithMechanics(Mask(MECHANIC_CHARM) | Mask(MECHANIC_FEAR) | Mask(MECHANIC_SLEEP));
		end
		
		if (agent:IsPlayer()
		and agent:IsAlive()
		and false == AI_HasBuffAssigned(agent:GetGuid(), "Dispel", BUFF_SINGLE)) then
			
			local should,key = ShouldIssueDispel(hive, data, agent, friendly, nonCombat);
			if (should == true) then
				DoIssue(ai, agent, key);
			elseif (should == nil) then
			
				local dispelTbl = agent:GetDispelTbl(not friendly);
				for key in next,dispelTbl do
					if (DoIssue(ai, agent, key)) then
						break;
					end
				end
			
			end
		end
		
	end
end

function Hive_OOCUpdate(hive, data)
	
	data.reverse  = nil;
	data.clineIdx = nil;
	data.aoe      = false;
	local agents = data.agents;
	
	if (#data.healers > 0) then
		local healTargets = Healer_GetTargetList(data.tracked, data.anyAgentInCombat and data.agents or nil);
		for j = 1, #healTargets do
			local target = healTargets[j];
			-- choose healers based on mana
			local healerScores = {};
			for i = 1, #data.healers do
				local healer = data.healers[i];
				local healerAgent = healer:GetPlayer();
				local maxHeal = data.encounter and data.encounter.healmax;
				if (not AI_IsIncapacitated(healer:GetPlayer()) and healer:CmdType() ~= CMD_BUFF and healerAgent:GetHealthPct() > 90) then
					table.insert(healerScores, {healer, Healer_ShouldHealTarget(healer, target, true)});
				end
			end
			-- healer with most mana
			table.sort(healerScores, function(a,b) return a[2] > b[2]; end);
			if (healerScores[1] and healerScores[1][2] > 0.0) then
				if (healerScores[1][1]:GetHealTarget() ~= target) then
					Command_IssueHeal(healerScores[1][1], hive, target:GetGuid(), 1);
				end
			end
		end
	end
	
	IssueBuffCommands(hive, data, agents);
	IssueBuffCommands(hive, data, data.tracked);
	IssueDispelCommands(hive, data, agents, true, true);
	IssueDispelCommands(hive, data, data.tracked, true, true);
	
	if (not data.owner) then
		return;
	end
	
	-- check for lootable corpses if not in free for all
	local corpses;
	if (data.owner:GetLootMode() ~= 0) then
		corpses = GetUnitsAroundEx(data.owner, 20, 10, false, false, REP_NEUTRAL, 0, false, false);
		if (#corpses == 0) then corpses = nil; end
	end
	
	local leaderX,leaderY,leaderZ = data.owner:GetPosition();
	local ori = data.owner:GetOrientation();
	local fwd = data.owner:GetForwardVector();
	
	for i = 1, #agents do
		local ai = agents[i];
		
		-- ignore scripted agents
		if (ai:GetRole() == ROLE_SCRIPT) then goto continue; end
		
		-- update level
		local agent = ai:GetPlayer();
		if (agent:GetLevel() ~= data.owner:GetLevel()) then
			ai:SetDesiredLevel(data.owner:GetLevel());
			goto continue;
		end
		
		local cmd = ai:CmdType();
		
		-- teleport to owner if far enough away
		local dist = agent:GetDistance(data.owner);
		local notBusy = cmd == CMD_FOLLOW or cmd == CMD_NONE;
		local diffMap = agent:GetMapId() ~= data.owner:GetMapId();
		if (diffMap or (dist > 50 and (notBusy or dist > 200))) then
			ai:GoName(data.owner:GetName());
			goto continue;
		end
		
		-- do not interrupt these with follow
		if (cmd == CMD_HEAL or cmd == CMD_BUFF or cmd == CMD_DISPEL or cmd == CMD_TRADE or cmd == CMD_LOOT) then
			goto continue;
		end
		
		-- loot, corpse isn't actually guaranteed to be dead
		if (corpses) then
			for i = 1, #corpses do
				if (agent:CanLootCorpse(corpses[i],0)) then
					Command_IssueLoot(ai, hive, corpses[i], 0);
					goto continue;
					break;
				end
			end
		end
		
		-- process chat
		local whisper = ai:ChatPopNextWhisper();
		if (whisper) then
			if (whisper == "inventory") then
				ai:ChatSendInvToMaster(true);
				
			elseif (string_startswith(whisper, "give")) then
				-- got a request for item trade
				local bag,slot;
				-- get bag and slot from whisper
				for n in whisper:gmatch("%d+") do
					if (not bag) then bag = tonumber(n);
					elseif (not slot) then slot = tonumber(n);
					else ai:ChatSendWhisper(ai:GetMasterGuid(), "Invalid string format for give command"); end
				end
				if (not (bag and slot)) then ai:ChatSendWhisper(ai:GetMasterGuid(), "Invalid string format for give command");
				else
					-- check i have an item in that slot that can be traded
					if (ai:EquipHasItemInSlot(bag, slot, true)) then
						Command_IssueTrade(ai, hive, data.owner, bag, slot)
					else
						ai:ChatSendWhisper(ai:GetMasterGuid(), "I do not have a tradeable item in that slot");
					end
				end
			end
			
			goto continue;
		end
		
		-- follow owner
		if (not AI_IsIncapacitated(agent) and cmd ~= CMD_FOLLOW) then
			local D, A = Hive_FormationRectGetAngle(agent, i, fwd, leaderX, leaderY, ori, data.tanks);
			Command_IssueFollow(ai, hive, ai:GetMasterGuid(), D, A);
		end
		
		::continue::
	end
	
end

function Hive_CombatUpdate(hive, data)
	
	if (data.reverse == nil and #data.attackers > 0) then
		-- local tankAI,tank = data:GetFirstActiveTank(true);
		local player = data.owner;--tank or data.owner;
		if (player and hive:HasCLineFor(player)) then
			local x,y,z,d,s,l = hive:GetNearestCLineP(data.attackers[1]);
			data.clineIdx = l;
			data.reverse = hive:ShouldReverseCLine(player, data.attackers[1], true);
			print "-----------------------------------------------------------------------";
			Print("Hive reverse", data.reverse, data.clineIdx, player:GetName());
		end
	end
	
	local encounter = data.encounter;
	local isNoCc = encounter and encounter.isNoCc;
	local isForcedCc = encounter and encounter.useForcedCc;
	local isFearAllowed = encounter and encounter.allowFearCc;
	
	-- check that we don't overassign
	local num_cc_now = 0;
	for i = #data.attackers, 1, -1 do
		if (hive:IsCC(data.attackers[i]) or Unit_IsCrowdControlled(data.attackers[i])) then
			num_cc_now = num_cc_now + 1;
		end
	end
	
	local minTargetsForCC = 2;
	local ccVsAoeCheck = #data.attackers < 6 and not data.aoe;
	if (not isNoCc and (isForcedCc or ccVsAoeCheck)) then
		for i = #data.ccAgents, 1, -1 do
			if (#data.attackers - num_cc_now <= 1) then break; end
			local guid, spellid, isfear = data.ccAgents[i][1], data.ccAgents[i][2], data.ccAgents[i].isfear;
			local fearcheck = isfear == false or isFearAllowed == true;
			-- target assigned
			local pendingCC;
			if (isForcedCc) then
				pendingCC = Party_GetCCTarget(spellid, hive, data.forcedCc, data.forcedCc.min, true);
			else
				pendingCC = Party_GetCCTarget(spellid, hive, data.attackers, minTargetsForCC, true);
			end
			if (nil ~= pendingCC and pendingCC:IsAlive() and fearcheck) then
				local agent = GetPlayerByGuid(guid);
				if (not agent or false == AI_IsAvailableToCast(agent:GetAI(), agent, pendingCC, spellid)) then
					if (not agent) then
						table.remove(data.ccAgents, i);
					end
				else
					local ai = agent:GetAI();
					local bRoleTarget = (isForcedCc) or (pendingCC:GetRole() ~= ROLE_TANK and pendingCC:GetRole() ~= ROLE_HEALER and pendingCC:CanAttack(agent));
					local bHealerCcCheck = ai:GetRole() ~= ROLE_HEALER or Data_GetAllowHealerCc(ai:GetData(), data);
					if (ai:GetRole() ~= ROLE_SCRIPT and nil == ai:GetCCTarget() and bRoleTarget and bHealerCcCheck) then
						local pendingGuid = pendingCC:GetGuid();
						ai:SetCCTarget(pendingGuid);
						hive:AddCC(guid, pendingGuid);
						num_cc_now = num_cc_now + 1;
					end
				end
			end
		end
	else
		data.aoe = true;
	end
	
	local attackCc = false;
	for i = #data.attackers, 1, -1 do
		local attacker = data.attackers[i];
		-- attacker:Kill(); -- kill all cheat
		-- attacker:SetHealthPct(100.0);
		-- io.write(attacker:GetName() .. i);
		-- for i,target in ipairs(attacker:GetThreatTbl()) do
			-- io.write(": " .. target:GetName() .. " = " .. attacker:GetThreat(target) .. "; ");
		-- end
		-- io.write("\n");
		
		-- never attack charmed allies
		if (attacker:IsPlayer() and attacker:HasAuraType(AURA_MOD_CHARM)) then
			num_cc_now = num_cc_now - 1;
			table.remove(data.attackers, i);
		else
			local totems = attacker:GetTotems();
			for i = 1, #totems do
				if (totems[i]:IsAlive()) then
					table.insert(data.hostileTotems, totems[i]);
				end
			end
			local guardians = attacker:GetGuardians();
			for i = 1, #guardians do
				if (guardians[i]:IsAlive() and guardians[i]:GetHealth() < 100.0) then
					table.insert(data.hostileTotems, guardians[i]);
				end
			end
		end
	end
	attackCc = num_cc_now == #data.attackers;
	
	local nTanks = 0;
	-- clear out invalid tanks
	for i = 1, #data.tanks do
		nTanks = nTanks + 1;
		local tank = data.tanks[i];
		local agent = tank:GetPlayer();
		if (AI_IsIncapacitated(agent)) then
			if (tank:CmdType() == CMD_TANK) then
				Command_ClearAll(tank, "Tank incapacitated");
			end
			nTanks = nTanks - 1;
		end
	end
	
	local tankTargets = Tank_GetTargetList(data.attackers, data.tanks);
	for j = 1, #tankTargets do
		if (Tank_AnyTankPulling(data.tanks)) then break; end
		local target = tankTargets[j][3];
		if (nil ~= target and ((false == hive:IsCC(target) and not Unit_IsCrowdControlled(target)) or attackCc)) then
			-- find closest tank that matches
			table.sort(data.tanks, function(a,b) return a:GetPlayer():GetDistance(target) < b:GetPlayer():GetDistance(target); end);
			for i = 1, #data.tanks do
				local ai = data.tanks[i];
				local bSwapOnly = ai:GetData().tankSwapOnly and nTanks > 1;
				local should, threatTarget = Tank_ShouldTankTarget(ai, target, tankTargets[j][1], tankTargets[j][2], 0);
				if (should and not bSwapOnly) then
					tankTargets[j][3] = nil; -- make sure no one else gets this
					if (false == target:IsInCombat() and true == Hive_CanPullTarget(hive, data, target)) then
						if (ai:CmdType() ~= CMD_PULL) then
							-- hive:CmdPull(ai, target:GetGuid());
							Command_IssuePull(ai, hive, target);
							break;
						end
					else
						-- if (false) then
							-- Print(ai:CmdType(), ai:GetPlayer():GetName(), target:GetName(), "been issued CMD_TANK.");
							-- hive:CmdTank(ai, target:GetGuid(), threatTarget);
							Command_IssueTank(ai, hive, target, threatTarget);
							break;
						-- end
					end
				end
			end
		end
	end
	
	if (Tank_AnyTankPulling(data.tanks)) then
		return;
	else
	end
	
	-- cc
	-- todo: test with multiple mages
	for i = 1, #data.cc do
		local ai = data.cc[i].agent;
		local agent = ai:GetPlayer();
		local target = data.cc[i].target;
		
		if (target:IsPlayer() and false == target:HasAuraType(AURA_MOD_CHARM)) then
			
			-- charmed ally no longer charmed
			if (false == target:CanAttack(agent)) then
				print("Remove no longer charmed ally from CC list", target:GetName(), agent and agent:GetName());
				hive:RemoveCC(target:GetGuid());
			end
			
		else
			
			if (false == attackCc and false == Unit_IsCrowdControlled(target) and ai:CmdType() ~= CMD_CC) then
				local targetsTarget = target:GetVictim();
				-- only cc if its an immediate danger
				if (AI_IsIncapacitated(agent) or not ccVsAoeCheck) then
					hive:RemoveCC(target:GetGuid());
				elseif (targetsTarget and target:IsInLOS(targetsTarget) and target:GetDistance(targetsTarget) < 45.0) then
					Command_IssueCc(ai, hive, target);
				end
			elseif (attackCc) then
				hive:RemoveCC(target:GetGuid());
				if (agent:CanAttack(target)) then
					table.insert(data.attackers, target);
				end
				break;
			end
		
		end
	end
	
	-- todo: Healer_ShouldHealTarget currently declines if CMD_DISPEL is active
	data.healTargets = Healer_GetTargetList(data.tracked, data.agents);
	local healTargets = data.healTargets;
	for j = 1, #healTargets do
		local target = healTargets[j];
		if (not Healer_AnyHealerOnTarget(data.healers, target)) then
			-- choose healers based on mana
			local healerScores = {};
			for i = 1, #data.healers do
				local healer = data.healers[i];
				if ((healer:CmdType() ~= CMD_DISPEL and healer:CmdType() ~= CMD_BUFF)
				or Healer_GetHealPriority(target, healer:GetPlayer():GetPowerPct(POWER_MANA), healer:GetData().hot, data.encounter and data.encounter.healmax) > 2) then
					table.insert(healerScores, {healer, Healer_ShouldHealTarget(healer, target, data.encounter and data.encounter.healmax)});
				end
				-- print(target:GetName(), target:GetHealthPct(), healer:GetPlayer():GetName(),
					-- Healer_ShouldHealTarget(healer, target, data.encounter and data.encounter.healmax),
					-- Healer_GetHealPriority(target, healer:GetPlayer():GetPowerPct(POWER_MANA), nil, data.encounter and data.encounter.healmax));
			end
			-- healer with most mana
			table.sort(healerScores, function(a,b) return a[2] > b[2]; end);
			if (healerScores[1] and healerScores[1][2] > 0) then
				if (healerScores[1][1]:CmdType() ~= CMD_HEAL or healerScores[1][1]:CmdArgs() ~= target:GetGuid()) then
					local healer = healerScores[1][1];
					local prio = Healer_GetHealPriority(
						target,
						healer:GetPlayer():GetPowerPct(POWER_MANA),
						healer:GetData().hot,
						data.encounter and data.encounter.healmax
					);
					Print("******* Issue Heal Cmd", target:GetName(), healerScores[1][2], "thp =", target:GetHealthPct(), "tpriority =", prio); 
					Command_IssueHeal(healerScores[1][1], hive, target:GetGuid(), 1);
					-- hive:CmdHeal(healerScores[1][1], target:GetGuid(), 1);
				end
			end
		end
	end
	
	if (not data.threatGrpMax) then data.threatGrpMax = Dps_GetMaxAllowedThreat(data.attackers); end
	
	IssueDispelCommands(hive, data, data.agents, true, false);
	IssueDispelCommands(hive, data, data.tracked, true, false);
	IssueBuffCommands(hive, data, data.agents, true);
	IssueBuffCommands(hive, data, data.tracked, true);
	
	local function cmd_engage(ai, hive)
		if (not AI_IsIncapacitated(ai:GetPlayer())) then
			if (ai:CmdType() == CMD_NONE or ai:CmdType() == CMD_FOLLOW) then
				Command_IssueEngage(ai, hive);
				-- hive:CmdEngage(ai, 0);
			end
		end
	end
	
	for i = 1, #data.healers do
		cmd_engage(data.healers[i], hive);
	end
	
	for i = 1, #data.rdps do
		cmd_engage(data.rdps[i], hive);
	end
	
	for i = 1, #data.mdps do
		cmd_engage(data.mdps[i], hive);
	end
	
	for i = 1, #data.tanks do
		cmd_engage(data.tanks[i], hive);
	end

end

function Hive_FormationRectGetAngle( drone, idx, forward, x, y, ori, tanks )
	
	-- settings
	
	local columns 	= 3; -- how many columns in formations
	local rows 		= math.ceil(drone:GetGroupMemberCount()/columns); -- for rowSize only;
	local width 	= 2*columns; -- distance from first column to last
	local length 	= 2*rows; -- distance from first row to last row
	local tol 		= 0.1; -- will not move if distance to new destination is less than this value
	
	local firstRowDist = length/rows; -- distance from leader to first row
	
	-- end of settings
	
	-- size of each row/column
	local rowSize = length/rows;
	local colSize = width/columns;
	
	-- calculate my row and column
	local myRow = math.ceil(idx/columns);
	local myCol = idx - (myRow - 1) * columns; -- disregard all columns from previous rows
	
	-- tanks go in front, if multiple spread over columns
	if (drone:GetRole() == ROLE_TANK) then
		if (#tanks == 1) then
			myRow = -2;
			myCol = 2;
		else
			for i = 1, #tanks do
				if (tanks[i]:GetPlayer():GetGuid() == drone:GetGuid()) then
					myRow = -2;
					myCol = i;
					break;
				end
			end
		end
	end
	
	-- get left vector
	local left = {x = -forward.y * colSize, y = forward.x * colSize};
	
	-- multiply forward vector by distance
	local forward_x = forward.x * ((myRow - 1) * rowSize + firstRowDist);
	local forward_y = forward.y * ((myRow - 1) * rowSize + firstRowDist);
	
	-- move back
	local destX = x - (forward_x);
	local destY = y - (forward_y);
	-- 5 cols; 2 1 0 1 2 --- 0 at 3;
	
	-- add an offset from middle when there is no middle spot (ie. an even number of columns)
	-- makes it tidy and symmetrical around leader
	local offset = colSize/2 * (1 - columns % 2);
	-- move left
	destX = destX + left.x * (myCol - math.ceil(columns/2)) + forward.y * offset; -- f: 1 when col = 1, f: 0 when col = 1 - (cols-1)/2; f: -1 when col = 3
	destY = destY + left.y * (myCol - math.ceil(columns/2)) - forward.x * offset; -- left vector is mutated so we dont use it for extra
	return math.sqrt((destX - x)*(destX - x)+(destY - y)*(destY - y)), math.atan(destY - y, destX - x) - ori;
	
end
