
import 'ai/common_encounter.lua'

-----------------------------------------------------------------------------------------------
-- Tested at level 30, with a priest healer, 2 tanks (1 LvlTankSwapOnly), mage dps
-- 
-- When going from Workshop Key route tank is very likely to pick the wrong pull direction
-- when just entering the Engineering labs, pulling unintionally other mobs and likely wiping.
-- Best to face pull.
--
-- There are some issues in the room with many windows in walls with enemeis in them,
-- especially upper rooms if you try to pull there can be pathfinding trouble.
--
-- In the Hall of Gears bots aren't aware of ground dot from Irradiated enemies.
-- Not a problem so long as you don't stack too many in once place.
--
-- Engineering Labs going counterclockwise is quite janky on a pull right after boss.
-- Bottom of Engineering Labs have horrendous navmesh. Don't step on the metal plates
-- near the center of the area.
--
-- Going through the top part of the clean zone from backdoor entrance:
-- last pull before you enter the very first corridor (that has path to Grubis)
-- should be face pulled. Further, pulls near path to Grubis from backdoor
-- direction will try to utilize a pillar for los that doesn't actually break LoS.


t_dungeons[90] = {
	-- Line 1: Dead end path, not from start
	{
		{-341.938, 20.9557, -156.496, -1000, 2}, -- 1
		{-382.759, 61.3438, -156.981, -1000, 2}, -- 2
		{-377.009, 68.7179, -154.765, -1000, 2}, -- 3
		{-367.362, 81.9546, -154.742, -1000, 2}, -- 4
		{-366.447, 131.989, -154.742, -1000, 2}, -- 5
	},
	-- Line 2: To explosives NPC
	{
		{-332.404, -1.54111, -152.845, -1000, 2}, -- 1
		{-358.793, 9.62034, -152.891, -1000, 2}, -- 2
		{-394.363, 46.0655, -154.801, -1000, 2}, -- 3
		{-440.056, 35.419, -154.743, -1000, 2}, -- 4
		{-478.497, 47.7058, -154.769, -1000, 2}, -- 5
		{-485.152, 54.0198, -156.981, -1000, 2}, -- 6
		{-500.21, 39.1422, -156.49, -1000, 2}, -- 7
		{-526.894, 19.8446, -156.483, -1000, 2}, -- 8
		{-536.997, -1.09468, -156.489, -1000, 2}, -- 9
		{-537.875, -45.3743, -152.241, -1000, 2}, -- 10
		{-538.622, -66.0531, -150.703, -1000, 2}, -- 11
		{-529.286, -88.6923, -155.535, -1000, 2}, -- 12
		{-513.39, -125.963, -156.097, -1000, 2}, -- 13
		{-510.911, -132.209, -152.534, -1000, 2}, -- 14
	},
	-- Line 3: RHS cavern
	{
		{-495.71, 70.2217, -154.791, -1000, 2}, -- 15
		{-507.301, 58.6052, -154.751, -1000, 2}, -- 16
		{-537.457, 29.3973, -152.851, -1000, 2}, -- 17
		{-550.995, -5.2052, -152.835, -1000, 2}, -- 18
		{-550.714, -49.3255, -148.383, -1000, 2}, -- 19
		{-547.501, -63.401, -150.971, -1000, 2}, -- 20
		{-545.904, -74.1835, -152.972, -1000, 2}, -- 21
		{-543.969, -85.1553, -155.404, -1000, 2}, -- 22
		{-535.23, -100.417, -155.976, -1000, 2}, -- 23
		{-544.457, -106.855, -155.477, -1000, 2}, -- 24
		{-560.703, -118.827, -151.397, -1000, 2}, -- 25
	},
	-- Line 4: Grubbis cavern
	{
		{-535.026, -57.5122, -150.998, -1000, 2}, -- 1
		{-533.092, -65.9867, -150.003, -1000, 2}, -- 2
		{-524.409, -76.4763, -152.941, -1000, 2}, -- 3
		{-513.642, -93.4054, -152.55, -1000, 2}, -- 4
		{-500.378, -92.0615, -150.694, -1000, 2}, -- 5
		{-483.996, -90.4294, -146.784, -1000, 2}, -- 6
		{-474.958, -107.868, -145.887, -1000, 2}, -- 7
	},
	-- Line 5: Towards the dead end window
	{
		{-501.767, 73.2877, -154.782, -1000, 2}, -- 8
		{-509.73, 84.6831, -154.745, -1000, 2}, -- 9
		{-507.743, 136.646, -154.745, -1000, 2}, -- 10
		{-488.923, 157.438, -154.717, -1000, 2}, -- 11
		{-508.189, 180.461, -155.236, -1000, 2}, -- 12
		{-532.12, 161.006, -155.236, -1000, 2}, -- 13
		{-557.24, 171.929, -155.236, -1000, 2}, -- 14
		{-529.85, 201.132, -155.238, -1000, 2}, -- 15
		{-563.493, 232.886, -159.427, -1000, 2}, -- 16
		{-571.157, 228.624, -159.43, -1000, 2}, -- 17
		{-587.824, 211.875, -165.678, -1000, 2}, -- 18
		{-604.319, 195.643, -171.928, -1000, 2}, -- 19
		{-622.207, 178.042, -178.199, -1000, 2}, -- 20
		{-636.536, 161.465, -184.509, -1000, 2}, -- 21
		{-636.709, 127.927, -183.878, -1000, 2}, -- 22
	},	
	-- Line 6: To construction hanging in mid
	{
		{-481.703, 163.322, -154.72, -1000, 2}, -- 1
		{-465.182, 178.324, -154.743, -1000, 2}, -- 2
		{-424.105, 178.552, -154.743, -1000, 2}, -- 3
		{-424.919, 172.303, -154.025, -1000, 2}, -- 4
		{-431.615, 140.298, -158.22, -1000, 2}, -- 5
		{-433.153, 123.075, -157.041, -1000, 2}, -- 6
		{-424.841, 112.925, -156.795, -1000, 2}, -- 7
		{-434.762, 101.643, -153.907, -1000, 2}, -- 8
	},
	-- Line 7: Other side of contruction
	{
		{-436.473, 122.267, -156.485, -1000, 2}, -- 1
		{-446.991, 113.027, -153.824, -1000, 2}, -- 2
		{-439.603, 102.274, -153.344, -1000, 2}, -- 3
	},
	-- Line 8: Down the stairs to many window room
	{
		{-500.451, 189.284, -155.236, -1000, 2}, -- 1
		{-495.571, 194.963, -155.236, -1000, 2}, -- 2
		{-488.315, 202.983, -161.987, -1000, 2}, -- 3
		{-487.524, 208.429, -161.987, -1000, 2}, -- 4
		{-493.741, 223.941, -172.787, -1000, 2}, -- 5
		{-497.739, 226.787, -172.787, -1000, 2}, -- 6
		{-501.782, 228.115, -175.487, -1000, 2}, -- 7
		{-507.111, 227.006, -175.487, -1000, 2}, -- 8
		{-526.817, 206.804, -193.712, -1000, 2}, -- 9
		{-548.293, 164.055, -193.74, -1000, 2}, -- 10
		{-554.857, 150.693, -202.151, -1000, 2}, -- 11
		{-568.294, 135.084, -202.143, -1000, 2}, -- 12
		{-567.581, 97.3969, -200.74, -1000, 2}, -- 13
		{-565.172, 82.3024, -204.49, -1000, 2}, -- 14
		{-541.431, 80.3165, -201.843, -1000, 2}, -- 15
	},
	-- Line 9: Right wall bottom right window
	{
		{-575.252, 139.987, -202.139, -1000, 2}, -- 1
		{-590.011, 140.153, -202.133, -1000, 2}, -- 2
		{-594.843, 140.124, -198.775, -1000, 2}, -- 3
		{-603.369, 140.073, -199.661, -1000, 2}, -- 4
		{-617.186, 153.635, -199.655, -1000, 2}, -- 5
	},
	-- Line 10: Right wall bottom middle window
	{
		{-580.451, 110.908, -201.89, -1000, 2}, -- 1
		{-590.629, 110.515, -202.131, -1000, 2}, -- 2
		{-594.873, 110.407, -198.747, -1000, 2}, -- 3
		{-611.925, 110.385, -199.655, -1000, 2}, -- 4
		{-623.961, 111.876, -199.646, -1000, 2}, -- 5
		{-645.273, 111.562, -190.908, -1000, 2}, -- 6
	},
	-- Line 11: Right wall bottom left window
	{
		{-584.175, 96.3322, -202.995, -1000, 2}, -- 1
		{-586.441, 80.1105, -202.732, -1000, 2}, -- 2
		{-594.629, 78.7513, -198.974, -1000, 2}, -- 3
		{-623.09, 74.3639, -199.645, -1000, 2}, -- 4
		{-646.627, 72.6305, -190.322, -1000, 2}, -- 5
	},
	-- Line 12: Right wall top left window
	{
		{-595.989, 93.5531, -197.706, -1000, 2}, -- 1
		{-611.95, 93.6868, -182.816, -1000, 2}, -- 2
		{-629.98, 93.1588, -183.275, -1000, 2}, -- 3
		{-641.931, 91.0381, -183.266, -1000, 2}, -- 4
		{-663.164, 88.9618, -174.389, -1000, 2}, -- 5
	},
	-- Line 13: Far wall bottom right window
	{
		{-576.755, 76.2571, -203.672, -1000, 2}, -- 1
		{-574.445, 65.6918, -201.499, -1000, 2}, -- 2
		{-573.905, 61.1459, -198.6, -1000, 2}, -- 3
		{-572.256, 46.8948, -200.223, -1000, 2}, -- 4
	},
	-- Line 14: Far wall top right window
	{
		{-582.131, 66.0515, -202.677, -1000, 2}, -- 1
		{-587.623, 40.093, -179.687, -1000, 2}, -- 2
		{-587.808, 29.2633, -179.685, -1000, 2}, -- 3
		{-589.297, 14.9149, -179.678, -1000, 2}, -- 4
	},
	-- Line 15: Far wall bottom right window
	{
		{-556.159, 63.2313, -198.966, -1000, 2}, -- 1
		{-555.861, 39.9869, -179.593, -1000, 2}, -- 2
		{-555.802, 28.5001, -179.742, -1000, 2}, -- 3
		{-554.995, 13.5462, -179.733, -1000, 2}, -- 4
	},
	-- Line 16: Far wall bottom left window
	{
		{-548.962, 75.637, -200.963, -1000, 2}, -- 1
		{-544.515, 63.6462, -198.755, -1000, 2}, -- 2
		{-543.211, 54.8811, -198.869, -1000, 2}, -- 3
		{-542.314, 40.9919, -199.893, -1000, 2}, -- 4
	},
	-- Line 17: To entrance to fallout boss
	{
		{-550.22, 144.014, -202.151, -1000, 2}, -- 1
		{-542.196, 130.488, -202.151, -1000, 2}, -- 2
		{-540.546, 109.425, -204.515, -1000, 2}, -- 3
		{-525.784, 109.374, -204.489, -1000, 2}, -- 4
	},
	-- Line 18: RHS semi circle fallout boss room
	{
		{-523.217, 109.641, -204.764, -1000, 2}, -- 1
		{-510.599, 107.562, -208.064, -1000, 2}, -- 2
		{-504.021, 78.7861, -208.461, -1000, 2}, -- 3
		{-500.73, 74.2793, -205.063, -1000, 2}, -- 4
		{-468.172, 41.9205, -208.393, -1000, 2}, -- 5
		{-408.266, 41.5786, -208.524, -1000, 2}, -- 6
		{-378.213, 81.4953, -210.496, -1000, 2}, -- 7
	},
	-- Line 19: Right line thru fallout boss room
	{
		{-507.702, 107.78, -208.323, -1000, 2}, -- 1
		{-475.359, 105.045, -210.755, -1000, 2}, -- 2
		{-464.891, 102.163, -209.063, -1000, 2}, -- 3
		{-456.355, 99.1634, -209.063, -1000, 2}, -- 4
		{-429.348, 88.3197, -209.301, -1000, 2}, -- 5
		{-410.461, 77.2593, -211.304, -1000, 2}, -- 6
	},
	-- Line 20: Left line through fallout boss room
	{
		{-504.476, 110.548, -208.61, -1000, 2}, -- 1
		{-463.781, 120.799, -210.63, -1000, 2}, -- 2
		{-445.346, 123.91, -209.272, -1000, 2}, -- 3
		{-435.864, 127.565, -211.752, -1000, 2}, -- 4
		{-409.868, 131.378, -211.529, -1000, 2}, -- 5
	},
	-- Line 21: LHS semi circle fallout boss room
	{
		{-506.393, 118.745, -208.453, -1000, 2}, -- 1
		{-500.349, 139.156, -208.749, -1000, 2}, -- 2
		{-464.982, 174.634, -208.71, -1000, 2}, -- 3
		{-413.257, 174.5, -208.807, -1000, 2}, -- 4
		{-370.851, 135.099, -208.723, -1000, 2}, -- 5
		{-373.841, 103.504, -209.7, -1000, 2}, -- 6
	},
	-- Line 22: Upper sidewalk to launch bay and LHS semi circle
	{
		{-445.972, 187.543, -207.907, -1000, 2}, -- 1
		{-446.463, 239.038, -207.941, -1000, 2}, -- 2
		{-454.411, 256.691, -207.919, -1000, 2}, -- 3
		{-478.989, 264.287, -207.906, -1000, 2}, -- 4
		{-515.134, 262.222, -207.95, -1000, 2}, -- 5
		{-547.87, 276.597, -207.936, -1000, 2}, -- 6
		{-561.873, 310.536, -213.328, -1000, 2}, -- 7
		{-561.549, 351.871, -227.376, -1000, 2}, -- 8
		{-561.376, 361.046, -231.679, -1000, 2}, -- 9
		{-557.686, 409.862, -230.6, -1000, 2}, -- 10
		{-604.73, 428.167, -230.6, -1000, 2}, -- 11
		{-635.668, 468.942, -230.6, -1000, 2}, -- 12
		{-645.848, 512.634, -230.6, -1000, 2}, -- 13
		{-632.312, 549.08, -230.6, -1000, 2}, -- 14
		{-604.819, 579.484, -230.6, -1000, 2}, -- 15
		{-553.315, 596.559, -230.6, -1000, 2}, -- 16
	},
	-- Line 23: Bottom sidewalk to launch bay and RHS semi circle
	{
		-- {-426.959, 193.152, -211.545, -1000, 2}, -- 1
		-- {-428.939, 238.553, -211.544, -1000, 2}, -- 2
		-- {-441.35, 266.426, -211.542, -1000, 2}, -- 3
		-- {-468.505, 278.532, -211.541, -1000, 2}, -- 4
		-- {-515.373, 280.508, -211.543, -1000, 2}, -- 5
		-- {-534.135, 291.969, -211.547, -1000, 2}, -- 6
		-- {-538.977, 301.984, -213.754, -1000, 2}, -- 7
		-- {-540.254, 308.432, -216.979, -1000, 2}, -- 8
		-- {-540.638, 311.533, -216.972, -1000, 2}, -- 9
		-- {-540.124, 355.145, -231.405, -1000, 2}, -- 10
		-- {-533.352, 408.696, -230.6, -1000, 2}, -- 11
		-- {-488.149, 435.315, -230.6, -1000, 2}, -- 12
		-- {-458.814, 481.716, -230.6, -1000, 2}, -- 13
		-- {-462.166, 550.592, -230.6, -1000, 2}, -- 14
		-- {-509.543, 589.437, -230.6, -1000, 2}, -- 15
		{-433.767, 195.779, -211.537, -1000, 2}, -- 1
		{-432.183, 237.997, -211.539, -1000, 2}, -- 2
		{-444.411, 265.221, -211.537, -1000, 2}, -- 3
		{-468.139, 275.756, -211.536, -1000, 2}, -- 4
		{-514.308, 278.496, -211.54, -1000, 2}, -- 5
		{-536.623, 287.988, -211.54, -1000, 2}, -- 6
		{-542.554, 299.858, -213.973, -1000, 2}, -- 7
		{-545.764, 307.295, -216.547, -1000, 2}, -- 8
		{-546.529, 315.45, -218.328, -1000, 2}, -- 9
		{-544.795, 352.315, -231.162, -1000, 2}, -- 10
		{-533.352, 408.696, -230.6, -1000, 2}, -- 11
		{-488.149, 435.315, -230.6, -1000, 2}, -- 12
		{-458.814, 481.716, -230.6, -1000, 2}, -- 13
		{-462.166, 550.592, -230.6, -1000, 2}, -- 14
		{-509.543, 589.437, -230.6, -1000, 2}, -- 15
	},
	-- Line 24: Electrocutioner bridge
	{
		{-526.526, 604.703, -230.6, -1000, 2}, -- 1
		{-531.845, 584.388, -230.602, -1000, 2}, -- 2
		{-537.382, 561.422, -221.945, -1000, 2}, -- 3
		{-540.91, 545.405, -217.94, -1000, 2}, -- 4
		{-544.863, 527.461, -216.174, -1000, 2}, -- 5
		{-552.219, 488.779, -216.81, -1000, 2}, -- 6
	},
	-- Line 25: Down the stairs of launch bay, and RHS semi circle
	{
		{-597.679, 419.247, -230.602, -1000, 2}, -- 1
		{-624.356, 439.915, -230.602, -1000, 2}, -- 2
		{-653.362, 418.065, -230.625, -1000, 2}, -- 3
		{-643.905, 406.305, -230.625, -1000, 2}, -- 4
		{-633.925, 393.316, -238.959, -1000, 2}, -- 5
		{-623.877, 379.931, -247.25, -1000, 2}, -- 6
		{-624.521, 367.954, -247.266, -1000, 2}, -- 7
		{-635.219, 358.829, -255.587, -1000, 2}, -- 8
		{-644.352, 359.225, -255.584, -1000, 2}, -- 9
		{-652.549, 369.876, -263.75, -1000, 2}, -- 10
		{-655.67, 373.639, -263.917, -1000, 2}, -- 11
		{-663.828, 384.736, -273.061, -1000, 2}, -- 12
		{-679.062, 407.358, -273.064, -1000, 2}, -- 13
		{-595.988, 471.057, -273.079, -1000, 2}, -- 14
		{-509.398, 480.903, -273.077, -1000, 2}, -- 15
		{-505.5, 518.017, -273.076, -1000, 2}, -- 16
	},
	-- Line 26: Launch bay bottom LHS semi cricle
	{
		{-612.06, 460.252, -273.074, -1000, 2}, -- 1
		{-597.968, 473.759, -273.081, -1000, 2}, -- 2
		{-575.905, 544.572, -273.075, -1000, 2}, -- 3
		{-522.611, 541.32, -273.076, -1000, 2}, -- 4
	},
	-- Line 27: To Engineering Labs and full circle (pummeler direction)
	{
		{-712.482, 446.697, -273.063, -1000, 2}, -- 1
		{-760.879, 414.019, -272.58, -1000, 2}, -- 2
		{-884.74, 430.028, -272.597, -1000, 2}, -- 3
		{-893.47, 416.599, -272.597, -1000, 2}, -- 4
		{-906.108, 306.223, -272.597, -1000, 2}, -- 5
		{-891.309, 295.914, -272.597, -1000, 2}, -- 6
		{-782.358, 284.163, -272.598, -1000, 2}, -- 7
		{-772.086, 295.201, -272.598, -1000, 2}, -- 8
		{-758.161, 406.878, -272.579, -1000, 2}, -- 9
		{-717.181, 450.69, -273.063, -1000, 2}, -- 10
	},
	-- Line 28: Workshop Key route
	{
		{-733.113, 3.00171, -248.927, -1000, 2}, -- 1
		{-746.229, 3.45901, -252.218, -1000, 2}, -- 2
		{-761.956, 13.3862, -252.218, -1000, 2}, -- 3
		{-762.845, 66.1233, -258.545, -1000, 2}, -- 4
		{-765.221, 91.3241, -260.566, -1000, 2}, -- 5
		{-780.291, 94.6266, -260.566, -1000, 2}, -- 6
		{-799.443, 97.3262, -264.731, -1000, 2}, -- 7
		{-815.293, 111.834, -264.731, -1000, 2}, -- 8
		{-814.221, 176.098, -273.079, -1000, 2}, -- 9
		{-741.781, 240.566, -273.081, -1000, 2}, -- 10
		{-795.884, 310.167, -272.598, -1000, 2}, -- 11
	},
	-- Line 29: From path to Mekgineer to Engineer labs bottom floor + lab circle
	{
		{-799.628, 535.307, -295.576, -1000, 2}, -- 1
		{-811.273, 526.268, -299.761, -1000, 2}, -- 2
		{-814.676, 523.7, -300.029, -1000, 2}, -- 3
		{-823.432, 516.265, -303.621, -1000, 2}, -- 4
		{-832.821, 498.632, -303.937, -1000, 2}, -- 5
		{-826.482, 488.692, -303.944, -1000, 2}, -- 6
		{-819.085, 475.553, -308.104, -1000, 2}, -- 7
		{-815.581, 458.213, -308.104, -1000, 2}, -- 8
		{-845.909, 432.111, -312.282, -1000, 2}, -- 9
		{-870.803, 411.733, -316.451, -1000, 2}, -- 10
		{-854.419, 388.358, -316.432, -1000, 2}, -- 11
		{-865.684, 340.117, -316.433, -1000, 2}, -- 12
		{-836.201, 323.26, -316.775, -1000, 2}, -- 13
		{-810.967, 333.483, -316.865, -1000, 2}, -- 14
		{-794.794, 355.98, -316.428, -1000, 2}, -- 15
		{-811.571, 390.004, -316.433, -1000, 2}, -- 16
		{-849.909, 394.143, -316.432, -1000, 2}, -- 17
		{-876.206, 410.128, -316.446, -1000, 2}, -- 18
	},
	-- Line 30: Bottom road to Mekgineer
	{
		{-631.827, 528.068, -273.063, -1000, 2}, -- 1
		{-655.185, 534.975, -272.504, -1000, 2}, -- 2
		{-670.078, 538.951, -285.783, -1000, 2}, -- 3
		{-676.606, 541.211, -285.783, -1000, 2}, -- 4
		{-697.685, 547.463, -294.783, -1000, 2}, -- 5
		{-704.61, 549.312, -294.784, -1000, 2}, -- 6
		{-726.549, 554.876, -303.783, -1000, 2}, -- 7
		{-746.107, 559.12, -303.783, -1000, 2}, -- 8
		{-754.814, 585.61, -303.783, -1000, 2}, -- 9
		{-752.19, 597.676, -303.783, -1000, 2}, -- 10
		{-746.24, 620.539, -312.783, -1000, 2}, -- 11
		{-744.973, 625.287, -312.783, -1000, 2}, -- 12
		{-738.962, 647.809, -321.783, -1000, 2}, -- 13
		{-737.462, 653.516, -321.783, -1000, 2}, -- 14
		{-731.451, 676.688, -330.783, -1000, 2}, -- 15
		{-723.606, 698.88, -330.783, -1000, 2}, -- 16
		{-696.749, 704.92, -330.783, -1000, 2}, -- 17
		{-660.184, 695.6, -331.782, -1000, 2}, -- 18
		{-644.721, 690.336, -326.807, -1000, 2}, -- 19
	},
	-- Line 31: Top road to Mekgineer
	{
		{-657.794, 519.872, -273.06, -1000, 2}, -- 1
		{-680.287, 525.04, -273.06, -1000, 2}, -- 2
		{-708.17, 532.198, -282.06, -1000, 2}, -- 3
		{-731.678, 538.256, -291.06, -1000, 2}, -- 4
		{-750.801, 545.142, -291.06, -1000, 2}, -- 5
		{-767.935, 564.885, -291.06, -1000, 2}, -- 6
		{-772.294, 586.426, -291.06, -1000, 2}, -- 7
		{-767.842, 603.582, -291.12, -1000, 2}, -- 8
		{-763.006, 622.655, -299.621, -1000, 2}, -- 9
		{-761.071, 630.289, -300.06, -1000, 2}, -- 10
		{-753.805, 658.95, -309.06, -1000, 2}, -- 11
		{-748.324, 680.568, -318.06, -1000, 2}, -- 12
		{-742.389, 700.024, -318.06, -1000, 2}, -- 13
		{-724.049, 718.332, -318.06, -1000, 2}, -- 14
		{-704.296, 723.22, -318.06, -1000, 2}, -- 15
		{-683.906, 718.194, -318.06, -1000, 2}, -- 16
		{-662.878, 713.126, -327.06, -1000, 2}, -- 17
		{-640.95, 707.31, -327.06, -1000, 2}, -- 18
	},
	-- Line 32: Final pull to Mekgineer
	{
		{-642.194, 697.46, -327.06, -1000, 2}, -- 1
		{-585.497, 681.447, -327.058, -1000, 2}, -- 2
		{-478.649, 665.518, -327.343, -1000, 2}, -- 3
	},
};

