
local respawnTimeInit = 5;
local respawnTimeZone = 15;

local MIDKalimdor = 1;
local MIDLordaeron = 0;

local ZIDBarrens = 17;
local ZIDDurotar = 14;
local ZIDDarkshore = 148;
local ZIDDarnassus = 1657;
local ZIDMulgore = 215;
local ZIDTeldrassil = 141;

local ZIDDunMorogh = 1;
local ZIDElwynnForest = 12;
local ZIDWestfall = 40;
local ZIDTirisfalGlades = 85;

function OpenWorldPVP_Init(party)
	local data = party:GetData();
	data._respawnTime = os.time() + respawnTimeInit;
end

function OpenWorldPVP_Respawn(party, data)

data._respawnTime = nil;

local a = {
	one = "Derek",
	two = "Steve",
	three = "Peter",
	four = "John",
	five = "Wally",
	six = "Andrew",
	seven = "James",
};
local h = {
	one = "Kered",
	two = "Evets",
	three = "Retep",
	four = "Nhoj",
	five = "Yllaw",
	six = "Werdna",
	seven = "Semaj",
};

local ownerGuid = party:GetOwnerGuid();
if (not ownerGuid) then
	return;
end
local owner = GetPlayerByGuid(ownerGuid);
if (not owner) then
	return;
end

local set = (owner:GetTeam() == TEAM_ALLIANCE) and h or a;

local spawns = {
	--  
	[MIDKalimdor] = {
		[ZIDDurotar] = {
			WarriorVoT     = {lvl=1, r=35, name = set.one, l=LOGIC_ID_InvaderPvp, x=-200.311, y=-4364.804, z=66.808, zone = ZIDDurotar, map = MIDKalimdor},
			WAR_DU_Road1   = {lvl=1, r=35, name = set.two, l=LOGIC_ID_InvaderPvp, x=-462.05,y=-4732.43,z=36.71, zone = ZIDDurotar, map = MIDKalimdor},
			-- WAR_DU_Road2 = {lvl=1, r=35, name = set.three, l=LOGIC_ID_InvaderPvp, x=63.74,y=-4692.87,z=34.01, zone = ZIDDurotar, map = MIDKalimdor},
			WAR_DU_Fort1   = {lvl=1, r=35, name = set.four, l=LOGIC_ID_InvaderPvp, x=-64.12,y=-4883.50,z=17.97, zone = ZIDDurotar, map = MIDKalimdor},
			-- WAR_DU_Fort2 = {lvl=1, r=35, name = set.five, l=LOGIC_ID_InvaderPvp, x=-62.29,y=-4885.06,z=18.03, zone = ZIDDurotar, map = MIDKalimdor},
			WAR_DU_ToBarr1 = {lvl=1, r=35, name = set.six, l=LOGIC_ID_InvaderPvp, x=341.12,y=-3920.76,z=32.28, zone = ZIDDurotar, map = MIDKalimdor},
			-- WAR_DU_ToBarr2 = {lvl=1, r=35, name = set.seven, l=LOGIC_ID_InvaderPvp, x=332.10,y=-3914.81,z=32.53, zone = ZIDDurotar, map = MIDKalimdor},
		},
		[ZIDMulgore] = {
			WAR_MLG_ToBarrens1	 = {lvl = 1, r=30, name = set.one,   l=LOGIC_ID_WarriorPvp, x=-2306.68,y=-1502.17,z=47.13, zone = ZIDMulgore, map = MIDKalimdor},
			WAR_MLG_ToBarrens2	 = {lvl = 1, r=30, name = set.two,   l=LOGIC_ID_WarriorPvp, x=-2390.25,y=-1437.63,z=25.71, zone = ZIDMulgore, map = MIDKalimdor},
			WAR_MLG_NearLake	 = {lvl = 1, r=30, name = set.three, l=LOGIC_ID_WarriorPvp, x=-2043.68,y=-221.40,z=-9.89, zone = ZIDMulgore, map = MIDKalimdor},
			WAR_MLG_NearThunder	 = {lvl = 1, r=30, name = set.four,  l=LOGIC_ID_WarriorPvp, x=-1591.32,y=168.79,z=-6.86, zone = ZIDMulgore, map = MIDKalimdor},
			WAR_MLG_RedRocks	 = {lvl = 1, r=30, name = set.five,  l=LOGIC_ID_WarriorPvp, x=-1168.95,y=-1134.47,z=29.79, zone = ZIDMulgore, map = MIDKalimdor},
		},
	},
	
	[MIDLordaeron] = {
	},
};

