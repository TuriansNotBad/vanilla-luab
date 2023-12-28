local t_agentInfo = {
	{"Cha",LOGIC_ID_Party,"LvlTank"}, -- warrior tank (human/orc, others untested, will likely have no melee weapon)
	{"Pri",LOGIC_ID_Party,"LvlHeal"}, -- priest healer
	{"Gert",LOGIC_ID_Party,"LvlDps"}, -- mage
	{"Mokaz",LOGIC_ID_Party,"LvlDps"}, -- rogue
	-- {"Fawarrie",LOGIC_ID_Party,"FeralLvlDps"}, -- cat
	-- {"Thia",LOGIC_ID_Party,"FeralLvlDps"}, -- cat
};

local Hive_FormationRectGetAngle;

local function GetBuffAgentsTbl(data, target, key)
	local data = data.buffs[key];
	local t = {};
	if (not data) then
		return t;
	end
	for i = #data, 1, -1 do
		local agent = GetPlayerByGuid(data[i]);
		if (nil == agent) then
			table.remove(data, i);
		else
			table.insert(t, agent);
		end
	end
	if (#data == 0) then
		data.buffs[key] = nil;
		return t;
	end
	-- it would be ideal to have a mixed sort between mana and distance
	-- but at the very least pick an agent that has enough mana to cast
	-- and isn't on cooldown if that's a consideration, ever?
	local function sort(a, b)
		if (a:HasEnoughPowerFor(data.spellid, false) and false == b:HasEnoughPowerFor(data.spellid, false)) then
			return true;
		end
		if (b:HasEnoughPowerFor(data.spellid, false) and false == a:HasEnoughPowerFor(data.spellid, false)) then
			return false;
		end
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

local function GetClosestBuffAgent(data, target, key)
	local t = GetBuffAgentsTbl(data, target, key);
	for i = 1, #t do
		local agent = t[i];
		local ai = agent:GetAI();
		local cmd = ai:CmdType();
		if (cmd == CMD_FOLLOW or cmd == CMD_NONE) then
			return agent;
		end
	end
end

local function RegisterBuff(data, agent, key, str, spellid, type, time, filter)
	local data = data.buffs;
	data[key] = data[key] or {str = -1, spellid = 0, type = BUFF_SINGLE, time = 0};
	if (table.ifind(data[key], agent:GetGuid()) ~= 0 or str < data[key].str) then
		return;
	end
	if (str > data[key].str) then
		data[key] = {str = str, spellid = spellid, type = type, time = time, filter = filter};
	end
	table.insert(data[key], agent:GetGuid());
end

local function HasTank(data)
	return #data.tanks > 0;
end

local function RegisterCC(data, agent, spellid)
	table.insert(data.ccAgents, {agent:GetGuid(), spellid});
end

function Hive_Init(hive)
	local t_12 = {
		{"Adowwar",LOGIC_ID_Party,"LvlTank"}, -- warrior tank
		{"Adowpriest",LOGIC_ID_Party,"LvlHeal"}, -- priest healer
		{"Adowmage",LOGIC_ID_Party,"LvlDps"}, -- mage
		{"Adowrogue",LOGIC_ID_Party,"LvlDps"}, -- rogue
	};
	hive:LoadInfoFromLuaTbl(t_agentInfo);
	local data = hive:GetData();
	data.ccAgents = {};
	data.buffs = {};
	data.RegisterBuff = RegisterBuff;
	data.RegisterCC = RegisterCC;
	data.HasTank = HasTank;
	-- local item = Item_GetItemFromId(12048);
	-- item:PrintRandomEnchants();
	-- Items_PrintItemsOfType(ItemClass.Weapon, ItemSubclass.WeaponAxe2, -1);
end

function Hive_Update(hive)
	
	local data = hive:GetData();
	data.attackers = hive:GetAttackers();
	data.agents = hive:GetAgents();
	data.owner = nil;
	table.sort(data.attackers, function(a, b) return a:GetHealth() < b:GetHealth(); end);
	data.healers = {};
	data.tanks = {};
	data.rdps = {};
	data.mdps = {};
	data.tracked = {};
	data.healTargets = {};
	data.cc = hive:GetCC();
	
	local ownerGuid = hive:GetOwnerGuid()
	local ownerVictim;
	if (ownerGuid) then
		data.owner = GetPlayerByGuid(ownerGuid);
		if (data.owner) then
			table.insert(data.tracked, data.owner);
			ownerVictim = data.owner:GetVictim();
			if (ownerVictim) then
				-- local x,y,z = hive:GetCLinePInLosAtD(data.owner, ownerVictim, 10, 15, 1, false);
				-- local px,py,pz = data.owner:GetPosition();
				-- Print(x,y,z, "you (", px,py,pz, ") D =", ownerVictim:GetDistance(data.owner));
			end
			-- print(data.owner:GetPosition());
			if (not data.attackers[1]) then
				data.attackers[1] = ownerVictim;
			end
		end
	end
	
	for i = 1, #data.agents do
		local ai = data.agents[i];
		-- ai:GetPlayer():SetHealthPct(100.0);
		-- ai:GetPlayer():SetPowerPct(POWER_RAGE, 100.0);
		-- ai:GetPlayer():SetPowerPct(POWER_MANA, 100.0);
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
	end
	
	if (#data.attackers == 0) then
		Hive_OOCUpdate(hive, data);
	else
		Hive_CombatUpdate(hive, data);
	end
	
end

local function filter_check(filter, ai, agent)
	if (nil == filter) then
		return true;
	end
	if (filter.role and ai:GetRole() ~= filter.role) then
		return false;
	end
	return true;
end

local function IssueBuffCommands(hive, data, agents)
	for i = 1, #agents do
		
		local ai = agents[i];
		local agent = ai.GetPlayer and ai:GetPlayer() or ai;
		
		for key,buff in next, data.buffs do
			if (agent:IsAlive()
			and agent:GetAuraTimeLeft(buff.spellid) < buff.time
			and false == AI_HasBuffAssigned(agent:GetGuid(), key, buff.type)
			and filter_check(buff.filter, ai, agent))
			then
				local ally = GetClosestBuffAgent(data, agent, key);
				if (ally) then
					local allyAi = ally:GetAI();
					-- if (allyAi:CmdType() == CMD_FOLLOW) then
						AI_PostBuff(ally:GetGuid(), agent:GetGuid(), key, true);
						hive:CmdBuff(allyAi, agent:GetGuid(), buff.spellid, key);
						Print("CmdBuff issued to", ally:GetName(), key, agent:GetName());
					-- end
				end
			end
		end
		
	end
end

function Hive_OOCUpdate(hive, data)
	
	data.reverse = nil;
	local agents = data.agents;
	
	if (#data.healers > 0) then
		local healTargets = Healer_GetTargetList(data.tracked);
		for j = 1, #healTargets do
			local target = healTargets[j];
			-- choose healers based on mana
			local healerScores = {};
			for i = 1, #data.healers do
				local healer = data.healers[i];
				table.insert(healerScores, {healer, Healer_ShouldHealTarget(healer, target)});
			end
			-- healer with most mana
			table.sort(healerScores, function(a,b) return a[2] > b[2]; end);
			if (healerScores[1] and healerScores[1][2] > 0.0) then
				if (healerScores[1][1]:GetHealTarget() ~= target) then
					hive:CmdHeal(healerScores[1][1], target:GetGuid(), 1);
				end
			end
		end
	end
	
	IssueBuffCommands(hive, data, agents);
	IssueBuffCommands(hive, data, data.tracked);
	
	if (not data.owner) then
		return;
	end
	
	local leaderX,leaderY,leaderZ = data.owner:GetPosition();
	local ori = data.owner:GetOrientation();
	local fwd = data.owner:GetForwardVector();
	
	for i = 1, #agents do
		local ai = agents[i];
		local agent = ai:GetPlayer();
		
		if (agent:GetLevel() ~= data.owner:GetLevel()) then
			ai:SetDesiredLevel(data.owner:GetLevel());
		end
		
		if (agent:GetDistance(data.owner) > 50) then
			ai:GoName(data.owner:GetName());
		else
		
			if (ai:CmdType() ~= CMD_FOLLOW and ai:CmdType() ~= CMD_HEAL and ai:CmdType() ~= CMD_BUFF) then
				Print("CmdFollow issued to", agent:GetName());
				local D, A = Hive_FormationRectGetAngle(agent, i, fwd, leaderX, leaderY, ori);
				hive:CmdFollow(ai, ai:GetMasterGuid(), D, A);
			end
		
		end
		
	end
	
end

function Hive_CombatUpdate(hive, data)
	
	-- should always attack lowest health target by default
	-- but if we are close to pulling aggro we should attack anything safe
	-- or halt, agents handle that in library funcs on their own
	
	if (data.reverse == nil and data.owner ~= nil and hive:HasCLineFor(data.owner)) then
		data.reverse = hive:ShouldReverseCLine(data.owner, data.attackers[1]);
		Print("Hive reverse", data.reverse);
	end
	local attackCc = false;
	local nCC = 0;
	for i,attacker in ipairs(data.attackers) do
		-- attacker:SetHealthPct(100.0);
		-- io.write(attacker:GetName() .. i);
		-- for i,target in ipairs(attacker:GetThreatTbl()) do
			-- io.write(": " .. target:GetName() .. " = " .. attacker:GetThreat(target) .. "; ");
		-- end
		-- io.write("\n");
		if (hive:IsCC(attacker)) then
			nCC = nCC + 1;
		end
	end
	attackCc = nCC == #data.attackers;
	
	local minTargetsForCC = 2;
	for i = #data.ccAgents, 1, -1 do
		local guid, spellid = data.ccAgents[i][1], data.ccAgents[i][2];
		-- target assigned
		local pendingCC = Party_GetCCTarget(spellid, hive, data.attackers, minTargetsForCC, true);
		if (nil ~= pendingCC and pendingCC:IsAlive()) then
			local agent = GetPlayerByGuid(guid);
			if (not agent or not agent:IsAlive()) then
				table.remove(data.ccAgents, i);
			else
				local ai = agent:GetAI();
				if (nil == ai:GetCCTarget() and agent:HasEnoughPowerFor(spellid, false)) then
					local pendingGuid = pendingCC:GetGuid();
					ai:SetCCTarget(pendingGuid);
					hive:AddCC(guid, pendingGuid);
				end
			end
		end
	end
	
	local tankTargets = Tank_GetTargetList(data.attackers, data.tanks);
	for j = 1, #tankTargets do
		local target = tankTargets[j][3];
		if (nil ~= target and (false == hive:IsCC(target) or attackCc)) then
			-- find closest tank that matches
			table.sort(data.tanks, function(a,b) return a:GetPlayer():GetDistance(target) < b:GetPlayer():GetDistance(target); end);
			for i = 1, #data.tanks do
				local ai = data.tanks[i];
				local should, threatTarget = Tank_ShouldTankTarget(ai, target, tankTargets[j][1], tankTargets[j][2], 0);
				if (should) then
					tankTargets[j][3] = nil; -- make sure no one else gets this
					if (false == target:IsInCombat() and true == hive:CanPullTarget(target) and ai:GetPlayer():IsInDungeon()) then
						if (ai:CmdType() ~= CMD_PULL) then
							hive:CmdPull(ai, target:GetGuid());
						end
					else
						hive:CmdTank(ai, target:GetGuid(), threatTarget);
						break;
					end
				end
			end
		end
	end
	
	if (Tank_AnyTankPulling(data.tanks)) then
		return;
	end
	
	-- cc
	for i = 1, #data.cc do
		local ai = data.cc[i].agent;
		local target = data.cc[i].target;
		if (false == attackCc and false == Unit_IsCrowdControlled(target) and ai:CmdType() ~= CMD_CC) then
			hive:CmdCC(ai, target:GetGuid());
		elseif (attackCc) then
			hive:RemoveCC(target:GetGuid());
			table.insert(data.attackers, target);
			break;
		end
	end
	
	local healTargets = Healer_GetTargetList(data.tracked, data.agents);
	for j = 1, #healTargets do
		local target = healTargets[j];
		-- choose healers based on mana
		local healerScores = {};
		for i = 1, #data.healers do
			local healer = data.healers[i];
			table.insert(healerScores, {healer, Healer_ShouldHealTarget(healer, target)});
		end
		-- healer with most mana
		table.sort(healerScores, function(a,b) return a[2] > b[2]; end);
		if (healerScores[1] and healerScores[1][2] > 0.0) then
			if (healerScores[1][1]:GetHealTarget() ~= target) then
				hive:CmdHeal(healerScores[1][1], target:GetGuid(), 1);
			end
		end
	end
	
	for i = 1, #data.healers do
	
		local ai = data.healers[i];
		if (ai:CmdType() == CMD_NONE or ai:CmdType() == CMD_FOLLOW) then
			hive:CmdEngage(ai, 0);
		end
		
	end
	
	for i = 1, #data.rdps do
	
		local ai = data.rdps[i];
		if (ai:CmdType() ~= CMD_CC and ai:CmdType() ~= CMD_ENGAGE) then
			hive:CmdEngage(ai, 0);
		end
		
	end
	
	for i = 1, #data.mdps do
	
		local ai = data.mdps[i];
		if (ai:CmdType() ~= CMD_CC and ai:CmdType() ~= CMD_ENGAGE) then
			print("Cmd engage");
			hive:CmdEngage(ai, 0);
		end
		
	end

end

function Hive_FormationRectGetAngle( drone, idx, forward, x, y, ori )
	
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
