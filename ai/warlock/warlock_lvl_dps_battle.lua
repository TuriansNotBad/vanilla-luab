--[[*******************************************************************************************
	GOAL_WarlockLevelDps_Battle = 10004
	
	Mage dps leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_WarlockLevelDps_Battle, "WarlockLevelDps");

local ST_POT = 0;

local function Warlock_GetCurse(curseStr, data)
	if (curseStr == "elements") then
		return data.curseote;
	elseif (curseStr == "recklessness") then
		return data.curseor;
	end
end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function WarlockLevelDps_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Dagger);
	agent:LearnSpell(Proficiency.Sword);
	
	local gsi = GearSelectionInfo(
		0.001, 0.001, -- armor, damage
		GearSelectionWeightTable(ItemStat.Intellect, 5, ItemStat.Stamina, 1, ItemStat.Spirit, 3), -- stats
		GearSelectionWeightTable(AURA_MOD_DAMAGE_DONE, 15), -- auras
		SpellSchoolMask.Shadow --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth"},
		WeaponType = {"Staff"},--, "Dagger", "Sword"},
		-- OffhandType = {"Holdable"},
		RangedType = {"Wand"},
	};
	AI_SpecGenerateGear(ai, info, gsi, nil, true)
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	ai:SetRole(ROLE_RDPS);
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	
	-- AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	
	data.shadowbolt = ai:GetSpellOfRank(SPELL_WRL_SHADOW_BOLT, 9);
	
	data.curseote   = ai:GetSpellMaxRankForMe(SPELL_WRL_CURSE_OF_THE_ELEMENTS);
	data.curseor    = ai:GetSpellMaxRankForMe(SPELL_WRL_CURSE_OF_RECKLESSNESS);
	
	data.corruption = ai:GetSpellOfRank(SPELL_WRL_CORRUPTION, 6);

	data.fear       = ai:GetSpellMaxRankForMe(SPELL_WRL_FEAR);
	
	data.drainmana  = ai:GetSpellMaxRankForMe(SPELL_WRL_DRAIN_MANA);
	
	data.curse      = "elements";
	data.forcecurse = nil;
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_FLASK_OF_DISTILLED_WISDOM, level);
	
	local party = ai:GetPartyIntelligence();
	if (party) then
		local partyData = party:GetData();
		partyData:RegisterCC(agent, data.fear, true);
		data.ccspell = data.fear;
	end
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(threat * 2);
	
	-- Command params
	Cmd_EngageSetParams(data, true, 25.0, WarlockDpsRotation);
	Cmd_FollowSetParams(data, 90.0, 80.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
		(CMD_BUFF,   nil, nil, nil, true)
		(CMD_SCRIPT, nil, nil, nil, true)
		(CMD_CC,     nil, nil, nil, true)
	;
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function WarlockLevelDps_Update(ai, goal)
	-- handle commands
	Command_DefaultUpdate(ai, goal);
	return GOAL_RESULT_Continue;
end

local function WarlockPotions(agent, goal, data, defensePot)
	
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

local function GetAEThreat(ai, agent, targets)
	local minDiff = 99999999;
	if (#targets < 1) then return minDiff; end
	for idx,target in ipairs(targets) do
		if (not Unit_IsCrowdControlled(target)) then
			local _,tankThreat = target:GetHighestThreat();
			local diff = (tankThreat - ai:GetStdThreat()) - target:GetThreat(agent);
			if (diff < minDiff) then
				minDiff = diff;
			end
		end
	end
	return math.max(0, minDiff);
end

function WarlockDpsRotation(ai, agent, goal, party, data, partyData, target)
	
	local level = agent:GetLevel();
	local encounter = partyData.encounter or {};
	
	if (agent:IsNonMeleeSpellCasted()) then
		return false;
	end
	
	-- if (agent:IsMoving()) then
		-- return false;
	-- end
	
	local mana = agent:GetPowerPct(POWER_MANA);
	local hp = agent:GetHealthPct();
	local party = ai:GetPartyIntelligence();
	
	-- Potions
	WarlockPotions(agent, goal, data, encounter.defensepot);
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, data.shadowbolt, 2.5)) then
		-- print("pos fail", agent:IsInPositionToCast(target, data.frostbolt, 2.5));
		return false;
	end
	
	local curseid = Warlock_GetCurse(data.forcecurse or data.curse, data);
	if (curseid and false == target:HasAura(curseid)) then
		if (agent:CastSpell(target, curseid, false) == CAST_OK) then
			-- print("Corruption", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	if (false == target:HasAura(data.corruption)) then
		if (agent:CastSpell(target, data.corruption, false) == CAST_OK) then
			-- print("Corruption", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	if (data.attackmode == "manadrain") then
		if (agent:CastSpell(target, data.drainmana, false) == CAST_OK) then
			-- print("Drain Mana", agent:GetName(), target:GetName());
			return true;
		end
		return false;
	end
	
	local fearEncounter = encounter.allowFearCc;
	local saveMana = (data.saveMana and data.saveMana >= mana) or (fearEncounter and mana < 40.0);
	if (not saveMana) then
		-- spammable
		if (agent:CastSpell(target, data.shadowbolt, false) == CAST_OK) then
			-- print("Shadow Bolt", agent:GetName(), target:GetName());
			return true;
		end
	end
	
	return false;
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function WarlockLevelDps_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function WarlockLevelDps_Interrupt(ai, goal)

end
