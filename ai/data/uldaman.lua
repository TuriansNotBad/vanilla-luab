-----------------------------------------------------------------------------------------------
-- Something buggy about when you first enter the cave and the first bat and lizard
-- can't be attacked and lock bots in place.
-- Additionally, pulling 2 sharpshooters requires very specific positioning to pick correct
-- line. Room with a lot of Stonevault Brawlers also requires much care.

t_dungeons[70] = {
	-- Line 1: RHS dead end
	{
		{-228.268, 58.3979, -46.0371, -1000, 2}, -- 1
		{-177.398, 61.8054, -48.8084, -1000, 2}, -- 2
		{-175.293, 89.7406, -48.811, -1000, 2}, -- 3
	},
	-- Line 2: LHS paths to lhs/rhs merge
	{
		{-232.525, 58.1615, -46.0384, -1000, 2}, -- 1
		{-282.328, 60.7035, -48.8007, -1000, 2}, -- 2
		{-281.371, 90.3647, -48.8021, -1000, 2}, -- 3
		{-246.633, 91.9276, -48.1124, -1000, 2}, -- 4
		{-246.377, 137.281, -46.714, -1000, 2}, -- 5
		{-281.103, 139.215, -47.4095, -1000, 2}, -- 6
		{-280.249, 168.6, -47.4095, -1000, 2}, -- 7
		{-230.413, 169.399, -44.6296, -1000, 2}, -- 8
	},
	-- Line 3: RHS paths to lhs/rhs merge
	{
		{-208.921, 90.8872, -48.1058, -1000, 2}, -- 1
		{-210.094, 137.464, -46.7146, -1000, 2}, -- 2
		{-174.765, 138.606, -47.4101, -1000, 2}, -- 3
		{-175.117, 167.903, -47.4101, -1000, 2}, -- 4
		{-219.449, 169.286, -44.6296, -1000, 2}, -- 5
	},
	-- Line 4: To Ironaya
	{
		{-228.499, 177.467, -44.6296, -1000, 2}, -- 6
		{-237.105, 228.329, -49.2516, -1000, 2}, -- 7
		{-245.571, 243.821, -47.1609, -1000, 2}, -- 8
		{-235.498, 281.12, -48.6218, -1000, 2}, -- 9
		{-234.345, 324.186, -47.5965, -1000, 2}, -- 10
	},
	-- Line 5: To first fork in caves
	{
		{-226.555, 177.55, -44.6296, -1000, 2}, -- 1
		{-225.51, 218.862, -49.6527, -1000, 2}, -- 2
		{-201.998, 257.552, -49.4479, -1000, 2}, -- 3
		{-186.443, 285.827, -47.8843, -1000, 2}, -- 4
		{-177.065, 322.787, -52.2778, -1000, 2}, -- 5
		{-151.772, 318.715, -48.8498, -1000, 2}, -- 6
		{-141.641, 332.02, -44.6071, -1000, 2}, -- 7
	},
	-- Line 6: To Ancient Stone Keeper room (rhs path)
	{
		{-140.946, 311.676, -44.4093, -1000, 2}, -- 1
		{-137.714, 291.273, -45.9457, -1000, 2}, -- 2
		{-122.849, 263.041, -47.4262, -1000, 2}, -- 3
		{-124.087, 237.113, -48.3499, -1000, 2}, -- 4
		{-131.554, 230.289, -47.941, -1000, 2}, -- 5
		{-121.473, 217.277, -46.148, -1000, 2}, -- 6
		{-103.768, 199.559, -39.8108, -1000, 2}, -- 7
		{-94.5691, 224.675, -45.0117, -1000, 2}, -- 8
		{-89.811, 221.566, -46.4838, -1000, 2}, -- 9
		{-85.9365, 216.831, -46.8069, -1000, 2}, -- 10
	},
	-- Line 7: To Annora
	{
		{-140.666, 226.518, -46.5237, -1000, 2}, -- 1
		{-157.128, 220.113, -46.8332, -1000, 2}, -- 2
		{-162.269, 213.402, -49.17, -1000, 2}, -- 3
		{-161.575, 202.001, -49.9289, -1000, 2}, -- 4
	},
	-- Line 8: To Ancient Stone Keeper room (middle path)
	{
		{-131.539, 319.502, -44.2985, -1000, 2}, -- 1
		{-93.4024, 317.009, -50.6775, -1000, 2}, -- 2
		{-89.0366, 291.815, -47.6302, -1000, 2}, -- 3
		{-88.8179, 260.132, -47.6302, -1000, 2}, -- 4
	},
	-- Line 9: Ancient Stone Keeper room (rhs side)
	{
		{-78.7873, 218.535, -49.6099, -1000, 2}, -- 1
		{-69.8873, 206.347, -49.7481, -1000, 2}, -- 2
		{-45.0315, 205.322, -48.3294, -1000, 2}, -- 3
	},
	-- Line 10: Ancient Stone Keeper room lhs side and path to next fork
	{
		{-90.3054, 237.824, -49.7201, -1000, 2}, -- 1
		{-42.6028, 239.034, -48.3255, -1000, 2}, -- 2
		{-41.1208, 272.699, -49.0188, -1000, 2}, -- 3
		{-14.0981, 278.052, -48.2033, -1000, 2}, -- 4
		{-13.0557, 295.415, -46.55, -1000, 2}, -- 5
		{-29.1686, 300.317, -45.6722, -1000, 2}, -- 6
		{-33.1714, 319.965, -41.4516, -1000, 2}, -- 7
		{-11.7704, 320.393, -39.6991, -1000, 2}, -- 8
	},
	-- Line 11: To Obsidian Sentinel
	{
		{-123.463, 359.943, -44.3936, -1000, 2}, -- 1
		{-134.998, 368.407, -42.3321, -1000, 2}, -- 2
		{-140.41, 384.131, -40.1303, -1000, 2}, -- 3
		{-159.693, 387.205, -36.439, -1000, 2}, -- 4
		{-184.687, 389.635, -36.3827, -1000, 2}, -- 5
		{-211.16, 389.411, -39.2023, -1000, 2}, -- 6
	},
	-- Line 12: From Obsidian Sentinel fork to next fork
	{
		{-106.373, 352.362, -47.5773, -1000, 2}, -- 1
		{-86.7564, 350.797, -49.8031, -1000, 2}, -- 2
		{-62.8804, 367.934, -50.5463, -1000, 2}, -- 3
		{-49.3907, 368.938, -50.0092, -1000, 2}, -- 4
		{-40.8727, 352.412, -46.8044, -1000, 2}, -- 5
	},
	-- Line 13: Scorpion pit at the fork wrap around
	{
		{-18.375, 328.402, -46.8573, -1000, 2}, -- 1
		{-28.8662, 347.299, -44.0032, -1000, 2}, -- 2
		{-13.1832, 346.127, -40.9499, -1000, 2}, -- 3
		{-12.0508, 338.993, -40.7214, -1000, 2}, -- 4
		{-7.77583, 326.494, -39.8644, -1000, 2}, -- 5
	},
	-- Line 14: Fork - room, rhs
	{
		{-1.9609, 327.284, -39.3223, -1000, 2}, -- 1
		{15.7334, 328.195, -39.5991, -1000, 2}, -- 2
	},
	-- Line 15: Room rhs pull direction
	{
		{18.0649, 328.354, -39.9383, -1000, 2}, -- 1
		{39.1247, 327.218, -42.9394, -1000, 2}, -- 2
	},
	-- Line 16: To Grimlock
	{
		{-10.8477, 347.469, -41.0544, -1000, 2}, -- 1
		{2.90329, 362.733, -42.8433, -1000, 2}, -- 2
		{35.906, 354.816, -42.9739, -1000, 2}, -- 3
		{59.0945, 377.066, -38.2558, -1000, 2}, -- 4
		{77.4288, 395.24, -38.2752, -1000, 2}, -- 5
		{39.1354, 432.715, -41.0427, -1000, 2}, -- 6
		{55.5944, 451.129, -41.0462, -1000, 2}, -- 7
	},
	-- Line 17: Room lhs pull direction
	{
		{-5.90659, 347.562, -40.9262, -1000, 2}, -- 1
		{3.93882, 367.074, -43.1303, -1000, 2}, -- 2
		{35.2434, 350.607, -42.667, -1000, 2}, -- 3
		{40.2718, 331.923, -43.1852, -1000, 2}, -- 4
	},
	-- Line 18: From room last boss
	{
		{20.6857, 323.767, -40.0404, -1000, 2}, -- 1
		{42.2553, 306.749, -39.4273, -1000, 2}, -- 2
		{26.4429, 312.065, -39.3709, -1000, 2}, -- 3
		{24.3938, 293.937, -40.0869, -1000, 2}, -- 4
		{9.1966, 286.703, -38.6554, -1000, 2}, -- 5
		{2.20177, 275.887, -36.5625, -1000, 2}, -- 6
		{14.0389, 227.685, -31.8576, -1000, 2}, -- 7
		{37.1854, 240.497, -26.5818, -1000, 2}, -- 8
		{104.141, 274.693, -26.5322, -1000, 2}, -- 9
		{148.244, 292.171, -26.5816, -1000, 2}, -- 10
		{173.366, 248.104, -29.3619, -1000, 2}, -- 11
		{163.476, 242.521, -29.3619, -1000, 2}, -- 12
		{141.533, 231.376, -42.4898, -1000, 2}, -- 13
		{112.09, 217.403, -42.4913, -1000, 2}, -- 14
		{89.9792, 206.85, -54.9768, -1000, 2}, -- 15
		{81.5441, 204.002, -54.9783, -1000, 2}, -- 16
		{58.6996, 251.548, -52.1981, -1000, 2}, -- 17
		{155.06, 296.744, -52.2261, -1000, 2}, -- 18
	},
	-- Line 19: To room Galgann Firehammer
	{
		{-45.2315, 356.946, -47.8897, -1000, 2},
		{-11.4663, 350.62, -40.9758, -1000, 2}, -- 1
		{-2.93843, 365.008, -43.0033, -1000, 2}, -- 2
		{-1.18782, 385.466, -43.696, -1000, 2}, -- 3
		{5.11579, 394.351, -45.202, -1000, 2}, -- 4
		{1.14074, 416.246, -47.8372, -1000, 2}, -- 5
	},
};