local Gnomeregan = t_dungeons[90];

local function Gnomeregan_OnLoad(self, hive, data, player)
	
-- Entries
local GO_EXPLOSIVE_CHARGE         = 144065;
local GO_CAVE_IN_NORTH            = 146085;
local GO_CAVE_IN_SOUTH            = 146086;
local NPC_BLASTMASTER_SHORTFUSE   = 7998;
	
	Print("Gnomeregan_OnLoad: initialized by player", player:GetName(), "; Guid:", tostring(player:GetGuid()), player:GetMapId());

	-- find guids
	-- blastmaster
	local bmPosStart = Gnomeregan.Blastmaster.BmPosStart;
	local x,y,z,r = bmPosStart.x, bmPosStart.y, bmPosStart.z, 80.0;
	local blastmaster = GetUnitsWithEntryNear(player, NPC_BLASTMASTER_SHORTFUSE, x, y, z, r, false, false)[1];
	if (not blastmaster) then
		Print("Failed to find Blastmaster at coords = (", x, y, z, ") with radius =", r, "entry =", NPC_BLASTMASTER_SHORTFUSE);
		error("Gnomeregan_OnLoad: Blastmaster not found in map. Entry = " .. tostring(NPC_BLASTMASTER_SHORTFUSE));
	end
	self.Ids.Blastmaster = blastmaster:GetGuid();
	
	-- explosive charges
	r = 60.0;
	local charges = GetObjectsWithEntryAround(blastmaster, GO_EXPLOSIVE_CHARGE, r, false);
	if (#charges < 4) then
		x,y,z = blastmaster:GetPosition();
		Print("Failed to find charges around blastmaster = (", x, y, z, ") with radius =", r, "BM entry =", NPC_BLASTMASTER_SHORTFUSE);
		for i,v in ipairs(charges) do
			Print("Charge:", v);
		end
		Print("Total charges:", #charges, "required: 4");
		error("Gnomeregan_OnLoad: Not all explosive charges were found in map. Entry = " .. tostring(GO_EXPLOSIVE_CHARGE));
	end
	self.Ids.ExplosiveCharges = charges;

	-- cave ins
	local caveInNorth = GetObjectsWithEntryAround(blastmaster, GO_CAVE_IN_NORTH, r, false)[1];
	local caveInSouth = GetObjectsWithEntryAround(blastmaster, GO_CAVE_IN_SOUTH, r, false)[1];
	
	if (not caveInNorth or not caveInSouth) then
		Print("Failed to find cave ins around blastmaster = (", x, y, z, ") with radius =", r, "BM entry =", NPC_BLASTMASTER_SHORTFUSE);
		Print("North =", caveInNorth, GO_CAVE_IN_NORTH, "South =", caveInSouth, GO_CAVE_IN_SOUTH);
		error("Gnomeregan_OnLoad: Not all cave ins were found in map.");
	end
	
	self.Ids.CaveInNorth = caveInNorth;
	self.Ids.CaveInSouth = caveInSouth;
	
end

--------------------------------------------------------------------
--                 Mekgineer event script
--------------------------------------------------------------------
Gnomeregan.Mekgineer = 
{
	assignee = nil, -- ai userdata associated with agent assigned to buttons
	bombs = {},     -- list of active bombs
};

local function GetAIFromGuid(guid)

	local agent = GetPlayerByGuid(guid);
	if (not agent) then
		return;
	end
	
	local ai = agent:GetAI();
	if (not ai) then
		return;
	end
	
	return agent, ai;

end

function Gnomeregan.Mekgineer:SelectAgent(data)
	
	if (#data.agents > 0 and self.assignee == nil) then
		for i = 1, #data.agents do
			local ai = data.agents[i];
			local agent = ai:GetPlayer();
			if (ai:GetRole() == ROLE_RDPS and agent:IsAlive()) then
				self.assignee = agent:GetGuid();
				Print("Gnomeregan.Mekgineer:", agent:GetName(), "assigned");
				return;
			end
		end
	end
	
end

function Gnomeregan.Mekgineer.AgentScript(ai, agent, goal, party, data, partyData)
	
	-- push button for active face
	
	local faces = Gnomeregan_GetFaceData(partyData.owner);
	if (not faces) then
		Print("Gnomeregan.Mekgineer:", agent:GetName(), "AgentScript: no faces on map");
		Command_Complete(ai);
		goal:ClearSubGoal();
		return;
	end
	
	local face = faces[data.script.face];
	if (face.active == false) then
		Print("Gnomeregan.Mekgineer:", agent:GetName(), "AgentScript: CMD_SCRIPT end");
		Command_Complete(ai);
		goal:ClearSubGoal();
		return;
	end
	
	if (goal:GetSubGoalNum() > 0) then
		return;
	end
	
	goal:AddSubGoal(GOAL_COMMON_UseObj, 10, face.btnGuid);
	
end

function Gnomeregan.Mekgineer:ResetAssignee(hive, data)
	
	if (self.assignee) then
		local agent, ai = GetAIFromGuid(self.assignee);
		if (agent) then
			local aidata = ai:GetData();
			aidata.script = nil;
			aidata.targets = nil;
			aidata.attackmode = nil;
			ai:SetRole(ROLE_RDPS);
			Command_Complete(ai);
		end
		self.assignee = nil;
	end
	
end

function Gnomeregan.Mekgineer:Update(hive, data)
	
	if (nil == data.owner and nil == data.agents[1]) then
		return;
	end
	
	if (self.assignee == nil) then
		self:SelectAgent(data);
	end
	-- no ranged dps in party
	if (self.assignee == nil) then
		return;
	end
	
	local agent, ai = GetAIFromGuid(self.assignee);
	if (not agent or not agent:IsAlive()) then
		self:ResetAssignee(hive, data);
		return;
	end
	
	local aidata = ai:GetData();
	
	self.bombs = Gnomeregan_GetBombs(data.owner);
	self.bombs.ignoreThreat = true;
	
	-- remove bombs from list of attackers
	for i = #data.attackers, 1, -1 do
		local attacker = data.attackers[i];
		if (attacker:GetName() == "Walking Bomb") then
			table.remove(data.attackers, i);
		end
	end
	
	-- only bombs that are on the ground
	local _,__,z = agent:GetPosition();
	for i = #self.bombs, 1, -1 do
		local bomb = self.bombs[i];
		local _,__,bombZ = bomb:GetPosition();
		if (bombZ - z > 5.0) then
			table.remove(self.bombs, i);
		end
	end
	
	-- attack bombs
	if (#self.bombs > 0) then
		
		
		ai:SetRole(ROLE_SCRIPT);
		aidata.targets = self.bombs;
		aidata.attackmode = "burst";
		-- interrupt old attack targets
		if (ai:CmdType() == CMD_ENGAGE and agent:GetVictim() and agent:GetVictim():GetName() ~= "Walking Bomb") then
			Command_Complete(ai);
		end
		if (ai:CmdType() ~= CMD_ENGAGE) then
			Print("Gnomeregan.Mekgineer:", ai:GetPlayer():GetName(), "engaging Walking Bombs");
			-- hive:CmdEngage(ai, 0);
			Command_IssueEngage(ai, hive);
		end
		return;
	else
		aidata.targets = nil;
		aidata.attackmode = nil;
	end
	
	-- disable faces
	local faces = Gnomeregan_GetFaceData(data.owner);
	for i,face in ipairs(faces) do
		if (face.active) then
			ai:SetRole(ROLE_SCRIPT);
			if (ai:CmdType() ~= CMD_SCRIPT) then
				Print("Gnomeregan.Mekgineer:", ai:GetPlayer():GetName(), "send CMD_SCRIPT for face", i);
				aidata.script = {fn = self.AgentScript, face = i};
				-- hive:CmdScript(ai);
				Command_IssueScript(ai, hive);
			end
			return;
		end
	end
	
	ai:SetRole(ROLE_RDPS);
	
end

function Gnomeregan.Mekgineer:OnEnd(hive, data)
	
	print("Gnomeregan.Mekgineer encounter ended");
	self:ResetAssignee(hive, data);
	self.bombs = {};
	
end

--------------------------------------------------------------------
--                 Blastmaster event script
--------------------------------------------------------------------

Gnomeregan.Blastmaster = {
	BmPosStart = {x = -514.935, y = -138.544, z = -152.399}, -- starting position of Blastmaster NPC
	WaitPos = {
		[1] = {x = -537.113, y = -101.872, z = -155.951}, -- wait by entrance position of south cave
		[2] = {x = -555.874, y = -114.762, z = -152.504}, -- wait inside cave position of south cave
		[3] = {x = -510.286, y =  -96.331, z = -151.751}, -- wait by entrance position of north cave
		[4] = {x = -487.885, y =  -90.055, z = -147.543}, -- wait inside cave position of north cave
	},
	OutsideWaitPos = {x = -521.865, y = -97.156, z = -154.492}, -- wait outside for charges to explode position
	Phase = 0,
	GrubbisDead = false,
};

function Gnomeregan.Blastmaster.Test(hive, data)
	
	local player = data.owner or (data.agents[1] and data.agents[1]:GetPlayer());
	if (player and player:GetMapId() == 90) then
		
		local GuidList = Gnomeregan.encounters.Ids;
		if (nil == GuidList.Blastmaster) then
			return false;
		end
		
		local blastmaster = GetUnitByGuid(player, Gnomeregan.encounters.Ids.Blastmaster);
		if (nil == blastmaster or false == blastmaster:IsAlive()) then
			return false;
		end
		
		-- local southX,southY,southZ = blastmaster:GetPositionOfObj(GuidList.CaveInSouth);
		-- local northX,northY,northZ = blastmaster:GetPositionOfObj(GuidList.CaveInNorth);
		local bmPosStart = Gnomeregan.Blastmaster.BmPosStart;
		local x,y,z,d = bmPosStart.x, bmPosStart.y, bmPosStart.z, 20.0;
		
		-- if tracked player is too far we don't care about this event
		if (player:GetDistance(blastmaster) >= 150.0) then
			return false;
		elseif (Gnomeregan.Blastmaster.Phase > 0) then
			-- Encounter has reset. IsAlive check above should be enough tho
			-- if (blastmaster:GetDistance(x,y,z) < 5) then
				-- return false;
			-- end
			return true;
		end
		
		-- if Blastmaster is moving around
		if (blastmaster:IsMoving() or blastmaster:GetDistance(x,y,z) >= d) then
			return true;
		end
		
		-- if any cave is open
		local southCaveState = GetObjectGOState(player, GuidList.CaveInSouth);
		local northCaveState = GetObjectGOState(player, GuidList.CaveInNorth);
		if (southCaveState == 0 or northCaveState == 0) then
			return true;
		end
		
	end
	return false;
	
end

function Gnomeregan.Blastmaster:UpdatePhase(player, blastmaster)
	
	-- Phase 1: wait at cave entrance south (if both caves are closed)
	-- Phase 2: defend inside cave until both charges planted then wait until the cave is closed outside (if south cave is open)
	-- Phase 3: wait at cave entrance north (if both caves are closed)
	-- Phase 4: defend inside cave until both charges planted then wait until the cave is closed outside (if north cave is open)
	-- Phase 5: wait outside cave entrance
	
	local GuidList = Gnomeregan.encounters.Ids;
	
	local southCaveState = GetObjectGOState(player, GuidList.CaveInSouth);
	local northCaveState = GetObjectGOState(player, GuidList.CaveInNorth);
	
	-- both caves are closed
	if (southCaveState + northCaveState == 2) then
		if (self.Phase > 3) then
			-- encounter ends
			self.Phase = 6;
		elseif (self.Phase > 1) then
			-- switch to north cave
			self.Phase = 3;
		else
			-- do south cave
			self.Phase = 1;
		end
		return;
	end
	
	-- south cave is open
	if (southCaveState == 0) then
		self.Phase = 2;
		return;
	end
	
	-- north cave is open
	if (northCaveState == 0) then
		if (self.GrubbisDead) then
			self.Phase = 5;
		else
			self.Phase = 4;
		end
		return;
	end
	
end

-- remember everyone's roles
function Gnomeregan.Blastmaster:PreprocessAgents(data)
	for i,ai in ipairs(data.agents) do
		local data = ai:GetData();
		if (nil == data["Gnomeregan.Blastmaster.OldRole"]) then
			data["Gnomeregan.Blastmaster.OldRole"] = ai:GetRole();
		end
		data._tankpos = nil;
	end
end

-- reset everyone's roles
function Gnomeregan.Blastmaster:RestoreAgents(data)
	for i,ai in ipairs(data.agents) do
		local data = ai:GetData();
		if (data["Gnomeregan.Blastmaster.OldRole"]) then
			Command_ClearAll(ai, "Gnomeregan.Blastmaster.RestoreAgents");
			ai:SetRole(data["Gnomeregan.Blastmaster.OldRole"]);
			data["Gnomeregan.Blastmaster.OldRole"] = nil;
		end
		data._tankpos = nil;
	end
end

function Gnomeregan.Blastmaster:ChangeRole(ai, newRole)
	if (nil == ai:GetData()["Gnomeregan.Blastmaster.OldRole"]) then
		error("Gnomeregan.Blastmaster.ChangeRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	ai:SetRole(newRole);
end

function Gnomeregan.Blastmaster:GetRealRole(ai)
	local data = ai:GetData();
	if (nil == data["Gnomeregan.Blastmaster.OldRole"]) then
		error("Gnomeregan.Blastmaster.GetRealRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	return data["Gnomeregan.Blastmaster.OldRole"];
end

function Gnomeregan.Blastmaster:RestoreRole(ai)
	local data = ai:GetData();
	if (data["Gnomeregan.Blastmaster.OldRole"]) then
		ai:SetRole(data["Gnomeregan.Blastmaster.OldRole"]);
		return;
	end
	error("Gnomeregan.Blastmaster.RestoreRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
end

function Gnomeregan.Blastmaster:OnBegin(hive, data)
	
	self.Phase       = 0;
	self.GrubbisDead = false;
	self:PreprocessAgents(data);
	data.disablePull = true;
	
end

function Gnomeregan.Blastmaster:UpdateAgents(data, x, y, z, numAttackers, forTank, bSetTpos)
	for i,ai in ipairs(data.agents) do
		
		local agent = ai:GetPlayer();
		local role = self:GetRealRole(ai);
		
		if (forTank and role ~= ROLE_TANK) then
			
			-- restore irrelevant agents to normal function
			if (ai:GetRole() == ROLE_SCRIPT) then
				Command_ClearAll(ai, "Gnomeregan.Blastmaster releasing control");
				agent:ClearMotion();
				self:RestoreRole(ai);
			end
			
		end
		
		-- so we don't get crushed by explosives
		if (forTank and bSetTpos and role == ROLE_TANK) then
			ai:GetData()._tankpos = {self.OutsideWaitPos.x, self.OutsideWaitPos.y, self.OutsideWaitPos.z}
		end
		
		if ((forTank and role == ROLE_TANK) or not forTank) then
			if (numAttackers == 0) then
			
				if (ai:GetRole() ~= ROLE_SCRIPT) then
					Command_ClearAll(ai, "Gnomeregan.Blastmaster taking control");
					self:ChangeRole(ai, ROLE_SCRIPT);
				end
				-- stand at the entrance
				if (agent:GetDistance(x,y,z) > 5 and false == ai:IsMovingTo(x,y,z)) then
					agent:ClearMotion();
					agent:MovePoint(x,y,z,false);
				end
				
			elseif (ai:GetRole() == ROLE_SCRIPT) then
				Command_ClearAll(ai, "Gnomeregan.Blastmaster releasing control");
				agent:ClearMotion();
				self:RestoreRole(ai);
			end
		end
		
	end
end

function Gnomeregan.Blastmaster:Update(hive, data)
	
local NPC_CAVERNDEEP_BURROWER = 6206;
local NPC_CAVERNDEEP_AMBUSHER = 6207;
local NPC_GRUBBIS            = 7361;
local NPC_CHOMPER            = 6215;
	
	local player = data.owner or (data.agents[1] and data.agents[1]:GetPlayer());
	if (not player or self.Phase > 5) then
		self:RestoreAgents(data);
		return;
	end
	
	local GuidList = Gnomeregan.encounters.Ids;
	local blastmaster = GetUnitByGuid(player, GuidList.Blastmaster);
	if (nil == blastmaster or false == blastmaster:IsAlive()) then
		return;
	end
	
	self:UpdatePhase(player, blastmaster);

	local function GetNumSpawnedCharges()
		local n = 0;
		for i,chargeGuid in ipairs(GuidList.ExplosiveCharges) do
			if (GetObjectIsSpawned(player, chargeGuid)) then
				n = n + 1;
			end
		end
		return n;
	end
	
	local wPos = self.WaitPos[self.Phase];
	local safePos = self.OutsideWaitPos;
	local x,y,z = blastmaster:GetPosition();
	
	local southCaveState = GetObjectGOState(player, GuidList.CaveInSouth);
	local northCaveState = GetObjectGOState(player, GuidList.CaveInNorth);
	local numAttackers = 0;
	if (southCaveState == 0 or northCaveState == 0) then
		local ambushers = GetUnitsWithEntryNear(blastmaster, NPC_CAVERNDEEP_AMBUSHER, x, y, z, 50.0, true, true);
		local burrowers = GetUnitsWithEntryNear(blastmaster, NPC_CAVERNDEEP_BURROWER, x, y, z, 50.0, true, true);
		numAttackers = #ambushers + #burrowers;
		data.attackers = {};
		for i,v in ipairs(ambushers) do table.insert(data.attackers, v) end
		for i,v in ipairs(burrowers) do table.insert(data.attackers, v) end
		table.sort(data.attackers, function(a, b) return a:GetHealth() < b:GetHealth(); end);
	end
	
	if (self.Phase == 1) then
		
		-- get tank facing the cave
		-- Print("Phase", self.Phase, "Tank should face Southern Cave");
		self:UpdateAgents(data, wPos.x, wPos.y, wPos.z, numAttackers, true);
		
	elseif (self.Phase == 2) then
		
		-- get tank into the cave when out of combat, leave when about to explode
		if (GetNumSpawnedCharges() < 2) then
			-- Print("Phase", self.Phase, "Tank should camp the Southern Cave");
			self:UpdateAgents(data, wPos.x, wPos.y, wPos.z, numAttackers, true);
		else
			-- Print("Phase", self.Phase, "Everyone should evacuate Southern Cave");
			self:UpdateAgents(data, safePos.x, safePos.y, safePos.z, numAttackers, false);
		end
		
	elseif (self.Phase == 3) then
		
		-- get tank facing the cave
		-- Print("Phase", self.Phase, "Tank should face the Northern Cave");
		self:UpdateAgents(data, wPos.x, wPos.y, wPos.z, numAttackers, true);
		
	elseif (self.Phase == 4) then
		
		-- get tank into the cave when out of combat, when both charges are set
		-- tank is reverted to normal behaviour of following the owner around
		if (GetNumSpawnedCharges() < 2) then
			-- Print("Phase", self.Phase, "Tank should camp the Northern Cave");
			self:UpdateAgents(data, wPos.x, wPos.y, wPos.z, numAttackers, true);
		else
			local bSetPos = false;
			if (false == self.GrubbisDead) then
				-- Print("Phase", self.Phase, "Tank should wait in anticipation of Grubbis");
				local x,y,z = player:GetPosition();
				local grubbis = GetUnitsWithEntryNear(player, NPC_GRUBBIS, x, y, z, 20.0, false, true)[1];
				local chomper = GetUnitsWithEntryNear(player, NPC_CHOMPER, x, y, z, 20.0, false, true)[1];
				local grubbisAlive = grubbis and grubbis:IsAlive();
				local chomperAlive = chomper and chomper:IsAlive();
				if (grubbis and chomper) then
					if (false == (grubbisAlive or chomperAlive)) then
						self.GrubbisDead = true;
					end
					bSetPos = true
				end
				if (grubbisAlive) then numAttackers = numAttackers + 1; table.insert(data.attackers, grubbis); end
				if (chomperAlive) then numAttackers = numAttackers + 1; table.insert(data.attackers, chomper); end
			end
			self:UpdateAgents(data, wPos.x, wPos.y, wPos.z, numAttackers, true, bSetPos);
		end
		
	elseif (self.Phase == 5) then
		
		-- get tank into the cave when out of combat
		-- Print("Phase", self.Phase, "All should wait outside caves");
		self:UpdateAgents(data, safePos.x, safePos.y, safePos.z, numAttackers, false);
		
	end

end

function Gnomeregan.Blastmaster:OnEnd(hive, data)
	
	self.Phase       = 0;
	self.GrubbisDead = false;
	self:RestoreAgents(data);
	data.disablePull = nil;
	
end

local _losTbl = Encounter_MakeLOSTbl()
	.new 'EntranceRght' {-365.674, 49.2264, -156.509} {-353.682, 32.5599, -156.491}
	.new 'EntranceLeft' {-393.569, 33.2120, -154.776} {-367.121, 18.5819, -153.393}
	.new 'EntranceLefA' {-483.075, 44.9885, -156.501} {-493.391, 67.1573, -154.798}
	.new 'EntranceEvnt' {-480.682, 40.7545, -154.734} {-447.988, 35.9755, -154.743}
	.new 'EntranceEvnA' {-499.957, 90.9679, -154.025} {-511.345, 106.053, -154.743}
	-- .new 'EntranceEvnA' {-508.809, 71.0358, -154.799} {-512.036, 88.8923, -154.743}
	.new 'EntranceNext' {-499.403, 85.1052, -154.024} {-509.556, 69.6253, -154.799}
	.new 'EntranceNexA' {-497.760, 160.150, -154.699} {-493.593, 173.569, -154.697}
	.new 'EntranceFork' {-502.214, 155.491, -154.696} {-512.008, 124.440, -154.742}
	.new 'EntranceForA' {-488.865, 189.829, -155.687} {-484.08, 206.01, -161.987}
	.new 'EntranceDend' {-436.129, 134.157, -158.132} {-428.431, 159.432, -155.704}
	-- Dormitory
	.new 'DormEntrTopL' {-496.863, 161.709, -154.698} {-486.195, 152.569, -154.737}
	.new 'DormEntrTpLA' {-535.222, 216.262, -155.345} {-550.57, 222.874, -158.114}
	
	.new 'DormEntrTopC' {-540.55, 201.489, -155.241} {-550.247, 177.479, -155.238}
	.new 'DormEntrTpCA' {-585.315, 204.509, -165.693} {-604.872, 193.599, -172.004}
	
	.new 'DormEntTopC2' {-560.217, 222.13, -159.237} {-540.492, 213.789, -155.695}
	.new 'DormEntTpC2A' {-631.054, 155.699, -183.92} {-641.175, 139.693, -183.876}
	
	.new 'DormTopRoomM' {-627.235, 163.775, -181.358} {-616.157, 185.559, -176.285}
	.new 'DormTopRoomA' {-622.579, 138.051, -172.963} {-624.358, 150.628, -171.364}
	
	.new 'DormEntrBotL' {-499.418, 222.530, -173.433} {-483.857, 210.917, -162.627}
	.new 'DormEntrBot2' {-568.541, 159.109, -202.15} {-581.177, 142.17, -202.137}
	
	.new 'DormSludgeRm' {-536.652, 156.502, -193.74} {-527.629, 151.066, -193.74} -- from lower
	.new 'DormSludgeRA' {-623.462, 136.216, -183.884} {-641.89, 116.056, -183.875} -- from upper
	.new 'DormSludgeRB' {-514.082, 121.994, -207.892} {-501.207, 128.89, -208.932} -- reverse path
	-- Dormitory Small Rooms
	.new 'DormSludgRB1' {-596.319, 150.936, -197.376} {-584.391, 159.098, -202.137}
	.new 'DormSludgRB2' {-595.526, 117.233, -198.138} {-602.434, 126.103, -191.693}
	.new 'DormSludgRB3' {-594.703, 87.4169, -198.905} {-602.359, 95.2485, -191.763}
	.new 'DormSludgRB4' {-581.58, 59.8837, -197.241} {-593.095, 55.6048, -193.778}
	.new 'DormSludgRB5' {-549.235, 60.7422, -197.972} {-559.594, 51.6688, -189.937}
	.new 'DormSludgRU1' {-565.394, 41.2993, -181.147} {-570.874, 31.941, -172.468}
	.new 'DormSludgRU2' {-596.562, 39.5714, -179.253} {-615.12, 34.8023, -174.056}
	.new 'DormSludgRU3' {-613.279, 86.0382, -181.576} {-622.949, 66.3565, -172.582}
	-- Hall of Gears
	.new 'HallOfGears_' {-532.573, 118.726, -204.514} {-544.951, 127.012, -202.862}
	.new 'HallOfGearsA' {-451.363, 195.059, -207.907} {-439.311, 195.139, -207.906}
	.new 'HogTransSeg1' {-451.238, 190.936, -207.906} {-451.676, 173.751, -208.873}
	.new 'HogTransSeg2' {-453.711, 236.411, -207.906} {-447.136, 212.585, -207.906}
	.new 'HogTransSeg3' {-468.319, 268.256, -207.954} {-460.659, 251.569, -207.907}
	.new 'HogTransSgBt' {-438.058, 235.579, -211.532} {-430.673, 202.421, -211.54}
	.new 'HogTransSeg4' {-542.923, 354.057, -231.332} {-544.309, 337.815, -226.116}
	.new 'HogTransSg4A' {-570.915, 395.63, -230.6} {-555.065, 421.619, -230.602}
	-- Launch Bay Top
	-- Normal entrance to loop, first segment of the loop
	.new 'LbayTopLSeg1' {-522.73, 385.938, -231.679} {-523.048, 364.293, -231.678} -- from 1st entrance
	.new 'LbayTopLSg1A' {-584.889, 404.844, -230.601} {-603.8, 424.368, -230.601} -- ccw
	.new 'LbayTopLSg1B' {-480.218, 426.193, -230.601} {-481.567, 456.656, -230.602} -- cw
	-- Loop clockwise second segment (also contains the path down)
	.new 'LbayTopLSeg2' {-566.822, 400.322, -230.601} {-555.986, 379.863, -231.674} -- cw
	.new 'LbayTopLSg2A' {-654.785, 433.382, -230.622} {-644.054, 400.623, -232.574} -- from 2nd entrance
	.new 'LbayTopLSg2B' {-627.814, 478.163, -230.601} {-643.144, 491.555, -230.601} -- ccw
	-- Loop clockwise third segment
	.new 'LbayTopLSeg3' {-642.205, 454.226, -230.601} {-615.458, 442.84, -230.601} -- cw
	.new 'LbayTopLSg3A' {-641.418, 560.111, -230.601} {-627.847, 575.583, -230.601} -- ccw
	-- Loop clockwise fourth segment, adjacent to boss segment
	.new 'LbayTopLSeg4' {-651.028, 544.51, -230.601} {-646.116, 524.092, -230.601} -- cw
	.new 'LbayTopLSg4A' {-564.62, 611.332, -230.601} {-536.841, 592.221, -230.601} -- ccw
	-- Loop clockwise fifth segment, contains boss' bridge
	.new 'LbayTopLSeg5' {-582.239, 606.542, -230.601} {-597.505, 578.826, -230.601} -- cw
	.new 'LbayTopLSg5A' {-472.801, 579.258, -230.601} {-463.592, 554.463, -230.601} -- ccw
	-- Loop clockwise sixth segment, adjacent to boss segment
	.new 'LbayTopLSeg6' {-489.42, 592.846, -230.601} {-514.479, 587.085, -230.601} -- cw
	.new 'LbayTopLSg6A' {-444.583, 494.934, -230.601} {-462.476, 476.622, -230.601} -- ccw
	-- Loop clockwise seventh segment
	.new 'LbayTopLSeg7' {-443.274, 513.939, -230.601} {-457.726, 533.803, -230.601} -- cw
	.new 'LbayTopLSg7A' {-491.5, 415.312, -230.602} {-515.072, 413.079, -230.602} -- ccw
	-- Launch Bay bottom floor T-hall
	.new 'LbayBotCorr1' {-634.785, 365.408, -253.333} {-617.56, 365.557, -247.26} -- original
	.new 'LbayBotCor1A' {-727.014, 430.802, -273.062} {-746, 423.037, -273.063} -- from engi labs
	.new 'LbayBotCor1B' {-654.821, 407.313, -273.064} {-649.949, 426.631, -273.064} -- from launch bay bottom
	.new 'LbayBotCorr2' {-657.094, 396.256, -273.063} {-668.362, 383.779, -273.063}
	.new 'LbayBotCor2A' {-608.533, 472.213, -273.083} {-587.83, 477.345, -273.076}
	.new 'LbayBotLevel' {-625.461, 460.655, -273.061} {-640.589, 437.851, -273.064}
	.new 'LbayBotLeveA' {-638.722, 507.925, -273.063} {-648.506, 515.107, -273.062}
	-- End Transition
	.new 'EndTransSeg1' {-655.886, 507.529, -273.061} {-625.803, 517.096, -273.061} -- original
	.new 'EndTransSg1A' {-794.038, 540.99, -294.406} {-807.511, 527.833, -298.884} -- reverse
	.new 'EndTransSeg2' {-777.789, 558.142, -291.125} {-784.037, 545.168, -291.15}
	-- Engineering labs
	.new 'EngiLabsBotm' {-793.504, 340.344, -316.426} {-785.989, 328.165, -316.425} -- normal
	.new 'EngiLabsBotR' {-859.966, 415.376, -315.598} {-843.982, 433.852, -312.282} -- reverse
	-- Loop clockwise first segment, normal entrance
	.new 'EngiLabsSeg1' {-744.024, 423.983, -273.064} {-732.67, 435.253, -273.062} -- cw
	.new 'EngiLabsSg1A' {-782.597, 300.896, -272.596} {-798.745, 308.126, -272.596} -- ccw
	-- Loop clockwise second segment, has elevator and second entrance
	.new 'EngiLabsSeg2' {-789.775, 298.629, -272.598} {-802.062, 307.987, -272.598} -- 2nd entrance, cw
	.new 'EngiLabsSg2A' {-903.571, 318.141, -272.596} {-900.542, 334.933, -272.596} -- ccw
	-- Loop clockwise third segment, has boss
	.new 'EngiLabsSeg3' {-888.259, 299.231, -272.596} {-870.466, 293.775, -272.596} -- cw
	.new 'EngiLabsSg3A' {-842.33, 418.295, -272.596} {-816.86, 417.795, -272.596} -- ccw
	-- Loop clockwise fourth segment, last segment
	.new 'EngiLabsSeg4' {-889.93, 416.105, -272.596} {-897.04, 396.576, -272.596} -- cw
	.new 'EngiLabsSg4A' {-754.063, 421.779, -272.827} {-736.109, 434.752, -273.064} -- ccw
.endtbl();

local _areaTbl = Encounter_MakeAreaTbl(_losTbl)
	-- .new ('EntranceRght', SHAPE_POLYGON) {-369.149, 65.8552} {-358.711, 76.1337} {-358.563, 139.548} {-377.887, 132.478} {-380.839, 73.5181}
		-- ('EntranceRght', -154.734, 10)
	-- .new ('EntranceLeft', SHAPE_POLYGON) {-387.690, 48.7254} {-397.691, 57.5594} {-461.332, 49.4711} {-469.170, 29.9544} {-405.352, 29.9290}
		-- ('EntranceLeft', -154.793, 10)
	-- .new ('EntranceEvnt', SHAPE_POLYGON) {-464.682, 44.3998} {-502.434, 81.4365} {-543.863, 33.8118} {-558.17, -1.16476} {-523.69, -19.7411} {-471.315, 31.2503}
		-- ('EntranceEvnt', -154.743, 10)
	-- .new ('EntranceNext', SHAPE_POLYGON) {-512.964, 65.0225} {-516.145, 141.504} {-497.832, 158.483} {-489.433, 147.605} {-495.453, 75.4881}
		-- ('EntranceNext', -154.776, 10)
	-- .new ('EntranceNext', SHAPE_POLYGON) {-489.749, 147.869} {-502.231, 155.443} {-516.115, 141.59} {-516.52, 87.6571} {-496.187, 90.3592}
		-- ('EntranceNext', -154.776, 10)
	.new ('EntranceRght', SHAPE_POLYGON) {-334.33, 24.2761} {-358.373, 140.279} {-378.323, 133.2} {-384.041, 70.6401} ('EntranceRght', -154.734, 10)
	.new ('EntranceLeft', SHAPE_POLYGON) {-513.471, 9.87187} {-462.002, 66.5453} {-383.843, 69.7655} {-327.303, 5.15931} ('EntranceLeft', -154.793, 10)
	.new ('EntranceNext', SHAPE_POLYGON) {-489.749, 147.869} {-502.231, 155.443} {-570.171, 87.6571} {-496.187, 90.3592} ('EntranceNext', -154.776, 10)
	.new ('EntranceFork', SHAPE_POLYGON) {-490.466, 147.206} {-525.112, 173.32} {-500.045, 198.299} {-408.337, 188.127} {-414.24, 169.011}
		('EntranceFork', -154.741, 10)
	.new ('EntranceDend', SHAPE_POLYGON) {-429.817, 153.053} {-400.893, 102.22} {-437.415, 67.8135} {-482.322, 110.703} ('EntranceDend', -157.023, 15)
	.new ('EntranceEvnt', SHAPE_POLYGON) {-500.578, 134.752} {-413.716, 49.3857} {-519.727, -22.2177} {-558.353, -1.16564} ('EntranceEvnt', -154.49, 10)
	-- Dormitory
	.new ('DormEntrTopL', SHAPE_POLYGON) {-511.336, 166.714} {-529.785, 151.39} {-573.34, 169.559} {-526.03, 216.734} {-517.869, 205.877}
		('DormEntrTopL', -155.155, 10)
	.new ('DormEntrTopC', SHAPE_POLYGON) {-540.35, 202.416} {-531.194, 211.394} {-567.88, 243.154} {-578.396, 232.512} ('DormEntrTopC', -155.241, 10)
	.new ('DormEntTopC2', SHAPE_POLYGON) {-575.174, 235.846} {-640.583, 170.22} {-629.868, 159.644} {-562.894, 221.339} ('DormEntTopC2', -158.546, 25)
	-- WIP: Need Trigger
	.new ('DormTopRoom_', SHAPE_POLYGON) {-629.847, 159.693} {-619.074, 142.57} {-619.074, 112.9} {-646.437, 112.902} {-646.408, 155.788}
		('DormTopRoomM', -182.833, 5)
	.new ('DormEntrBotL', SHAPE_POLYGON) {-573.835, 169.76} {-573.582, 186.138} {-520.426, 239.864} {-497.02, 234.134} {-486.554, 225.213} {-482.583, 196.357}
		{-528.084, 150.61} ('DormEntrBotL', -193.74, 10)
	-- WIP: Need Trigger
	.new ('DormSludgeRm', SHAPE_POLYGON) {-530.689, 145.33} {-532.896, 62.4914} {-596.31, 64.7623} {-597.693, 158.437} ('DormSludgeRm', -202.151, 10)
	-- Dormitory Small Rooms
	.new ('DormSludgRB1', SHAPE_POLYGON) {-602.046, 135.081} {-625.183, 135.09} {-625.185, 159.048} {-602.081, 159.048} ('DormSludgRB1', -199.661, 5)
	.new ('DormSludgRB2', SHAPE_POLYGON) {-611.257, 124.933} {-648.385, 124.923} {-648.496, 90.3551} {-611.256, 90.3549} ('DormSludgRB2', -199.655, 10)
	.new ('DormSludgRB3', SHAPE_POLYGON) {-611.256, 83.9632} {-648.355, 83.9643} {-648.479, 49.3867} {-611.256, 49.3869} ('DormSludgRB3', -199.655, 10)
	.new ('DormSludgRB4', SHAPE_POLYGON) {-562.137, 51.4158} {-560.864, 30.2082} {-584.005, 25.8398} {-584.004, 52.3324} ('DormSludgRB4', -198.31, 5)
	.new ('DormSludgRB5', SHAPE_POLYGON) {-531.47, 53.1685} {-531.457, 26.6906} {-554.269, 30.5367} {-554.278, 52.7488} ('DormSludgRB5', -198.845, 5)
	.new ('DormSludgRU1', SHAPE_POLYGON) {-567.332, 30.8933} {-562.759, 8.89044} {-539.045, 8.83152} {-539.236, 31.5967} ('DormSludgRU1', -179.741, 5)
	.new ('DormSludgRU2', SHAPE_POLYGON) {-577.188, 30.0155} {-582.157, 8.86148} {-605.696, 8.8167} {-605.831, 31.5462} ('DormSludgRU2', -179.684, 5)
	.new ('DormSludgRU3', SHAPE_POLYGON) {-628.813, 99.5491} {-665.971, 99.549} {-666.024, 64.9726} {-628.814, 64.9714} ('DormSludgRU3', -173.2, 11)
	-- Hall of Gears
	.new ('HallOfGears_', SHAPE_POLYGON) {-530.756, 145.574} {-533.089, 61.9363} {-464.301, 29.8771} {-400.455, 33.9235} {-364.548, 77.7575}
		{-362.023, 145.629} {-400.779, 183.259} {-473.77, 184.07} ('HallOfGears_', -202.151, 10)
	-- .new ('HogTransSeg1', SHAPE_POLYGON) {-454.79, 188.023} {-454.203, 240.673} {-421.964, 248.946} {-414.267, 188.024} ('HogTransSeg1', -207.908, 10)
	-- .new ('HogTransSeg1', SHAPE_POLYGON) {-454.791, 188.024} {-438.061, 190.699} {-442.424, 246.294} {-455.167, 242.834} ('HogTransSeg1', -207.908, 10)
	-- .new ('HogTransSeg2', SHAPE_POLYGON) {-454.268, 236.41} {-478.734, 254.713} {-478.014, 270.941} {-468.184, 270.683} {-448.397, 262.413}
		-- {-438.643, 236.203} ('HogTransSeg2', -207.906, 10)
	-- .new ('HogTransSeg3', SHAPE_POLYGON) {-468.145, 254.949} {-516.5, 255.021} {-554.715, 272.75} {-569.624, 311.688} {-581.135, 358.037}
		-- {-516.565, 356.905} {-464.004, 288.608} ('HogTransSeg3', -207.989, 30)
	-- .new ('HogTransSgBt', SHAPE_POLYGON) {-473.77, 184.069} {-375.104, 160.938} {-433.631, 275.355} {-469.815, 290.758} {-514.676, 290.758}
		-- {-516.5, 255.021} ('HogTransSgBt', -207.908, 10)
	.new ('HogTransSeg4', SHAPE_POLYGON) {-516.566, 356.906} {-581.425, 358.039} {-580.465, 383.724} {-516.116, 382.606} ('HogTransSeg4', -231.679, 10)
	-- Launch Bay Top
	.new ('LbayTopLSeg1', SHAPE_POLYGON) {-516.116, 382.603} {-489.74, 412.501} {-507.09, 440.776} {-578.076, 431.965} {-585.142, 399.02}
		{-580.976, 383.737} ('LbayTopLSeg1', -231.698, 10)
	.new ('LbayTopLSeg2', SHAPE_POLYGON) {-585.136, 399.02} {-628.118, 424.515} {-648.8, 452.008} {-619.297, 468.941} {-573.542, 430.812}
		('LbayTopLSeg2', -230.601, 10)
	.new ('LbayTopLSeg3', SHAPE_POLYGON) {-645.575, 447.255} {-664.03, 506.744} {-653.315, 548.417} {-622.07, 535.904} {-617.162, 465.082}
		('LbayTopLSeg3', -230.601, 10)
	.new ('LbayTopLSeg4', SHAPE_POLYGON) {-655.17, 542.858} {-619.756, 594.553} {-580.808, 611.957} {-571.092, 579.393} {-623.746, 530.422}
		('LbayTopLSeg4', -230.601, 10)
	.new ('LbayTopLSeg5', SHAPE_POLYGON) {-586.292, 609.833} {-523.857, 614.45} {-486.093, 594.855} {-505.267, 566.858} {-577.554, 576.451}
		('LbayTopLSeg5', -230.601, 10)
	.new ('LbayTopLSeg6', SHAPE_POLYGON) {-492.102, 598.34} {-448.581, 551.962} {-440.153, 509.833} {-474.262, 507.571} {-509.443, 569.447}
		('LbayTopLSeg6', -230.601, 10)
	.new ('LbayTopLSeg7', SHAPE_POLYGON) {-440.769, 514.641} {-450.584, 453.734} {-478.001, 421.438} {-501.002, 446.471} {-475.303, 514.896}
		('LbayTopLSeg7', -230.601, 10)
	-- Launch Bay bottom
	.new ('LbayBotCorr1', SHAPE_POLYGON) --[[{-653.057, 392.308}]] {-646.625, 396.755} {-680.165, 440.659} {-710.083, 467.633} {-730.903, 451.6}
		{-673.853, 376.347} ('LbayBotCorr1', -273.061, 10)
	.new ('LbayBotCorr2', SHAPE_POLYGON) {-653.003, 392.348} {-588.828, 444.672} {-619.669, 486.806} {-683.078, 438.607} ('LbayBotCorr2', -273.063, 10)
	.new ('LbayBotLevel', SHAPE_POLYGON) {-630.159, 469.534} {-615.902, 537.735} {-565.56, 576.068} {-504.255, 559.998} {-478.778, 503.236}
		{-506.516, 447.852} {-568.769, 434.408} {-605.948, 437.508} ('LbayBotLevel', -273.062, 10)
	.new ('EndTransSeg1', SHAPE_POLYGON, true) {-616.136, 474.017} {-783.228, 555.229} {-764.29, 568.956} {-756.388, 555.752} {-743.554, 546.124}
		{-658.935, 525.469} {-645.972, 549.109} {-595.571, 562.237} ('EndTransSeg1', -273.064, 30)
	.new ('EndTransSeg2', SHAPE_POLYGON, true) {-781.255, 542.76} {-771.451, 609.889} {-762.716, 605.257} {-766.965, 586.704} {-764.899, 569.898}
		{-758.606, 559.636} ('EndTransSeg2', -291.15, 30)
	-- Engineering labs
	.new ('EngiLabsBotm', SHAPE_POLYGON) {-779.996, 330.52} {-775.054, 369.641} {-805.353, 409.345} {-844.04, 414.552} {-883.883, 384.315}
		{-889.492, 345.282} {-859.249, 305.612} {-820.178, 299.924} ('EngiLabsBotR', -316.431, 10)
	.new ('EngiLabsSeg1', SHAPE_POLYGON) {-758.623, 422.245} {-771.615, 410.877} {-779.302, 328.778} {-755.987, 328.912} {-735.334, 424.396}
		('EngiLabsSeg1', -272.581, 10)
	.new ('EngiLabsSeg2', SHAPE_POLYGON) {-782.057, 332.442} {-755.987, 328.912} {-765.895, 268.973} {-860.864, 281.184} {-857.287, 307.466}
		('EngiLabsSeg2', -272.596, 10)
	.new ('EngiLabsSeg3', SHAPE_POLYGON) --[[{-857.31, 307.468}]] {-860.866, 281.179} {-893.684, 292.282} {-907.105, 301.231} {-912.165, 313.463}
		{-913.496, 350.095} {-908.671, 385.779} {-897.178, 419.888} {-886.418, 434.188} {-873.043, 436.212} {-843.075, 435.898} {-842.975, 412.22}
		('EngiLabsSeg3', -272.596, 10)
	.new ('EngiLabsSeg4', SHAPE_POLYGON) {-842.972, 412.244} {-839.412, 438.616} {-758.623, 422.247} {-771.614, 410.878} {-807.26, 407.617}
		('EngiLabsSeg4', -272.596, 10)
.endtbl();

local NPC_RANGED_LIST = Encounter_NewRangedList();
function NPC_RANGED_LIST.IsRanged() return true; end

local function TriggerCircle_DormUpperNorm(unit, hive, data)
	Print("TriggerCircle_DormUpperNorm");
	Encounter_SetAreaLosPos("DormEntrBotL", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrBotL");
	Encounter_SetAreaLosPos("DormSludgeRm", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormSludgeRm");
	-- upper path rooms will have alt pts on nrm path
	Encounter_SetAreaLosPos("DormTopRoom_", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormTopRoomA");
	Encounter_SetAreaLosPos("DormEntrTopL", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrTpLA");
	Encounter_SetAreaLosPos("DormEntrTopC", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrTpCA");
	Encounter_SetAreaLosPos("DormEntTopC2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntTpC2A");
end

local function TriggerCircle_DormUpperAltr(unit, hive, data)
	Print("TriggerCircle_DormUpperAltr");
	Encounter_SetAreaLosPos("DormEntrBotL", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrBot2");
	Encounter_SetAreaLosPos("DormSludgeRm", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormSludgeRA");
	-- upper path rooms will have normal pts on alt path
	Encounter_SetAreaLosPos("DormTopRoom_", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormTopRoomM");
	Encounter_SetAreaLosPos("DormEntrTopL", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrTopL");
	Encounter_SetAreaLosPos("DormEntrTopC", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrTopC");
	Encounter_SetAreaLosPos("DormEntTopC2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntTopC2");
end

local function TriggerCircle_LaunchBayTopA(unit, hive, data)
	Print("TriggerCircle_LaunchBayTopA");
	-- go clockwise
	if (not data.dungeon.TC_LaunchBayTopA_enabled) then
		return;
	end
	Encounter_SetAreaLosPos("LbayTopLSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg1B");
	Encounter_SetAreaLosPos("LbayTopLSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg2");
	Encounter_SetAreaLosPos("LbayTopLSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg3");
	Encounter_SetAreaLosPos("LbayTopLSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg4");
	Encounter_SetAreaLosPos("LbayTopLSeg5", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg5");
	Encounter_SetAreaLosPos("LbayTopLSeg6", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg6");
	Encounter_SetAreaLosPos("LbayTopLSeg7", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg7");
end

local function TriggerCircle_LaunchBayTopB(unit, hive, data)
	Print("TriggerCircle_LaunchBayTopB");
	-- go counterclockwise
	if (not data.dungeon.TC_LaunchBayTopB_enabled) then
		return;
	end
	Encounter_SetAreaLosPos("LbayTopLSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg1A");
	Encounter_SetAreaLosPos("LbayTopLSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg2B");
	Encounter_SetAreaLosPos("LbayTopLSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg3A");
	Encounter_SetAreaLosPos("LbayTopLSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg4A");
	Encounter_SetAreaLosPos("LbayTopLSeg5", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg5A");
	Encounter_SetAreaLosPos("LbayTopLSeg6", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg6A");
	Encounter_SetAreaLosPos("LbayTopLSeg7", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg7A");
end

local function TriggerCircle_LaunchBayTopC(unit, hive, data)
	Print("TriggerCircle_LaunchBayTopC");
	-- go clockwise
	if (not data.dungeon.TC_LaunchBayTopC_enabled) then
		return;
	end
	Encounter_SetAreaLosPos("LbayTopLSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg1B");
	Encounter_SetAreaLosPos("LbayTopLSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg2");
	Encounter_SetAreaLosPos("LbayTopLSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg3");
	Encounter_SetAreaLosPos("LbayTopLSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg4");
	Encounter_SetAreaLosPos("LbayTopLSeg5", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg5");
	Encounter_SetAreaLosPos("LbayTopLSeg6", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg6");
	Encounter_SetAreaLosPos("LbayTopLSeg7", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSeg7");
end

local function TriggerCircle_LaunchBayTopD(unit, hive, data)
	Print("TriggerCircle_LaunchBayTopD");
	-- go counterclockwise
	if (not data.dungeon.TC_LaunchBayTopD_enabled) then
		return;
	end
	Encounter_SetAreaLosPos("LbayTopLSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg1A");
	Encounter_SetAreaLosPos("LbayTopLSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg2B");
	Encounter_SetAreaLosPos("LbayTopLSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg3A");
	Encounter_SetAreaLosPos("LbayTopLSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg4A");
	Encounter_SetAreaLosPos("LbayTopLSeg5", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg5A");
	Encounter_SetAreaLosPos("LbayTopLSeg6", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg6A");
	Encounter_SetAreaLosPos("LbayTopLSeg7", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg7A");
end

local function TriggerCircle_EndTransPass1(unit, hive, data)
	Print("TriggerCircle_EndTransPass1");
	Encounter_SetAreaLosPos("EndTransSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EndTransSg1A");
	Encounter_SetAreaLosPos("EngiLabsBotm", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsBotm");
	Encounter_SetAreaLosPos("LbayBotLevel", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotLeveA");
	Encounter_SetAreaLosPos("LbayBotCorr2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCor2A");
	Encounter_SetAreaLosPos("LbayBotCorr1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCor1B");
	data.dungeon.TC_EngiLabsMain1_enabled = true;
	data.dungeon.TC_EngiLabsMain2_enabled = true;
	data.dungeon.TC_EngiLabsMain3_enabled = false;
	data.dungeon.TC_EngiLabsMain4_enabled = false;
end

local function TriggerCircle_EndTransPass2(unit, hive, data)
	Print("TriggerCircle_EndTransPass2");
	Encounter_SetAreaLosPos("EndTransSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EndTransSeg1");
	Encounter_SetAreaLosPos("EngiLabsBotm", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsBotR");
	Encounter_SetAreaLosPos("LbayBotLevel", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotLevel");
	Encounter_SetAreaLosPos("LbayBotCorr2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCorr2");
	Encounter_SetAreaLosPos("LbayBotCorr1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCor1A");
	data.dungeon.TC_EngiLabsMain1_enabled = false;
	data.dungeon.TC_EngiLabsMain2_enabled = false;
	data.dungeon.TC_EngiLabsMain3_enabled = true;
	data.dungeon.TC_EngiLabsMain4_enabled = true;
end

local function TriggerCircle_EngiLabsMain1(unit, hive, data)
	Print("TriggerCircle_EngiLabsMain1");
	if (not data.dungeon.TC_EngiLabsMain1_enabled) then return; end
	Encounter_SetAreaLosPos("EngiLabsSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg1");
	Encounter_SetAreaLosPos("EngiLabsSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg2");
	Encounter_SetAreaLosPos("EngiLabsSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg3");
	Encounter_SetAreaLosPos("EngiLabsSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg4");
end

local function TriggerCircle_EngiLabsMain2(unit, hive, data)
	Print("TriggerCircle_EngiLabsMain2");
	if (not data.dungeon.TC_EngiLabsMain2_enabled) then return; end
	Encounter_SetAreaLosPos("EngiLabsSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg1A");
	Encounter_SetAreaLosPos("EngiLabsSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg2A");
	Encounter_SetAreaLosPos("EngiLabsSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg3A");
	Encounter_SetAreaLosPos("EngiLabsSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg4A");
end

local function TriggerCircle_EngiLabsMain3(unit, hive, data)
	Print("TriggerCircle_EngiLabsMain3");
	if (not data.dungeon.TC_EngiLabsMain3_enabled) then return; end
	Encounter_SetAreaLosPos("EngiLabsSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg1");
	Encounter_SetAreaLosPos("EngiLabsSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg2");
	Encounter_SetAreaLosPos("EngiLabsSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg3");
	Encounter_SetAreaLosPos("EngiLabsSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSeg4");
end

local function TriggerCircle_EngiLabsMain4(unit, hive, data)
	Print("TriggerCircle_EngiLabsMain4");
	if (not data.dungeon.TC_EngiLabsMain4_enabled) then return; end
	Encounter_SetAreaLosPos("EngiLabsSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg1A");
	Encounter_SetAreaLosPos("EngiLabsSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg2A");
	Encounter_SetAreaLosPos("EngiLabsSeg3", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg3A");
	Encounter_SetAreaLosPos("EngiLabsSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsSg4A");
end

local function TriggerCircle_BackdoorEntra(unit, hive, data)
	Print("TriggerCircle_BackdoorEntra");
	
	-- Switch to backdoor triggers
	data.dungeon.TC_LaunchBayTopA_enabled = false;
	data.dungeon.TC_LaunchBayTopB_enabled = false;
	data.dungeon.TC_LaunchBayTopC_enabled = true;
	data.dungeon.TC_LaunchBayTopD_enabled = true;
	
	data.dungeon.TC_EngiLabsMain1_enabled = false;
	data.dungeon.TC_EngiLabsMain2_enabled = false;
	data.dungeon.TC_EngiLabsMain3_enabled = true;
	data.dungeon.TC_EngiLabsMain4_enabled = true;
	
	-- default is reverse, other way is handled with triggers TriggerCircle_EndTransPass1 and TriggerCircle_EndTransPass2
	-- which are located in the corridor connecting launch bay and engineering labs next to each other
	Encounter_SetAreaLosPos("EndTransSeg1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EndTransSg1A");
	Encounter_SetAreaLosPos("EngiLabsBotm", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EngiLabsBotm");
	Encounter_SetAreaLosPos("LbayBotLevel", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotLeveA");
	Encounter_SetAreaLosPos("LbayBotCorr2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCor2A");
	Encounter_SetAreaLosPos("LbayBotCorr1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCor1B");
	
	-- Launch bay loop entrance change
	Encounter_SetAreaLosPos("LbayTopLSeg2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayTopLSg2A");
	
	-- Engineering labs approach is covered by TriggerCircle_EndTransPass1/2 triggers
	-- This covers launch bay approach
	Encounter_SetAreaLosPos("LbayBotCorr1", data.dungeon.AreaTbl, data.dungeon.LosTbl, "LbayBotCor1B");
	
	-- set up Dormitory
	Encounter_SetAreaLosPos("DormSludgeRm", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormSludgeRB");
	Encounter_SetAreaLosPos("DormEntrBotL", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrBot2");
	Encounter_SetAreaLosPos("EntranceFork", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceForA");
	Encounter_SetAreaLosPos("DormEntrTopL", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrTpLA");
	Encounter_SetAreaLosPos("DormEntrTopC", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntrTpCA");
	Encounter_SetAreaLosPos("DormEntTopC2", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormEntTpC2A");
	Encounter_SetAreaLosPos("DormTopRoom_", data.dungeon.AreaTbl, data.dungeon.LosTbl, "DormTopRoomA");
	
	-- set static things to default to reverse path
	Encounter_SetAreaLosPos("HogTransSeg4", data.dungeon.AreaTbl, data.dungeon.LosTbl, "HogTransSg4A");
	Encounter_SetAreaLosPos("HallOfGears_", data.dungeon.AreaTbl, data.dungeon.LosTbl, "HallOfGearsA");
	Encounter_SetAreaLosPos("EntranceLeft", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceLefA");
	Encounter_SetAreaLosPos("EntranceEvnt", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceEvnA");
	Encounter_SetAreaLosPos("EntranceNext", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceNexA");
	
end

Gnomeregan.triggers = {
	Encounter_NewTriggerCircle("DormUpperNorm", -495.695, 194.592, -155.236,10,10, TriggerCircle_DormUpperNorm),
	Encounter_NewTriggerCircle("DormUpperAltr", -519.400, 171.007, -155.236,10,10, TriggerCircle_DormUpperAltr),
	
	Encounter_NewTriggerCircle("LaunchBayTopA", -560.466, 412.614, -230.600,9.5,10, TriggerCircle_LaunchBayTopA),
	Encounter_NewTriggerCircle("LaunchBayTopB", -512.954, 416.820, -230.600,24,10, TriggerCircle_LaunchBayTopB),
	Encounter_NewTriggerCircle("LaunchBayTopC", -631.553, 458.818, -230.601,7,10, TriggerCircle_LaunchBayTopC),
	Encounter_NewTriggerCircle("LaunchBayTopD", -583.504, 418.043, -230.601,8,10, TriggerCircle_LaunchBayTopD),
	
	Encounter_NewTriggerCircle("EndTransPass1", -743.957, 424.935, -273.064,10,10, TriggerCircle_EndTransPass1),
	Encounter_NewTriggerCircle("EndTransPass2", -728.883, 437.020, -273.063,10,10, TriggerCircle_EndTransPass2),
	
	Encounter_NewTriggerCircle("EngiLabsMain1", -758.898, 398.291, -272.580,6,10, TriggerCircle_EngiLabsMain1),
	Encounter_NewTriggerCircle("EngiLabsMain2", -773.492, 418.194, -272.580,6,10, TriggerCircle_EngiLabsMain2),
	Encounter_NewTriggerCircle("EngiLabsMain3", -794.704, 283.228, -272.598,6,10, TriggerCircle_EngiLabsMain3),
	Encounter_NewTriggerCircle("EngiLabsMain4", -770.964, 301.264, -272.598,6,10, TriggerCircle_EngiLabsMain4),
	
	Encounter_NewTriggerCircle("BackdoorEntra", -749.004, 2.74334, -252.218,10,10, TriggerCircle_BackdoorEntra),
};

t_dungeons[90].encounters = {
	-- {name = "Mobile Alert System", entry = 7849, 
	{name = "Grubbis", script = Gnomeregan.Blastmaster, test = Gnomeregan.Blastmaster.Test},
	{name = "Viscous Fallout"},
	{name = "Electrocutioner 6000", tpos = {-552.048, 502.902, -216.727}, rchrpos = {x=-545.596, y=528.996, z=-216.279, melee = "ignore"}, healmax = true},
	{name = "Crowd Pummeler 9-60", tpos = {-902.155, 361.340, -272.596}, enemyPrio = {[7849] = 10}},
	{name = "Mekgineer Thermaplugg", script = Gnomeregan.Mekgineer, tpos = {-531.448, 670.266, -325.268}, tankswap = true},
	OnLoad = Gnomeregan_OnLoad,
	Ids =
	{
		Blastmaster      = nil,
		ExplosiveCharges = nil, -- order is random!
		CaveInSouth      = nil,
		CaveInNorth      = nil,
	},
	{
		name               = "Global",
		test               = function() return true; end,
		UseLosBreakForPull = true,
		noboss             = true,
		enemyPrio = {
			[7849] = 10, -- Mobile Alert System
		},
	},
	
	TC_LaunchBayTopA_enabled = true,
	TC_LaunchBayTopB_enabled = true,
	TC_LaunchBayTopC_enabled = false,
	TC_LaunchBayTopD_enabled = false,
	
	TC_EngiLabsMain1_enabled = false,
	TC_EngiLabsMain2_enabled = false,
	TC_EngiLabsMain3_enabled = true,
	TC_EngiLabsMain4_enabled = true,
};

Gnomeregan.encounters.LosTbl    = _losTbl;
Gnomeregan.encounters.AreaTbl   = _areaTbl;
Gnomeregan.encounters.RangedTbl = NPC_RANGED_LIST;
