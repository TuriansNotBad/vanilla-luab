--[[*******************************************************************************************
	GOAL_MageLevelDps_Battle = 10004
	
	Mage dps leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_MageLevelDps_Battle, "MageLevelDps");

local ST_POT = 0;

local function MageLevelDps_SelfDefense(ai, agent, goal, party, data, partyData)
	if (agent:GetLevel() >= 20) then
		if (not agent:HasAura(data.manashield) and agent:CastSpell(agent, data.manashield, false) == CAST_OK) then
			print(agent:GetName(), "Mana Shield");
			return true;
		end
	end
end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function MageLevelDps_Activate(ai, goal)
	
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
		SpellSchoolMask.Frost --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth"},
		WeaponType = {"Staff"},--, "Dagger", "Sword"},
		-- OffhandType = {"Holdable"},
		RangedType = {"Wand"},
	};
	
	local classTbl = t_agentSpecs[ agent:GetClass() ];
	local specTbl = classTbl[ ai:GetSpec() ];
	
	AI_SpecEquipLoadoutOrRandom(ai, info, gsi, nil, true, Gear_GetLoadoutForLevel60(specTbl.Loadout));
	
	ai:SetRole(ROLE_RDPS);
	
	local talentInfo = _ENV[ specTbl.TalentInfo ];
	
	AI_SpecApplyTalents(ai, level, talentInfo.talents );
	-- print();
	-- DebugPlayer_PrintTalentsNice(agent, true);
	-- print();
	
	local data = ai:GetData();
	
	data.blizzard   = ai:GetSpellMaxRankForMe(SPELL_MAG_BLIZZARD);
	data.fireball   = ai:GetSpellMaxRankForMe(SPELL_MAG_FIREBALL);
	data.frostbolt  = ai:GetSpellMaxRankForMe(SPELL_MAG_FROSTBOLT);
	data.fireblast  = ai:GetSpellMaxRankForMe(SPELL_MAG_FIRE_BLAST);
	data.scorch     = ai:GetSpellMaxRankForMe(SPELL_MAG_SCORCH);

	data.poly       = ai:GetSpellMaxRankForMe(SPELL_MAG_POLYMORPH);
	data.decurse    = SPELL_MAG_REMOVE_LESSER_CURSE;

	-- buff         
	data.frostA     = ai:GetSpellMaxRankForMe(SPELL_MAG_FROST_ARMOR);
	data.iceA       = ai:GetSpellMaxRankForMe(SPELL_MAG_ICE_ARMOR);
	data.mageA      = ai:GetSpellMaxRankForMe(SPELL_MAG_MAGE_ARMOR);
	data.manashield = ai:GetSpellMaxRankForMe(SPELL_MAG_MANA_SHIELD);

	data.brilliance = Builds.Select(ai, "1.4.2", SPELL_MAG_ARCANE_BRILLIANCE, ai.GetSpellMaxRankForMe);
	data.intellect  = ai:GetSpellMaxRankForMe(SPELL_MAG_ARCANE_INTELLECT);
	data.aint       = level >= 56 and data.brilliance or data.intellect;
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_FLASK_OF_SUPREME_POWER, level);
	
	Data_AgentRegisterChanneledAoe(data, data.blizzard, 10);
	Data_SetSelfDefenseFn(data, MageLevelDps_SelfDefense);
	
	-- dispels
	if (level >= 18) then
		data.dispels = {Curse = SPELL_MAG_REMOVE_LESSER_CURSE};
	end
	
	if (level < 30) then
		data.armor = data.frostA;
	elseif (level < 34) then
		data.armor = data.iceA;
	else
		data.armor = data.mageA;
	end
	
	Movement_Init(data);
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(threat * 2);
	
	local party = ai:GetPartyIntelligence();
	if (party) then
		local partyData = party:GetData();
		local type = BUFF_SINGLE;
		if (data.aint == data.brilliance) then
			type = BUFF_PARTY;
		end
		partyData:RegisterBuff(agent, "Arcane Intellect", 1, data.aint, type, 5*6e4);
		partyData:RegisterCC(agent, data.poly);
		data.ccspell = data.poly;
		if (level >= 18) then
			partyData:RegisterDispel(agent, "Curse");
		end
	end
	
	-- Command params
	Cmd_EngageSetParams(data, true, 25.0, MageDpsRotation);
	Cmd_FollowSetParams(data, 90.0, 80.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
		(CMD_BUFF,   nil, nil, nil, true)
		(CMD_DISPEL, nil, nil, nil, true)
		(CMD_SCRIPT, nil, nil, nil, true)
		(CMD_CC,     nil, nil, nil, true)
	;
	-- agent:SetGameMaster(false);
	-- agent:SetGameMaster(true);
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function MageLevelDps_Update(ai, goal)
	
	-- local agent     = ai:GetPlayer();
	-- local party     = ai:GetPartyIntelligence();
	-- local partyData = party:GetData();
	
	-- local owner = partyData.owner;
	-- if (not owner) then return GOAL_RESULT_Continue; end
	
	-- local target = owner:GetVictim() or owner;
	-- if (target == owner) then
		-- if (agent:GetMotionType() ~= MOTION_FOLLOW) then
			-- agent:MoveFollow(target, 0, 0);
		-- end
		-- return GOAL_RESULT_Continue
	-- end
	-- if (not target) then agent:AttackStop(); agent:ClearMotion(); return GOAL_RESULT_Continue; end
	-- print(target:GetDistanceEx(agent, 0))
	-- agent:Attack(target);
	-- if (agent:GetMotionType() ~= MOTION_CHASE or ai:GetChaseTarget() ~= target) then
		-- agent:ClearMotion();
		-- Dps_RangedChase(ai, agent, target, false)
	-- end
	-- target:SetHealthPct(100)
	
	-- if true then return GOAL_RESULT_Continue; end

	-- handle commands
	if (not Command_DefaultUpdate(ai, goal)) then
		return GOAL_RESULT_Continue;
	end
	
	if (ai:CmdType() == CMD_FOLLOW) then
		MageSelfBuff(ai:GetPlayer(), ai:GetData());
	end

	return GOAL_RESULT_Continue;
	
end

local function MagePotions(agent, goal, data, defensePot)
	
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

function MageSelfBuff(agent, data)
	
	-- armor
	if (not agent:HasAura(data.armor)) then
		agent:CastSpell(agent, data.armor, false);
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

function MageDpsRotation(ai, agent, goal, party, data, partyData, target)
	
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
	
	-- armor
	MageSelfBuff(agent, data);
	
	-- Potions
	MagePotions(agent, goal, data, Data_GetDefensePotion(data, encounter));
	
	-- los/dist checks
	if (CAST_OK ~= agent:IsInPositionToCast(target, data.frostbolt, 2.5)) then
		-- print("pos fail", agent:IsInPositionToCast(target, data.frostbolt, 2.5));
		return false;
	end
	
	if (data.attackmode == "none") then
		return false;
	end
	
	if ((data.attackmode == "burst" or (level > 20 and target:GetHealth() < 101)) and level >= 6) then
		if (agent:GetDistance(target) < 19) then
			if (agent:CastSpell(target, data.fireblast, false) == CAST_OK) then
				print("Fire Blast", agent:GetName(), target:GetName());
				return true;
			end
			if (level >= 22 and agent:CastSpell(target, data.scorch, false) == CAST_OK) then
				print("Scorch", agent:GetName(), target:GetName());
				return true;
			end
		end
		return false;
	elseif (data.attackmode == "aoe") then
		local level = agent:GetLevel();
		
		local targets = Data_GetAttackers(data, partyData);
		if (level >= 20) then
			if (Unit_AECheck(agent, 7, 3, false, targets)) then
				if (not target:IsMoving() and agent:CastSpell(target, data.blizzard, false) == CAST_OK) then
					return true;
				end
			end
		end
	end
	
	-- evocation
	if (level >= 20 and mana < 20 and agent:IsSpellReady(SPELL_MAG_EVOCATION) and agent:CastSpell(agent, SPELL_MAG_EVOCATION, false) == CAST_OK) then
		Print(agent:GetName(), "Evocation. Mana =", mana);
		return true;
	end
	
	-- check interruptable
	local interruptFilter = encounter.interruptFilter;
	local interruptCheck;
	if (interruptFilter) then
		interruptCheck = interruptFilter(ai, agent, party, target, partyData.attackers, false, 25.0);
	else
		interruptCheck = target:IsCastingInterruptableSpell();
	end
	-- interrupt
	if (level >= 24
	and interruptCheck
	and agent:IsSpellReady(SPELL_MAG_COUNTERSPELL)
	and false == AI_HasBuffAssigned(target:GetGuid(), "Interrupt", BUFF_SINGLE)) then
		goal:AddSubGoal(GOAL_COMMON_CastAlone, 5.0, target:GetGuid(), SPELL_MAG_COUNTERSPELL, "Interrupt", 3.0);
		AI_PostBuff(agent:GetGuid(), target:GetGuid(), "Interrupt", true);
		return true;
	end
	
	-- Blizzard
	if (level >= 20) then
		
		if (Unit_AECheck(target, 8.0, 4, not partyData.aoe, partyData.attackers)) then
			local d,t = agent:GetSpellDamageAndThreat(agent,  data.blizzard, false, true);
			if (Data_GetIgnoreThreat(data, partyData) or d * 6 < GetAEThreat(ai, agent, partyData.attackers)) then
				if (Dps_DoChanneledAoe(agent, target, data.blizzard, data)) then
					return true;
				end
			end
		end
		
	end
	
	-- spammable
	if (level >= 4 and data.attackmode ~= "fire") then
		if (agent:CastSpell(target, data.frostbolt, false) == CAST_OK) then
			-- print("Frostbolt", agent:GetName(), target:GetName());
			return true;
		else
			-- print("cast fail", agent:CastSpell(target, data.frostbolt, false));
		end
	elseif (agent:CastSpell(target, data.fireball, false) == CAST_OK) then
		print("Fireball", agent:GetName(), target:GetName());
		return true;
	end
	
	return false;
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function MageLevelDps_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function MageLevelDps_Interrupt(ai, goal)

end
