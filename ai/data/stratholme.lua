
import 'ai/common_encounter.lua'

t_dungeons[329] = {
	-- Line 1 Entrance to Zealous
	{
		{3394.77, -3378.6, 142.705, -1000, 2}, -- 1
		{3450.71, -3380.85, 140.468, -1000, 2}, -- 2
		{3535.23, -3382.8, 132.377, -1000, 2}, -- 3
		{3557.25, -3342.17, 129.241, -1000, 2}, -- 4
		{3577.04, -3335.2, 128.471, -1000, 2}, -- 5
		{3650.06, -3330.76, 123.658, -1000, 2}, -- 6
		{3677.49, -3306.66, 126.736, -1000, 2}, -- 7
		{3694.72, -3251.12, 126.889, -1000, 2}, -- 8
		{3675.58, -3198.58, 126.336, -1000, 2}, -- 9
		{3663.27, -3161.38, 127.679, -1000, 2}, -- 10
		{3655.02, -3149.81, 134.781, -1000, 2}, -- 11
		{3640.69, -3128.82, 134.781, -1000, 2}, -- 12
		{3651.52, -3120.67, 134.781, -1000, 2}, -- 13
		{3645.38, -3108.08, 134.117, -1000, 2}, -- 14
		{3652.15, -3095.86, 134.117, -1000, 2}, -- 15
		{3642.26, -3082.54, 134.12, -1000, 2}, -- 16
		{3605.4, -3102.62, 134.12, -1000, 2}, -- 17
		{3621.1, -3126.24, 135.664, -1000, 2}, -- 18
	},
	-- Line 2 Zealous to Wiley
	{
		{3598.28, -3094.3, 135.659, -1000, 2}, -- 1
		{3565.7, -3047.97, 135.667, -1000, 2}, -- 2
		{3548.53, -3019.77, 125.001, -1000, 2}, -- 3
		{3585.58, -2991.83, 125.001, -1000, 2}, -- 4
		{3562.52, -2977.65, 125.001, -1000, 2}, -- 5
		{3544.21, -2980.19, 125.001, -1000, 2}, -- 6
		{3533.94, -2962.77, 125.001, -1000, 2}, -- 7
		{3571.15, -2938.61, 125.001, -1000, 2}, -- 8
	},
	-- Line 3 Wiley to Archivist
	{
		{3582.64, -3050.62, 134.997, -1000, 2}, -- 1
		{3546.08, -3075.26, 134.997, -1000, 2}, -- 2
		{3532.5, -3054.61, 134.997, -1000, 2}, -- 3
		{3492.51, -3081.28, 134.997, -1000, 2}, -- 4
		{3480.17, -3062.36, 135.002, -1000, 2}, -- 5
		{3444.65, -3086.35, 135.003, -1000, 2}, -- 6
		{3457.23, -3103.45, 136.544, -1000, 2}, -- 7
	},
	-- Line 4 Last live boss room
	{
		{3439.88, -3079.22, 135.003, -1000, 2}, -- 1
		{3437.01, -3075.07, 136.542, -1000, 2}, -- 2
		{3413.88, -3042.39, 136.53, -1000, 2}, -- 3
	},
	-- Line 5 Street loop
	{
		{3663.89, -3341.3, 124.257, -1000, 2}, -- 1
		{3707.01, -3414.44, 131.949, -1000, 2}, -- 2
		{3719.32, -3459.33, 129.729, -1000, 2}, -- 3
		{3706.28, -3484.53, 129.701, -1000, 2}, -- 4
		{3669.83, -3488.98, 136.106, -1000, 2}, -- 5
		{3610.97, -3489.79, 136.44, -1000, 2}, -- 6
		{3573.53, -3452.62, 135.936, -1000, 2}, -- 7
		{3554.21, -3432.99, 135.88, -1000, 2}, -- 8
		{3535.05, -3414.32, 134.461, -1000, 2}, -- 9
	},
	-- Line 6 Street left dead end
	{
		{3394.62, -3376.68, 142.706, -1000, 2}, -- 1
		{3526.95, -3379.12, 132.695, -1000, 2}, -- 2
		{3541.12, -3330.62, 129.422, -1000, 2}, -- 3
		{3472.27, -3302.17, 132.266, -1000, 2}, -- 4
	},
	-- Line 7 Elder's Square rhs
	{
		{3650.58, -3529.63, 137.457, -1000, 2}, -- 1
		{3651.76, -3609.55, 137.123, -1000, 2}, -- 2
		{3640.54, -3650.48, 138.749, -1000, 2}, -- 3
	},
	-- Line 8 Elder's Square lhs
	{
		{3652.02, -3530.35, 137.547, -1000, 2}, -- 1
		{3670.26, -3584.64, 136.914, -1000, 2}, -- 2
		{3713.61, -3613.03, 141.745, -1000, 2}, -- 3
	},
};

local Stratholme = t_dungeons[329];

Stratholme.Global = {
	key = "Stratholme.Global.OldRole",
};

local _losTbl = Encounter_MakeLOSTbl()
	-- Streets
	.new 'FrasCornerSt' {3536.70, -3365.60, 132.1540} {3533.40, -3368.50, 132.5660}
	.new 'EntrancePull' {3396.70, -3363.10, 142.9660} {3396.70, -3395.90, 143.1640}
	.new '1stCrossroad' {3497.76, -3358.48, 136.8160} {3455.17, -3371.68, 139.9780}
.endtbl();

local _areaTbl = Encounter_MakeAreaTbl(_losTbl)
	-- Streets
	.new ('FrasCornerSt', SHAPE_POLYGON) {3526.60, -3344.00} {3526.60, -3290.00} {3470.00, -3290.00} {3470.00, -3344.00} ('FrasCornerSt', 132.154, 100)
	.new ('EntrancePull', SHAPE_POLYGON) {3398.88, -3363.11} {3398.86, -3395.90} {3525.94, -3420.83} {3523.92, -3364.31} ('EntrancePull', 142.966, 100)
	.new ('1stCrossroad', SHAPE_POLYGON) {3519.10, -3296.82} {3519.10, -3430.76} {3594.90, -3430.76} {3594.90, -3296.82} ('1stCrossroad', 136.816, 100)
.endtbl();

local NPC_EYE_OF_NAXXRAMAS = 10411;

local NPC_RANGED_LIST = Encounter_NewRangedList();
function NPC_RANGED_LIST.IsRanged() return true; end

Stratholme.encounters = {
	{
		name               = "Global",
		test               = function() return true; end,
		script             = Stratholme.Global,
		UseLosBreakForPull = true,
		noboss             = true,
		enemyPrio = {
			[NPC_EYE_OF_NAXXRAMAS] = 10,
		},
	},
};

Stratholme.encounters.LosTbl    = _losTbl;
Stratholme.encounters.AreaTbl   = _areaTbl;
Stratholme.encounters.RangedTbl = NPC_RANGED_LIST;
