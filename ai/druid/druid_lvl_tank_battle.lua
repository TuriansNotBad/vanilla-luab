--[[*******************************************************************************************
	GOAL_DruidLevelTank_Battle = 10001
	
	Tank druid leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_DruidLevelTank_Battle, "DruidLevelTank");

--[[*****************************************************
	Goal activation.
*******************************************************]]
function DruidLevelTank_Activate(ai, goal)
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	local gsi = GearSelectionInfo(
		1, 1, -- armor, damage
		GearSelectionWeightTable(ItemStat.Stamina, 5, ItemStat.Strength, 3, ItemStat.Agility, 1.5), -- stats
		GearSelectionWeightTable(), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	-- pummeler
	if (level >= 29) then
		AI_SpecGenerateGear(ai, gsi, {[EquipSlot.MainHand] = true, [EquipSlot.OffHand] = true});
		ai:EquipItem(ITEMID_MANUAL_CROWD_PUMMELER, 0, 0);
		ai:UpdateVisibilityForMaster();
	else
		AI_SpecGenerateGear(ai, gsi);
	end
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	-- AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function DruidLevelTank_Update(ai, goal)

	local cmd = ai:CmdType();
	if (cmd == -1) then
		return GOAL_RESULT_Continue;
	end
	
	local agent = ai:GetPlayer();
	-- handle commands
	if (cmd == CMD_FOLLOW) then
	
		if (ai:CmdState() == CMD_STATE_WAITING or agent:GetMotionType() ~= MOTION_FOLLOW) then
			agent:AttackStop();
			agent:ClearMotion();
			ai:CmdSetInProgress();
			local guid, dist, angle = ai:CmdArgs();
			agent:MoveFollow(GetPlayerByGuid(guid), dist, angle);
		end
		
	elseif (cmd == CMD_ENGAGE) then
	
		-- do combat!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			ai:CmdSetInProgress();
		end
		local hive = ai:GetPartyIntelligence();
		local data = hive:GetData();
		local attackers = data.attackers;
		if (not attackers[1]) then
			return GOAL_RESULT_Continue;
		end
		if (agent:GetMotionType() ~= MOTION_CHASE or agent:GetVictim() ~= attackers[1]) then
			agent:AttackStop();
			agent:ClearMotion();
			agent:Attack(attackers[1]);
			local angle = ai:CmdArgs();
			agent:MoveChase(attackers[1], 0.001, 0.1, 0.1, angle, math.rad(15), true);
		end
	
	elseif (cmd == CMD_TANK) then
	
		-- do tank!
		if (ai:CmdState() == CMD_STATE_WAITING) then
			ai:CmdSetInProgress();
		end
		local guid = ai:CmdArgs();
		local target = GetUnitByGuid(ai, guid);
		if (nil == target) then
			return GOAL_RESULT_Continue;
		end
		if (target ~= agent:GetVictim()) then
			agent:AttackStop();
			agent:ClearMotion();
			agent:AttackStart(target);
			agent:MoveChase(target, 0.001, 0.1, 0.1, 0, math.pi, true);
		end
		
	end

	return GOAL_RESULT_Continue;
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function DruidLevelTank_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function DruidLevelTank_Interrupt(ai, goal)

end
