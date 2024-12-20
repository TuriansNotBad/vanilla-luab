t_dungeons[34] = {
	-- Line 1
	{
		{48.9849, 0.483882, -16.4032, -1000, 2}, -- 1
		{100.285, 1.00949, -25.6062, -1000, 2}, -- 2
		{127.558, 1.15288, -25.6062, -1000, 2}, -- 3
		{129.968, 44.0152, -33.9396, -1000, 2}, -- 4
		{136.465, 71.361, -33.9396, -1000, 2}, -- 5
		{151.141, 108.314, -35.1896, -1000, 2}, -- 6
		{172.317, 143.721, -33.9396, -1000, 2}, -- 7
	},
	-- Line 2
	{
		{130.586, 119.852, -33.9396, -1000, 2}, -- 1
		{116.394, 127.485, -33.9396, -1000, 2}, -- 2
	},
	-- Line 3
	{
		{175.868, 95.6381, -33.9396, -1000, 2}, -- 1
		{190.851, 87.5028, -33.9396, -1000, 2}, -- 2
	},
	-- Line 4
	{
		{145.75, 62.7967, -34.8562, -1000, 2}, -- 1
		{164.703, 58.1428, -34.8562, -1000, 2}, -- 2
	},
	-- Line 5
	{
		{123.929, 70.5458, -34.8551, -1000, 2}, -- 1
		{106.469, 75.0198, -34.8562, -1000, 2}, -- 2
	},
	-- Line 6
	{
		{140.489, 43.7454, -34.8561, -1000, 2}, -- 1
		{159.88, 41.4297, -34.8562, -1000, 2}, -- 2
	},
	-- Line 7
	{
		{118.094, 46.5513, -34.8561, -1000, 2}, -- 1
		{100.441, 48.6143, -34.8562, -1000, 2}, -- 2
	},
	-- Line 8
	{
		{147.687, 0.858962, -25.6062, -1000, 2}, -- 1
		{168.083, 1.11938, -25.6062, -1000, 2}, -- 2
	},
	-- Line 9
	{
		{105.713, 13.295, -26.5229, -1000, 2}, -- 1
		{107.036, 30.8438, -26.5229, -1000, 2}, -- 2
	},
	-- Line 10
	{
		{107.494, -12.9412, -26.5229, -1000, 2}, -- 1
		{107.169, -29.977, -26.5229, -1000, 2}, -- 2
	},
	-- Line 11
	{
		{84.7499, -13.3196, -26.5229, -1000, 2}, -- 1
		{84.3913, -29.4361, -26.5229, -1000, 2}, -- 2
	},
	-- Line 12
	{
		{84.5624, 15.7159, -26.5229, -1000, 2}, -- 1
		{84.74, 29.3293, -26.5283, -1000, 2}, -- 2
	},
	-- Line 13
	{
		{129.365, -10.3602, -25.6062, -1000, 2}, -- 1
		{127.663, -48.82, -33.9396, -1000, 2}, -- 2
		{118.373, -79.5858, -33.9396, -1000, 2}, -- 3
		{100.582, -114.611, -35.1896, -1000, 2}, -- 4
		{85.4532, -143.019, -33.9396, -1000, 2}, -- 5
	},
	-- Line 14
	{
		{129.556, -118.659, -33.9395, -1000, 2}, -- 1
		{141.493, -125.612, -33.9396, -1000, 2}, -- 2
	},
	-- Line 15
	{
		{83.2983, -94.4213, -33.9396, -1000, 2}, -- 1
		{68.2169, -87.0903, -33.9396, -1000, 2}, -- 2
	},
	-- Line 16
	{
		{136.731, -69.1582, -34.856, -1000, 2}, -- 1
		{151.85, -73.6735, -34.8562, -1000, 2}, -- 2
	},
	-- Line 17
	{
		{109.186, -61.0821, -34.8561, -1000, 2}, -- 1
		{94.9993, -56.7919, -34.8562, -1000, 2}, -- 2
	},
	-- Line 18
	{
		{143.825, -46.367, -34.8561, -1000, 2}, -- 1
		{157.914, -47.823, -34.8562, -1000, 2}, -- 2
	},
	-- Line 19
	{
		{115.143, -42.0165, -34.8561, -1000, 2}, -- 1
		{97.7063, -40.3421, -34.8562, -1000, 2}, -- 2
	},
};

local TheStockades = t_dungeons[34];

local _losTbl = Encounter_MakeLOSTbl()
	-- Entrance
	.new 'EntrancePull' {73.419, 0.615921, -25.5575} {59.1124, 1.00041, -20.2048}
	.new 'EntrancePul2' {90.4218, 0.59062, -25.6062} {74.0329, 0.42110, -25.6062}
	-- Left Wing
	.new 'LeftWingPull' {129.177, 31.7745, -33.0863} {129.436, 13.4642, -26.1968}
	.new 'LeftWingPul2' {132.038, 56.2775, -33.9396} {130.075, 40.7720, -33.9396}
	.new 'LeftWingBoss' {142.847, 88.0463, -33.9395} {137.062, 73.7350, -33.9395}
	-- Right Wing
	.new 'RightWingPull' {128.967, -33.9872, -33.9396} {129.413, -17.5049, -28.2988}
	.new 'RightWingPul2' {126.990, -52.2567, -33.9391} {128.187, -38.7932, -33.9391}
	.new 'RightWingBoss' {117.026, -84.9016, -33.9396} {122.939, -67.1447, -33.9396}
