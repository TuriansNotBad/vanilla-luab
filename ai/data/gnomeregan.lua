
-----------------------------------------------------------------------------------------------
-- When going from Workshop Key route tank is very likely to pick the wrong pull direction
-- when just entering the Engineering labs, pulling unintionally other mobs and likely wiping.
-- Best to face pull.

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
		{-426.959, 193.152, -211.545, -1000, 2}, -- 1
		{-428.939, 238.553, -211.544, -1000, 2}, -- 2
		{-441.35, 266.426, -211.542, -1000, 2}, -- 3
		{-468.505, 278.532, -211.541, -1000, 2}, -- 4
		{-515.373, 280.508, -211.543, -1000, 2}, -- 5
		{-534.135, 291.969, -211.547, -1000, 2}, -- 6
		{-538.977, 301.984, -213.754, -1000, 2}, -- 7
		{-540.254, 308.432, -216.979, -1000, 2}, -- 8
		{-540.638, 311.533, -216.972, -1000, 2}, -- 9
		{-540.124, 355.145, -231.405, -1000, 2}, -- 10
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

function Gnomeregan.Blastmaster:UpdateAgents(data, x, y, z, numAttackers, forTank)
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
local NPC_GRUBBIS             = 7361;
local NPC_CHOMPER             = 6215;
	
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
				end
				if (grubbisAlive) then numAttackers = numAttackers + 1; table.insert(data.attackers, grubbis); end
				if (chomperAlive) then numAttackers = numAttackers + 1; table.insert(data.attackers, chomper); end
			end
			self:UpdateAgents(data, wPos.x, wPos.y, wPos.z, numAttackers, true);
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

t_dungeons[90].encounters = {
	{name = "Grubbis", script = Gnomeregan.Blastmaster, test = Gnomeregan.Blastmaster.Test},
	-- {name = "Grubbis"},
	{name = "Viscous Fallout"},
	{name = "Electrocutioner 6000", tpos = {-552.048, 502.902, -216.727}, rchrpos = {x=-545.596, y=528.996, z=-216.279, melee = "ignore"}, healmax = true},
	{name = "Crowd Pummeler 9-60", tpos = {-902.155, 361.340, -272.596}},
	{name = "Mekgineer Thermaplugg", script = Gnomeregan.Mekgineer, tpos = {-531.448, 670.266, -325.268}, tankswap = true},
	OnLoad = Gnomeregan_OnLoad,
	Ids =
	{
		Blastmaster      = nil,
		ExplosiveCharges = nil, -- order is random!
		CaveInSouth      = nil,
		CaveInNorth      = nil,
	},
};
