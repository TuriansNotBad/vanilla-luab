--[[*******************************************************************************************
	GOAL_DruidBalanceLevelDps_Battle = 10000
	
	Dps balance druid leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_DruidBalanceLevelDps_Battle, "DruidBalanceLevel");

--[[*****************************************************
	Goal activation.
*******************************************************]]
function DruidBalanceLevel_Activate(ai, goal)
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	local gsi = GearSelectionInfo(
		0.0003, 0, -- armor, damage
		GearSelectionWeightTable(ItemStat.Spirit, 5, ItemStat.Intellect, 4, ItemStat.Stamina, 1), -- stats
		GearSelectionWeightTable(AURA_MOD_DAMAGE_DONE, 15), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	-- AI_SpecGenerateGear(ai, gsi);
	
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
function DruidBalanceLevel_Update(ai, goal)

	local cmd = ai:CmdType();
	if (cmd == -1) then
		return GOAL_RESULT_Continue;
	end
	
	-- handle commands
	if (cmd == CMD_FOLLOW) then
		local agent = ai:GetPlayer();
		if (ai:CmdState() == CMD_STATE_WAITING or agent:GetMotionType() ~= MOTION_FOLLOW) then
			agent:ClearMotion();
			ai:CmdSetInProgress();
			local guid = ai:CmdArgs();
			agent:MoveFollow(GetPlayerByGuid(guid), 3, math.pi);
		end
	end

	return GOAL_RESULT_Continue;
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function DruidBalanceLevel_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function DruidBalanceLevel_Interrupt(ai, goal)

end
