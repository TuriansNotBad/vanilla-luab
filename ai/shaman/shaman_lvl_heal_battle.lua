--[[*******************************************************************************************
	GOAL_ShamanLevelHeal_Battle = 10009
	
	Shaman healer leveling top goal for PI
	Description:
		<blank>
	
	Status:
		WIP ~ 0%
*********************************************************************************************]]
REGISTER_GOAL(GOAL_ShamanLevelHeal_Battle, "ShamanLevelHeal");

-- local function print()end Print=print; fmtprint=print;

local ST_POT  = 0;

local function ShamanPotions(agent, goal, data, defensePot)

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

local function ShamanHealerCombat(ai, agent, goal, party, data, partyData, target)
	
	error("ShamanHealerCombat: NYI");
	
end

--[[*****************************************************
	Goal activation.
*******************************************************]]
function ShamanLevelHeal_Activate(ai, goal)
	
	-- remove old buffs
	AI_CancelAgentBuffs(ai);
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	
	-- learn proficiencies
	agent:LearnSpell(Proficiency.Dagger);
	agent:LearnSpell(Proficiency.Mail);
	
	local gsi = GearSelectionInfo(
		0.001, 0.001, -- armor, damage
		GearSelectionWeightTable(ItemStat.Intellect, 5, ItemStat.Stamina, 1, ItemStat.Spirit, 3), -- stats
		GearSelectionWeightTable(AURA_MOD_HEALING_DONE, 15, AURA_MOD_HEALING_DONE_PERCENT, 25), -- auras
		SpellSchoolMask.Arcane --| SpellSchoolMask.Nature
	);
	local info = {
		ArmorType = {"Cloth"},
		WeaponType = {"Dagger"},
		OffhandType = {"Holdable"},
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
	
	data.heal10   = ai:GetSpellMaxRankForMe(SPELL_SHA_HEALING_WAVE);
	data.heal5    = ai:GetSpellOfRank(SPELL_SHA_HEALING_WAVE, 5);
	data.heal1    = ai:GetSpellOfRank(SPELL_SHA_HEALING_WAVE, 1);
	data.chainheal= ai:GetSpellOfRank(SPELL_SHA_CHAIN_HEAL, 1);
	data.hot      = nil;
	
	-- totems
	data.ttremor = ai:GetSpellMaxRankForMe(SPELL_SHA_TREMOR_TOTEM);
	data.tstr    = ai:GetSpellMaxRankForMe(10442);--ai:GetSpellMaxRankForMe(SPELL_SHA_STRENGTH_OF_EARTH_TOTEM);
	data.twind   = ai:GetSpellMaxRankForMe(SPELL_SHA_WINDFURY_TOTEM);
	
	data._hasTotemicMs = agent:HasTalent(582, 0);
	
	data.heals = {data.heal1};
	if (level < 32) then
		table.insert(data.heals, data.heal10);
	else
		table.insert(data.heals, data.heal5);
		table.insert(data.heals, data.heal10);
	end
	
	data.weakestHeal = data.heals[1];
	assert(#data.heals > 0, "ShamanLevelHeal_Activate: #data.heals > 0");
	
	-- consumes
	data.food    = Consumable_GetFood(level);
	data.water   = Consumable_GetWater(level);
	data.manapot = Consumable_GetManaPotion(level);
	data.flask   = Consumable_GetFlask(SPELL_GEN_FLASK_OF_DISTILLED_WISDOM, level);
	data.grenade = Consumable_GetExplosive(level);
	
	Movement_Init(data);
	data.ShouldInterruptPrecast = Healer_ShouldInterruptPrecast;
	data.InterruptCurrentHealingSpell = Healer_InterruptCurrentHealingSpell;
	data.UsePotions = ShamanPotions;
	data.combatFn = ShamanHealerCombat;
	data.SelectHealSpell = ShamanLevelHeal_SelectHealSpell;
	
	local _,threat = agent:GetSpellDamageAndThreat(agent, ai:GetSpellMaxRankForMe(SPELL_WAR_SUNDER_ARMOR), false, true);
	ai:SetStdThreat(threat);
	
	-- Command params
	Cmd_EngageSetParams(data, true, nil, AI_DummyActions);
	Cmd_FollowSetParams(data, 90.0, 80.0);
	-- register commands
	Command_MakeTable(ai)
		(CMD_FOLLOW, nil, nil, nil, true)
		(CMD_ENGAGE, nil, nil, nil, true)
		(CMD_HEAL,   nil, nil, nil, true)
		(CMD_SCRIPT, nil, nil, nil, true)
	;
	
end

--[[*****************************************************
	Goal update.
*******************************************************]]
function ShamanLevelHeal_Update(ai, goal)
	
	ShamanTotems(ai, ai:GetPlayer(), goal, ai:GetData(), ai:GetPartyIntelligence():GetData());
	if (goal:GetActiveSubGoalId() == GOAL_COMMON_TotemXYZ or goal:GetActiveSubGoalId() == GOAL_COMMON_Totem) then
		return GOAL_RESULT_Continue;
	end
	
	-- handle commands
	if (not Command_DefaultUpdate(ai, goal)) then
		return GOAL_RESULT_Continue;
	end
	
	local agent = ai:GetPlayer();
	local party = ai:GetPartyIntelligence();
	local partyData = party:GetData();
	
	if (not partyData.hasEnemies) then
		agent:UnsummonAllTotems();
	end
	
	return GOAL_RESULT_Continue;
	
end

function ShamanLevelHeal_SelectHealSpell(ai, agent, goal, data, target, hp, hpdiff, maxThreat, partyData)
	
		local n = 0;
		local lowestHp;
		for i = 1, #partyData.agents do
			local allyai = partyData.agents[i];
			local player = allyai.GetPlayer and allyai:GetPlayer() or allyai;
			if (player:IsPlayer() and player:IsInSameSubGroup(agent)) then
				local hp = player:GetHealthPct();
				if (hp < 60) then
					if (not lowestHp or lowestHp > hp) then lowestHp = hp; end
					n = n + 1;
				end
			end
		end
		if ((lowestHp and lowestHp < 50 and n > 1) or (n > 2)) then
			local threat,value = agent:GetSpellDamageAndThreat(target, data.chainheal, true, false);
			if (threat < maxThreat) then
				return data.chainheal,value,threat;
			end
		end
	
	return Healer_BestHealSpell(ai, agent, goal, data, target, hp, hpdiff, maxThreat, partyData);
	
end

local t_totems = {
	[TOTEM_EARTH] = {
		Strength = {[5874] = true, [5921] = true, [5922] = true, [7403] = true, [15464] = true,},
		Tremor = {[5913] = true,},
	},
	[TOTEM_WATER] = {
		Poison = {[5923] = true,},
	},
	[TOTEM_AIR] = {
		Windfury = {[6112] = true, [7483] = true, [7484] = true,},
	},
};

local function HasTotemType(agent, slot, type)
	local earthEntry = agent:GetTotemEntry(slot);
	return earthEntry ~= nil and t_totems[slot][type][earthEntry] == true;
end

local function GetTotemTarget(agent, partyData, rchrpos, encTotemPos)
	
	if (encTotemPos) then
		return {x = encTotemPos.x, y = encTotemPos.y, z = encTotemPos.z}, encTotemPos.d, encTotemPos.a;
	end
	
	if (rchrpos and rchrpos.melee == nil) then
		if (agent:IsMoving()) then
			return nil;
		end
		return agent, 0, 0;
	end
	
	local target = partyData.owner;
	if (#partyData.tanks > 0) then
		for i,tank in ipairs(partyData.tanks) do
			if (tank:CmdType() == CMD_TANK) then
				target = tank:GetPlayer();
				break;
			end
		end
	end
	
	if (target:IsMoving()) then
		return nil;
	end
	
	return target, 8.0, 0.0;
	
end

local function ShamanTotemDoTotem(ai, agent, goal, data, partyData, totemSlot, totemType, totemSpell, totems)
	
	local rchrpos = data.rchrpos or (partyData.encounter and partyData.encounter.rchrpos);
	
	local totem = totems[totemSlot];
	local shouldPlace = false == HasTotemType(agent, totemSlot, totemType);
	if (not shouldPlace and totem) then
		local target, D, A = GetTotemTarget(agent, partyData, rchrpos, partyData.encounter and partyData.encounter.totemPos);
		local r = 18;
		if (totemType == "Tremor" or data._hasTotemicMs) then
			r = 27;
		end
		if (type(target) == "table") then
			shouldPlace = totem:GetDistance(target.x, target.y, target.z) > r;
		elseif (target) then
			shouldPlace = totem:GetDistance(target) > r;
		end
	end
	
	if (shouldPlace and agent:HasEnoughPowerFor(totemSpell, false)) then
		
		if (Tank_AnyTankPulling(partyData.tanks)) then return true; end
		if (ai:CmdType() == CMD_HEAL) then
			local target = GetUnitByGuid(agent, ai:CmdArgs());
			if (target) then
				if (target:GetHealthPct() < 70) then
					return true;
				end
			end
		end
		
		local target, D, A = GetTotemTarget(agent, partyData, rchrpos, partyData.encounter and partyData.encounter.totemPos);
		if (type(target) == "table") then
			goal:AddSubGoal(GOAL_COMMON_TotemXYZ, 10.0, target.x, target.y, target.z, totemSpell, totemSlot, D, A);
		elseif (target) then
			goal:AddSubGoal(GOAL_COMMON_Totem, 10.0, target:GetGuid(), totemSpell, totemSlot, D, A);
		end
		return true;
	end
	return false;
	
end

function ShamanTotems(ai, agent, goal, data, partyData)
	
	if (goal:GetSubGoalNum() > 0 or not partyData.hasEnemies) then
		return;
	end
	
	local level = agent:GetLevel();
	local totems = agent:GetTotems();
	
	-- earth
	if (level >= 18 and true == partyData._needTremor) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_EARTH, "Tremor", data.ttremor, totems)) then
			return;
		end
	elseif (level >= 10) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_EARTH, "Strength", data.tstr, totems)) then
			return;
		end
	end
	
	-- water
	if (level >= 22 and true == partyData._needPoisonCleansing) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_WATER, "Poison", SPELL_SHA_POISON_CLEANSING_TOTEM, totems)) then
			return;
		end
	end
	
	-- air
	if (level >= 32) then
		if (ShamanTotemDoTotem(ai, agent, goal, data, partyData, TOTEM_AIR, "Windfury", data.twind, totems)) then
			return;
		end
	end
	
end

--[[*****************************************************
	Goal termination.
*******************************************************]]
function ShamanLevelHeal_Terminate(ai, goal)

end

--[[*****************************************************
	Goal interrupts.
*******************************************************]]
function ShamanLevelHeal_Interrupt(ai, goal)

end
