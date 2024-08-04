--[[*******************************************************************************************
	Instructs a bot to get in aggro range of N closest enemies.
	Initial target is always first to be WarriorPvpOWed, ignoring all enemies in the way.
	If initial target is not among N closest enemies it's added manually. The WarriorPvpOW will be a mess, though.
	Success when all selected targets have threat > 0

	Parameter 0  Initial target [Guid]
	Parameter 1  How many enemies to WarriorPvpOW [m]	(1-5)
	Parameter 2  Destination offset angle. Ccw from target's facing. [deg]	(0-360)

	goal:SetNumber() usage.
		0: Make distance to X coordinate
		1: Make distance to Y coordinate
		2: Make distance to Z coordinate
		9: Flag to only add FollowIdle once

	Example of use
	-- Try to find 3 targets near victim, including victim, within 30 meters of target and bow-WarriorPvpOW all found.
	goal:AddSubGoal(GOAL_COMMON_WarriorPvpOW, -1, victim:GetObjectGuid(), 3, 20);
*********************************************************************************************]]

-- GOAL_WARRIOR_OpenWorldPvp = 11000;
REGISTER_GOAL(GOAL_WARRIOR_OpenWorldPvp, "WarriorPvpOW");

--[[******************************************************
	Goal start
********************************************************]]
function WarriorPvpOW_Activate(ai, goal)
	local t = ai:GetData();
	local agent = ai:GetPlayer();
	
	t.demoShout 	= ai:GetSpellMaxRankForMe(SPELL_WAR_DEMORALIZING_SHOUT);
	t.charge		= ai:GetSpellMaxRankForMe(SPELL_WAR_CHARGE);
	t.rend			= ai:GetSpellMaxRankForMe(SPELL_WAR_REND);
	t.heroic		= ai:GetSpellMaxRankForMe(SPELL_WAR_HEROIC_STRIKE);
	t.execute		= ai:GetSpellMaxRankForMe(SPELL_WAR_EXECUTE);
	t.mortalstrike	= ai:GetSpellMaxRankForMe(SPELL_WAR_MORTAL_STRIKE);
	t.thunderclap	= ai:GetSpellMaxRankForMe(SPELL_WAR_THUNDER_CLAP);
	t.sunder 		= ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR);
	t.overpower 	= ai:GetSpellMaxRankForMe(SPELL_WAR_OVERPOWER);
	t.hamstring 	= ai:GetSpellMaxRankForMe(SPELL_WAR_HAMSTRING);
	
	t._hasMortalStrike = agent:HasTalent(135,0);
	
	t.actionTable = {
		{SPELL_WAR_BLOODRAGE, target = "self", lvl = 10, maxPowerPct = 70, msg="Bloodrage"},
		
		{t.demoShout, lvl = 14, maxDist = 10, isAura = true, msg="Demo Shout"},
		{t.thunderclap, lvl = 6, maxDist = 8, isAura = true, msg="Thunder Clap"},
		{t.hamstring, lvl = 8, isAura = true, msg="Hamstring"},
		
		{t.rend, lvl = 4, isAura = true, msg="Rend"},
		{t.mortalstrike, reqTalent = t._hasMortalStrike, isAura = true, msg="Mortal Strike"},
		{t.execute, lvl = 24, msg="Execute"},
		{t.overpower, lvl = 12, msg="Overpower"},
		{t.sunder, lvl = 10, msg="Sunder"},
		
		{t.heroic, minPowerPct = 90, isMelee = true, msg="Heroic Strike"},
	};
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Bow);
	agent:LearnSpell(Proficiency.Axe2H);
	agent:LearnSpell(Proficiency.Mace2H);
	agent:LearnSpell(Proficiency.Sword2H);
	
	local gsi = GearSelectionInfo(
		0.0001, 1.5, -- armor, damage
		GearSelectionWeightTable(ItemStat.Strength, 5, ItemStat.Agility, 1.5), -- stats
		GearSelectionWeightTable(), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local wpns = {"Sword2H", "Axe2H", "Mace2H"};
	local info = {
		ArmorType = {"Mail"},
		WeaponType = { wpns[ math.random(1, #wpns) ] },
		RangedType = {"Bow"},
	};
	AI_SpecGenerateGear(ai, info, gsi, nil, true);

end


--[[******************************************************
	Goal update
********************************************************]]
function WarriorPvpOW_Update(ai, goal)
	
	local t = ai:GetData();
	
	local agent = ai:GetPlayer();
	local attackers = agent:GetAttackers();
	local _allowCheat = true;
	
	-- mobs attacking me? attack closest one
	if (#attackers > 0) then
		
		local myTarget = agent:GetVictim();
		local myTargetDist = (myTarget and myTarget:GetDistance(agent)) or 99999999;
		local _closestTarget = myTarget;
		local _closestDist = 9999999;
		for i,attacker in ipairs(attackers) do
			-- don't cheat against agents
			if (attacker:IsPlayer() or attacker:GetLevel() - 5 > agent:GetLevel()) then
				_allowCheat = false;
			end
			local dist = agent:GetDistance(attacker);
			if (_closestDist > dist and math.abs(myTargetDist - _closestDist) > 1) then
				_closestDist = dist;
				_closestTarget = attacker;
			end
		end
		
		-- attack nearest guy
		if (_closestTarget and _closestTarget ~= myTarget) then
			agent:Attack(_closestTarget);
			agent:MoveChase(_closestTarget, 1, 5, 2, 0, math.pi * 2, true, false, false);
		end
		
	end
	
	
	-- wait for cast to finish
	if (agent:IsNonMeleeSpellCasted()) then
		
		return GOAL_RESULT_Continue;
	end
	-- stance anyway
	AI_ApplyAura(ai, agent, false, true, SPELL_WAR_BATTLE_STANCE);
	
	local target = agent:GetVictim();
	if (target) then
		
		-- cheat against mobs when no agents are engaging us
		if (_allowCheat and not target:IsPlayer()) then
			agent:SetHealthPct(100.0);
			agent:SetPowerPct(agent:GetPowerType(), 100.0);
		end
		
		
		if (not agent:IsMoving()) then
			if (agent:GetMotionType() == MOTION_IDLE) then
				agent:MoveChase(target, 1, 5, 2, 0, math.pi * 2, true, false, false);
			end
		end
		
		local dist = agent:GetDistance(target);
		
		if (dist >= 8 and agent:GetLevel() >= 4 and agent:GetMotionType() ~= MOTION_CHARGE) then
			if (agent:CastSpell(target, t.charge, false) == SPELL_CAST_OK) then
				return GOAL_RESULT_Continue;
			end
		end
		
		if (AI_DoAction(ai, t.actionTable, target)) then
			return GOAL_RESULT_Continue;
		end
		
		return GOAL_RESULT_Continue;
	end
	
	-- move to target if gets close enough
	if (not t._pvpTargetGuid) then
		return GOAL_RESULT_Continue;
	end
	
	local _pvpTarget = GetPlayerByGuid(t._pvpTargetGuid);
	if (not _pvpTarget) then
		return GOAL_RESULT_Continue;
	end
	
	ai:SetDesiredLevel(_pvpTarget:GetLevel());
	
	-- Chaaarge!
	if (_pvpTarget:GetDistance(agent) < t.droneInfo.r) then
		
		-- attack our guy
		if (_pvpTarget ~= agent:GetVictim()) then
			agent:Attack(_pvpTarget);
			agent:MoveChase(_pvpTarget, 1, 5, 2, 0, math.pi * 2, true, false, false);
			-- print(agent:(), "_pvptarget branch");
		end
		
	end
	-- print(agent:GetDistanceToPos(t.droneInfo.x, t.droneInfo.y, t.droneInfo.z), agent:GetVictim());
	if (not agent:GetVictim() and agent:GetDistance(t.droneInfo.x, t.droneInfo.y, t.droneInfo.z) > 2) then
		-- go home
		if (not ai:IsMovingTo(t.droneInfo.x, t.droneInfo.y, t.droneInfo.z)) then
			agent:MovePoint(t.droneInfo.x, t.droneInfo.y, t.droneInfo.z, true);
			-- print(agent:GetMotionType(), "move branch");
			return GOAL_RESULT_Continue;
		end
	end
	
	return GOAL_RESULT_Continue;
end


--[[******************************************************
	Goal terminate
********************************************************]]
function WarriorPvpOW_Terminate(ai, goal)
end


--[[******************************************************
--  Interrupt
--  Return true if interrupted.
--  Add an interrupt subgoal here.
--  If not interrupted, the interrupt is handled by the goal or logic part of the next layer above.
********************************************************]]
function WarriorPvpOW_Interupt(ai, goal)	return false;end