.endtbl();

local _areaTbl = Encounter_MakeAreaTbl(_losTbl)
	-- Entrance
	.new ('EntrancePl1L', SHAPE_POLYGON) {76.7213, 7.04679} {76.7217, 34.6147} {92.6016, 34.6147} {92.6017, 7.04783} ('EntrancePull', -26.52, 100.0)
	.new ('EntrancePl1R', SHAPE_POLYGON) {92.6007, -5.5563} {92.5207, -33.123} {76.7223, -33.122} {76.839, -5.59178} ('EntrancePull', -26.52, 100.0)
	.new ('EntrancePl2L', SHAPE_POLYGON) {98.9447, 7.04775} {99.0548, 34.4627} {114.729, 34.6017} {114.823, 7.04666} ('EntrancePul2', -26.52, 100.0)
	.new ('EntrancePl2R', SHAPE_POLYGON) {114.823, -5.5566} {114.65, -32.9862} {98.9436, -33.123} {98.9434, -5.5555} ('EntrancePul2', -26.52, 100.0)
	-- Left Wing
	.new ('LeftWingPl1L', SHAPE_POLYGON) {123.046, 37.6376} {95.5997, 39.3590} {98.0067, 59.0696} {124.908, 53.9458} ('LeftWingPull', -34.86, 100.0)
	.new ('LeftWingPl1R', SHAPE_POLYGON) {137.509, 51.7875} {164.517, 46.7863} {163.127, 35.3028} {135.685, 36.8956} ('LeftWingPull', -34.86, 100.0)
	.new ('LeftWingPl2L', SHAPE_POLYGON) {126.329, 60.8330} {99.6794, 66.9835} {105.249, 85.8515} {130.940, 76.5223} ('LeftWingPul2', -34.86, 100.0)
	.new ('LeftWingPl2R', SHAPE_POLYGON) {142.989, 72.0893} {168.610, 62.7726} {165.514, 51.7791} {138.789, 57.8643} ('LeftWingPul2', -34.86, 100.0)
	.new ('LeftWingEndL', SHAPE_POLYGON) {133.762, 109.152} {141.025, 122.825} {116.965, 135.499} {109.799, 122.024} ('LeftWingBoss', -34.86, 100.0)
	.new ('LeftWingEndR', SHAPE_POLYGON) {172.475, 106.178} {196.425, 93.2495} {189.253, 79.7634} {165.262, 92.4876} ('LeftWingBoss', -34.86, 100.0)
	.new ('LeftWingEndF', SHAPE_POLYGON) {154.613, 126.971} {167.491, 150.946} {180.973, 143.770} {168.272, 119.742} ('LeftWingBoss', -34.86, 100.0)
	-- Right Wing
	.new ('RightWingPl1L', SHAPE_POLYGON) {135.042, -37.6386} {162.613, -37.8578} {160.206, -57.5793} {133.215, -52.5271} ('RightWingPull', -34.86, 100.0)
	.new ('RightWingPl1R', SHAPE_POLYGON) {120.701, -50.2938} {93.6974, -45.2852} {95.0798, -33.8234} {122.527, -35.4042} ('RightWingPull', -34.86, 100.0)
	.new ('RightWingPl2L', SHAPE_POLYGON) {131.932, -59.4455} {158.585, -65.2943} {153.021, -84.1772} {127.299, -74.9236} ('RightWingPul2', -34.86, 100.0)
	.new ('RightWingPl2R', SHAPE_POLYGON) {115.186, -70.5198} {89.5210, -61.3242} {92.6981, -50.2852} {119.410, -56.4192} ('RightWingPul2', -34.86, 100.0)
	.new ('RightWingEndL', SHAPE_POLYGON) {124.468, -107.787} {148.381, -120.502} {141.249, -134.182} {117.175, -121.315} ('RightWingBoss', -34.86, 100.0)
	.new ('RightWingEndR', SHAPE_POLYGON) {85.4174, -104.517} {61.7875, -91.7585} {68.9496, -78.1249} {92.9401, -90.9964} ('RightWingBoss', -34.86, 100.0)
.endtbl();

local NPC_RANGED_LIST = Encounter_NewRangedList();
function NPC_RANGED_LIST.IsRanged() return true; end

TheStockades.encounters = {
	fear = true,
	{name = "Targorr the Dread"},
	{name = "Kam Deepfury"},
	{name = "Hamhock", tpos = {116.304, -84.771, -33.9396}, rchrpos = {x=121.543,y=-72.0047,z=-33.9396,melee="dance"}},
	{name = "Bazil Thredd"},
	{name = "Dextren Ward", fear = true, pull = true, tpos = {117.026, -84.9016, -33.9396}, UseLosBreakForPull = true},
	{
		name               = "Global",
		test               = function() return true; end,
		UseLosBreakForPull = true,
		noboss             = true,
	},
};

TheStockades.encounters.LosTbl    = _losTbl;
TheStockades.encounters.AreaTbl   = _areaTbl;
TheStockades.encounters.RangedTbl = NPC_RANGED_LIST;