data.spawns = spawns;
data._lastZoneID = owner:GetZoneId();

local agentInfo = {};
local activeMapID = owner:GetMapId();
local activeZoneID = owner:GetZoneId();

if (not spawns[activeMapID] or not spawns[activeMapID][activeZoneID]) then
	return;
end

spawns = spawns[activeMapID][activeZoneID];
for label,info in next,spawns do
	print(info.name, info.l, label);
	table.insert(agentInfo, {info.name, info.l, label});
end

party:LoadInfoFromLuaTbl(agentInfo);

end

function OpenWorldPVP_FindDroneInfo(spawns, name)
	for mapID,map in next,spawns do
		for zoneID,zone in next,map do
			for entryName,entry in next,zone do
				if (entryName == name) then
					return entry;
				end
			end
		end
	end
end

function OpenWorldPVP_CleanUpEx(party, data)
	
	data._respawnTime = os.time() + respawnTimeZone;
	party:RemoveAll();
	
end

-- remove all bots
function OpenWorldPVP_CleanUp(ai)
	self:CleanUpEx(ai, nil);
end


function OpenWorldPVP_Update(party)
	
	local ownerGuid = party:GetOwnerGuid();
	local target = GetPlayerByGuid(ownerGuid);
	if (not target) then
		party:RemoveAll();
		return;
	end
	
	local data = party:GetData();
	
	if (data._respawnTime ~= nil and os.time() >= data._respawnTime) then
		Print("Respawning OWPVP");
		OpenWorldPVP_Respawn(party, data);
		return;
	end

	local activeMapID = target:GetMapId();
	local activeZoneID = target:GetZoneId();
	
	if (data._lastZoneID ~= target:GetZoneId()) then
		-- remove all old bots and respawn
		Print("OWPVP Zone Change");
		OpenWorldPVP_CleanUpEx(party, data);
		data._lastZoneID = activeZoneID;
		return;
	end

	-- wait for first spawn
	if (data.spawns == nil) then
		return;
	end
	
	local spawns = data.spawns;
	if (not spawns[activeMapID] or not spawns[activeMapID][activeZoneID]) then
		party:RemoveAll();
		return;
	end
	
	for i,ai in ipairs(party:GetAgents()) do
		
		local agent = ai:GetPlayer();
		local aidata = ai:GetData();
		if (nil == aidata.droneInfo) then
			-- can be dead on login
			if (not agent:IsAlive()) then
				print"Dead on login"
				agent:ResurrectPlayer(1, false);
			end
			aidata.droneInfo = OpenWorldPVP_FindDroneInfo(spawns, ai:GetSpec());
			if (aidata.droneInfo == nil) then
				print(agent:GetName(), ai:GetSpec(), "has no drone info for pvp");
				error("Drone Info not found");
			end
			aidata._pvpTargetGuid = target:GetGuid();
		end
		
		-- bots are logged out on death
		if (not agent:IsAlive()) then
			-- init timer
			if (aidata._pvpCoreDespawnTimer == nil) then
				aidata._pvpCoreDespawnTimer = os.time() + 10;
			end
			-- check timer
			if (os.time() >= aidata._pvpCoreDespawnTimer) then
				agent:ResurrectPlayer(1, false);
				party:RemoveAgent(agent:GetGuid());
				return;
			end
		end
		
	end
	
end
