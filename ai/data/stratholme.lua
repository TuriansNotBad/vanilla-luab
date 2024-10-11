
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
	-- Line 9 Scarlet small room before Archivist
	{
		{3468.46, -3081.59, 135.003, -1000, 2}, -- 1
		{3476.87, -3093.84, 136.543, -1000, 2}, -- 2
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
	.new 'EntrancePAlt' {3527.37, -3364.24, 133.4180} {3540.34, -3368.43, 132.1520}
	.new '1stCrossroad' {3497.76, -3358.48, 136.8160} {3455.17, -3371.68, 139.9780}
	.new '1stCrossRatG' {3609.46, -3327.48, 124.2180} {3615.95, -3335.59, 123.6840}
	.new '1stCrossSqrG' {3555.17, -3429.08, 136.1170} {3554.41, -3433.65, 135.9090}
	.new 'FountSquareA' {3713.16, -3459.36, 129.9300} {3717.32, -3450.30, 129.4680}
	.new 'FountSquareB' {3640.38, -3588.68, 138.0750} {3634.15, -3606.43, 137.9140}
	.new 'FountSquareC' {3575.27, -3481.93, 135.8610} {3572.83, -3455.63, 135.8950}
	.new 'PScarletGate' {3646.09, -3319.28, 124.4530} {3628.67, -3336.75, 123.1940}
	.new 'NorthStreetA' {3639.59, -3349.99, 125.6590} {3625.28, -3333.34, 123.1100}
	.new 'NorthStreetB' {3706.86, -3449.91, 130.5530} {3725.49, -3470.54, 129.9210}
	.new 'EntranceBSqA' {3668.25, -3519.26, 137.3280} {3665.30, -3503.61, 136.8150}
	.new 'EntranceBSqB' {3662.89, -3643.06, 138.4710} {3644.06, -3653.92, 138.7370}
	-- Scarlet Areas
	.new 'ScarletSquar' {3675.81, -3260.67, 127.7930} {3697.93, -3277.45, 128.6900}
	.new 'ScarletHall1' {3640.84, -3105.13, 134.1170} {3635.94, -3112.85, 134.1170}
	.new 'ScarletPillr' {3619.45, -3092.81, 134.1220} {3629.28, -3085.23, 134.1220}
	.new 'ScarletCann1' {3578.17, -3052.12, 134.9980} {3583.04, -3072.14, 135.6650}
	.new 'ScarletCann2' {3564.83, -3001.58, 125.0020} {3554.29, -3013.36, 125.0010}
	.new 'ScarletPreAr' {3554.39, -3065.79, 134.9970} {3564.73, -3060.30, 134.9970}
	.new 'ScarletArchi' {3502.74, -3072.05, 134.9970} {3516.74, -3059.72, 134.9970}
.endtbl();

local _areaTbl = Encounter_MakeAreaTbl(_losTbl)
	-- Streets
	.new ('FrasCornerSt', SHAPE_POLYGON) {3526.60, -3344.00} {3526.60, -3290.00} {3470.00, -3290.00} {3470.00, -3344.00} ('FrasCornerSt', 132.154, 100)
	.new ('EntrancePull', SHAPE_POLYGON) {3398.88, -3363.11} {3398.86, -3395.90} {3525.94, -3420.83} {3523.92, -3364.31} ('EntrancePull', 142.966, 100)
	.new ('1stCrossroad', SHAPE_POLYGON) {3519.10, -3296.82} {3519.10, -3430.76} {3594.90, -3430.76} {3594.90, -3296.82} ('1stCrossroad', 136.816, 100)
	.new ('FountnSquare', SHAPE_POLYGON) {3727.66, -3456.26} {3568.71, -3456.52} {3568.71, -3538.00} {3727.66, -3538.00} ('FountSquareA', 137.914, 100)
	.new ('PScarletGate', SHAPE_POLYGON) {3655.22, -3316.75} {3655.22, -3248.17} {3758.14, -3207.13} {3758.14, -3316.75} ('PScarletGate', 127.781, 100)
	.new ('NorthStreets', SHAPE_POLYGON) {3637.93, -3318.09} {3657.72, -3449.14} {3800.19, -3400.33} {3728.14, -3315.88} ('NorthStreetA', 127.781, 100)
	.new ('EntranceBSqr', SHAPE_POLYGON) {3575.36, -3560.34} {3709.68, -3523.30} {3737.74, -3658.49} {3586.56, -3672.30} ('EntranceBSqA', 127.781, 100)
	-- Scarlet Areas
	.new ('ScarletSquar', SHAPE_POLYGON) {3701.84, -3120.38} {3592.63, -3174.25} {3629.31, -3256.63} {3750.25, -3199.23} ('ScarletSquar', 127.781, 100)
	.new ('ScarletHall1', SHAPE_POLYGON) {3644.88, -3061.92} {3587.11, -3102.98} {3602.20, -3122.55} {3661.58, -3081.51} ('ScarletHall1', 134.122, 100)
	.new ('ScarletPillr', SHAPE_POLYGON) {3582.84, -3100.44} {3562.66, -3074.80} {3591.74, -3055.77} {3610.93, -3082.77} ('ScarletPillr', 134.122, 100)
	.new ('ScarletCann1', SHAPE_POLYGON) {3545.72, -3034.18} {3597.47, -2997.39} {3584.46, -2979.47} {3531.99, -3015.54} ('ScarletCann1', 125.000, 100)
	.new ('ScarletCann2', SHAPE_POLYGON) {3584.46, -2979.47} {3531.99, -3015.54} {3519.40, -2961.97} {3572.04, -2920.44} ('ScarletCann2', 125.000, 100)
	.new ('ScarletPreAr', SHAPE_POLYGON) {3553.34, -3059.58} {3491.79, -3102.18} {3479.09, -3080.91} {3539.30, -3038.65} ('ScarletPreAr', 134.997, 100)
	.new ('ScarletArchi', SHAPE_POLYGON) {3499.66, -3064.96} {3441.42, -3106.46} {3425.35, -3082.98} {3485.67, -3040.00} ('ScarletArchi', 134.997, 100)
.endtbl();

local NPC_EYE_OF_NAXXRAMAS = 10411;

local NPC_RANGED_LIST = Encounter_NewRangedList();
function NPC_RANGED_LIST.IsRanged() return true; end

local function TriggerCircle_GateToSquare(unit, hive, data)
	Print("TriggerCircle_GateToSquare");
	Encounter_SetAreaLosPos("1stCrossroad", data.dungeon.AreaTbl, data.dungeon.LosTbl, "1stCrossSqrG");
	Encounter_SetAreaLosPos("EntrancePull", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntrancePAlt");
	Encounter_SetAreaLosPos("FountnSquare", data.dungeon.AreaTbl, data.dungeon.LosTbl, "FountSquareC");
	Encounter_SetAreaLosPos("EntranceBSqr", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceBSqA");
end

local function TriggerCircle_GateRatTrap(unit, hive, data)
	Print("TriggerCircle_GateRatTrap");
	Encounter_SetAreaLosPos("1stCrossroad", data.dungeon.AreaTbl, data.dungeon.LosTbl, "1stCrossRatG");
	Encounter_SetAreaLosPos("EntrancePull", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntrancePAlt");
	Encounter_SetAreaLosPos("NorthStreets", data.dungeon.AreaTbl, data.dungeon.LosTbl, "NorthStreetA");
end

local function TriggerCircle_GhostSpawn(unit, hive, data)
	Print("TriggerCircle_GhostSpawn");
	Encounter_SetAreaLosPos("FountnSquare", data.dungeon.AreaTbl, data.dungeon.LosTbl, "FountSquareA");
	Encounter_SetAreaLosPos("EntranceBSqr", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceBSqA");
end

local function TriggerCircle_ReverseNorth(unit, hive, data)
	Print("TriggerCircle_ReverseNorth");
	Encounter_SetAreaLosPos("NorthStreets", data.dungeon.AreaTbl, data.dungeon.LosTbl, "NorthStreetB");
end

local function TriggerCircle_EntranceB(unit, hive, data)
	Print("TriggerCircle_EntranceB");
	Encounter_SetAreaLosPos("FountnSquare", data.dungeon.AreaTbl, data.dungeon.LosTbl, "FountSquareB");
	Encounter_SetAreaLosPos("EntranceBSqr", data.dungeon.AreaTbl, data.dungeon.LosTbl, "EntranceBSqB");
end

Stratholme.triggers = {
	Encounter_NewTriggerCircle("GateToSquare", 3564.13,-3443.87,136.709,20,100, TriggerCircle_GateToSquare),
	Encounter_NewTriggerCircle("GateRatTrap",  3611.36,-3335.34,124.178,20,100, TriggerCircle_GateRatTrap),
	Encounter_NewTriggerCircle("GhostSpawn",   3713.24,-3426.11,131.328,20,100, TriggerCircle_GhostSpawn),
	Encounter_NewTriggerCircle("ReverseNorth", 3704.78,-3486.47,129.789,20,100, TriggerCircle_ReverseNorth),
	Encounter_NewTriggerCircle("EntranceB",    3593.09,-3648.60,138.508,15,100, TriggerCircle_EntranceB),
};

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
