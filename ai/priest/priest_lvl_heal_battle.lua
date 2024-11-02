--[[*******************************************************************************************
	GOAL_PriestLevelHeal_Battle = 10001
	
	Tank druid leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_PriestLevelHeal_Battle, "PriestLevelHeal");

-- local function print()end Print=print; fmtprint=print;

local ST_POT  = 0;

local function PriestPotions(agent, goal, data, defensePot)

	if (defensePot and false == agent:HasAura(defensePot)) then
		if (goal:IsFinishTimer(ST_POT) and agent:CastSpell(agent, defensePot, true) == CAST_OK) then
			print("Defense Potion", GetSpellName(defensePot), agent:GetName());
			goal:SetTimer(ST_POT, 120);
		end
		return;
	end
	
	local mp = agent:GetPowerPct(POWER_MANA);
	-- Rage Potion
	if (data.manapot and goal:IsFinishTimer(ST_POT) and mp < 50 and agent:CastSpell(agent, data.manapot, true) == CAST_OK) then
		print("Mana Potion", agent:GetName());
		goal:SetTimer(ST_POT, 120);
	end
	
end

local function PriestHealerCombat(ai, agent, goal, party, data, partyData, target)
	
	if (agent:IsNonMeleeSpellCasted() or agent:IsInPositionToCast(target, data.smite, 2.0) ~= CAST_OK) then
		return false;
	end
	
	local level = agent:GetLevel();
	
	local targets = Data_GetAttackers(data, partyData);
	if (level >= 4 and data.attackmode == "aoe") then
		for i = 1,#targets do
			local target = targets[i];
			if (not target:HasAura(data.pain)) then
				if (agent:CastSpell(target, data.pain, false) == CAST_OK) then
					return true;
				end
			end
		end
	end

	if (targets.ignoreThreat) then
		if (level >= 10 and agent:CastSpell(target, data.mindblast, false) == CAST_OK) then
			return true;
		end
	end
	
	return agent:CastSpell(target, data.smite, false) == CAST_OK;
	
end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function PriestLevelHeal_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Dagger);
	
	agent:CancelAura(1460);

	
	local gsi = GearSelectionInfo(
		0.001, 0.001, -- armor, damage
		GearSelectionWeightTable(ItemStat.Intellect, 5, ItemStat.Stamina, 1, ItemStat.Spirit, 3), -- stats
		GearSelectionWeightTable(AURA_MOD_HEALING_DONE, 15, AURA_MOD_HEALING_DONE_PERCENT, 25), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth"},
		WeaponType = {"Mace", "Dagger"},
		OffhandType = {"Holdable"},
		RangedType = {"Wand"},
	};
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	AI_SpecEquipLoadoutOrRandom(ai, info, gsi, nil, true, Gear_GetLoadoutForLevel60(specTbl.Loadout));
	ai:SetRole(ROLE_HEALER);
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	
	AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data  = ai:GetData();
	
	data.gheal    = ai:GetSpellMaxRankForMe(SPELL_PRI_GREATER_HEAL);
	data.renew    = ai:GetSpellMaxRankForMe(SPELL_PRI_RENEW);
	data.fheal    = ai:GetSpellMaxRankForMe(SPELL_PRI_FLASH_HEAL);
	data.heal     = ai:GetSpellMaxRankForMe(SPELL_PRI_HEAL);
	data.lheal    = ai:GetSpellMaxRankForMe(SPELL_PRI_LESSER_HEAL);
	data.hot      = data.renew;
	
	data.fearward = ai:GetSpellMaxRankForMe(SPELL_PRI_FEAR_WARD);
	data.dispel   = ai:GetSpellMaxRankForMe(SPELL_PRI_DISPEL_MAGIC);
	data.pwf      = ai:GetSpellMaxRankForMe(SPELL_PRI_POWER_WORD_FORTITUDE);
	data.aepwf    = ai:GetSpellMaxRankForMe(SPELL_PRI_PRAYER_OF_FORTITUDE);
	data.innfire  = ai:GetSpellMaxRankForMe(SPELL_PRI_INNER_FIRE);
	
	data.shackle  = ai:GetSpellMaxRankForMe(SPELL_PRI_SHACKLE_UNDEAD);
	
	data.smite    = ai:GetSpellMaxRankForMe(SPELL_PRI_SMITE);
	data.mindblast= ai:GetSpellMaxRankForMe(SPELL_PRI_MIND_BLAST);
	data.pain     = ai:GetSpellMaxRankForMe(SPELL_PRI_SHADOW_WORD_PAIN);
	data.manaburn = ai:GetSpellMaxRankForMe(SPELL_PRI_MANA_BURN);
	
	data.fortitude = level >= 48 and data.aepwf or data.pwf;
	
	data.heals = {};
	-- weak heals
	if (level < 16) then
		table.insert(data.heals, data.lheal);
	else
		if (level < 40) then
			table.insert(data.heals, ai:GetSpellOfRank(SPELL_PRI_HEAL, 1));
		end
		table.insert(data.heals, data.heal);
	end
	-- strong heals
	if (level >= 40) then
		if (level >= 52) then
			table.insert(data.heals, ai:GetSpellOfRank(SPELL_PRI_GREATER_HEAL, 3)); -- gheal 3
		end
		table.insert(data.heals, data.gheal);
	end
	data.weakestHeal = data.heals[1];
	assert(#data.heals > 0, "PriestLevelHeal_Activate: #data.heals > 0");
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_FLASK_OF_DISTILLED_WISDOM, level);
	data.grenade = Consumable_GetExplosive(level);
	
	data.dispels = {
		Magic = data.dispel,
		Disease = level >= 32 and SPELL_PRI_ABOLISH_DISEASE or SPELL_PRI_CURE_DISEASE,
	};
	
	local party = ai:GetPartyIntelligence();
	if (party) then
		local partyData = party:GetData();
		
		-- Shackle Undead, has to be permitted by encounter
		if (level >= 20) then
			data.ccspell = data.shackle;
			partyData:RegisterCC(agent, data.shackle);
		end
	
		local type = BUFF_SINGLE;
		if (data.fortitude == data.aepwf) then
			type = BUFF_PARTY;
		end
		-- Prior to patch 1.3 Prayer of Fortitude only applied to your party
		if (CVER < Builds["1.3.1"]) then
			if (data.fortitude == data.aepwf) then
				partyData:RegisterBuff(agent, "ST: Power Word: Fortitude", 1, data.pwf, BUFF_SINGLE, 5*6e4, {party = false, notauras = {21564, 21562}});
			end
			partyData:RegisterBuff(agent, "Power Word: Fortitude", 1, data.fortitude, type, 5*6e4, {party = type == BUFF_PARTY or nil});
		else
			partyData:RegisterBuff(agent, "Power Word: Fortitude", 1, data.fortitude, type, 5*6e4);
		end
		if (agent:GetRace() == RACE_DWARF and level >= 20) then
			local filter = {
				role = {[ROLE_TANK] = true, [ROLE_HEALER] = true},
				dungeon = {fear = true},
			};
			partyData:RegisterBuff(agent, "Fear Ward", 1, data.fearward, BUFF_SINGLE, 3*6e4, filter, true);
			partyData:RegisterBuff(agent, "Fear Ward NC", 1, data.fearward, BUFF_SINGLE, 3*6e4, {dungeon = {fear = true}});
		end
		if (level >= 14) then
			partyData:RegisterDispel(agent, "Disease");
		end
		if (level >= 18) then
			partyData:RegisterDispel(agent, "Magic");
		end
	end
	
	Movement_Init(data);
	data.ShouldInterruptPrecast = Healer_ShouldInterruptPrecast;
	data.InterruptCurrentHealingSpell = Healer_InterruptCurrentHealingSpell;
	data.UsePotions = PriestPotions;
	data.combatFn = PriestHealerCombat;
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(threat);
	
	-- Command params
	Cmd_EngageSetParams(data, true, nil, AI_DummyActions);
	Cmd_FollowSetParams(data, 90.0, 80.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
		(CMD_BUFF,   nil, nil, nil, true)
		(CMD_DISPEL, nil, nil, nil, true)
		(CMD_CC,     nil, nil, nil, true)
		(CMD_HEAL,   nil, nil, nil, true)
		(CMD_SCRIPT, nil, nil, nil, true)
		(CMD_TRADE,  nil, nil, nil, true)
		(CMD_LOOT,   nil, nil, nil, true)
	;
	
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function PriestLevelHeal_Update(ai, goal)
	
	local agent = ai:GetPlayer();
	local data  = ai:GetData();
	if (agent:GetLevel() >= 12 and not agent:HasAura(data.innfire)) then
		agent:CastSpell(agent, data.innfire, false);
	end
	
	-- handle commands
	Command_DefaultUpdate(ai, goal);
	
	return GOAL_RESULT_Continue;
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function PriestLevelHeal_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function PriestLevelHeal_Interrupt(ai, goal)

end