local Uldaman = t_dungeons[70];
Uldaman.Altar = {
	Spellid = 11206,
};

-- remember everyone's roles
function Uldaman.Altar:PreprocessAgents(data)
	for i,ai in ipairs(data.agents) do
		local data = ai:GetData();
		if (nil == data["Uldaman.Altar.OldRole"]) then
			data["Uldaman.Altar.OldRole"] = ai:GetRole();
		end
	end
end

-- reset everyone's roles
function Uldaman.Altar:RestoreAgents(data)
	for i,ai in ipairs(data.agents) do
		local agent = ai:GetPlayer();
		agent:InterruptSpell(CURRENT_CHANNELED_SPELL);
		agent:ClearMotion();
		local data = ai:GetData();
		if (data["Uldaman.Altar.OldRole"]) then
			Command_ClearAll(ai, "Uldaman.Altar.RestoreAgents");
			ai:SetRole(data["Uldaman.Altar.OldRole"]);
			data["Uldaman.Altar.OldRole"] = nil;
		end
	end
end

function Uldaman.Altar:ChangeRole(ai, newRole)
	if (nil == ai:GetData()["Uldaman.Altar.OldRole"]) then
		error("Uldaman.Altar.ChangeRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	ai:SetRole(newRole);
end


function Uldaman.Altar.Test(hive, data)
	
	local owner = data.owner;
	-- at least 3 players required
	if (owner and #data.agents > 1 and #data.attackers == 0) then
		if (owner:GetCurrentSpellId(CURRENT_CHANNELED_SPELL) == Uldaman.Altar.Spellid) then
			return true;
		end
	end
	
	return false;
	
end

function Uldaman.Altar:OnBegin(hive, data)
	self:PreprocessAgents(data);
end

function Uldaman.Altar:Update(hive, data)

local GO_ALTAR_KEEPERS   = 130511;
local GO_ALTAR_ARCHAEDAS = 133234;

	local pos_preboss = {
		{x = 106.643, y = 268.510, z =-26.532},
		{x = 102.756, y = 276.595, z =-26.532},
		{x = 102.756, y = 276.595, z =-26.532},
		{x = 102.756, y = 276.595, z =-26.532},
		altar = GO_ALTAR_KEEPERS,
	};
	local pos_boss = {
		{x = 94.298, y = 271.854, z = -52.149},
		{x = 97.845, y = 265.890, z = -52.148},
		{x = 97.845, y = 265.890, z = -52.148},
		{x = 97.845, y = 265.890, z = -52.148},
		altar = GO_ALTAR_ARCHAEDAS,
	};
	
	for i = 1, 2 do
		
		local ai = data.agents[i];
		local agent = ai:GetPlayer();
		
		if (ai:GetRole() ~= ROLE_SCRIPT) then
			Command_ClearAll(ai, "Uldaman.Altar taking control");
			self:ChangeRole(ai, ROLE_SCRIPT);
		end
		
		local pos = pos_preboss;
		if (agent:GetDistance(pos[i].x, pos[i].y, pos[i].z) > agent:GetDistance(pos_boss[i].x, pos_boss[i].y, pos_boss[i].z)) then
			pos = pos_boss;
		end
		
		local x,y,z = pos[i].x, pos[i].y, pos[i].z;
		if (agent:GetDistance(x,y,z) > 2) then
		
			-- move to the altar
			if (false == ai:IsMovingTo(x,y,z)) then
				agent:ClearMotion();
				agent:MovePoint(x,y,z,false);
			end
		
		else
		
			if (agent:GetMotionType() ~= MOTION_IDLE) then
				agent:ClearMotion();
			end
			
			if (agent:GetCurrentSpellId(CURRENT_CHANNELED_SPELL) ~= self.Spellid) then
				
				local guid = GetObjectsWithEntryAround(agent, pos.altar, 30, false)[1];
				if (not guid) then return; end
				agent:UseObj(guid);
				
			end
		
		end
		
	end
end

function Uldaman.Altar:OnEnd(hive, data)
	self:RestoreAgents(data);
end

t_dungeons[70].encounters = {
	{name = "Stone Steward", nodebuffs = true, pull = true},
	{name = "Olaf"},
	{name = "Revelosh"},
	{name = "Ironaya", nodebuffs = true},
	{name = "Obsidian Sentinel", nodebuffs = true},
	{name = "Ancient Stone Keeper", nodebuffs = true, tpos = {-49.887, 220.959, -48.326}},
	{name = "Galgann Firehammer"},
	{name = "Grimlok"},
	{name = "Archaedas", distancingR = 15.0, tpos = {86.920, 278.596, -51.783}},
	{name = "Altar", script = Uldaman.Altar, test = Uldaman.Altar.Test},
	{
		name = "Stone Keeper",
		nodebuffs = true,
		tpos = {99.110, 269.588, -26.532},
		rchrpos = {x=78.803, y=260.742, z=-26.588, melee = "dance"}
	},
};
