
function Data_GetEncounterDistancingR(encounter, default)
	if (encounter) then return encounter.distancingR or default; end
	return default;
end

function Data_GetEncounterHoldArea(encounter)
	if (encounter) then return encounter.hold_area; end
end

function Data_GetEncounterTankSwap(encounter)
	if (encounter) then return encounter.tankswap; end
end

function Data_GetRchrpos(aidata, encounter)
	if (aidata.rchrpos) then return aidata.rchrpos; end
	if (encounter) then return encounter.rchrpos; end
end

function Data_GetAttackers(aidata, partyData)
	return aidata.targets or partyData.attackers;
end

function Data_GetAllowHealerCc(aidata, partyData)
	return partyData.encounter and partyData.encounter.allowHealerCc;
end

function Data_GetDefensePotion(aidata, encounter)
	if (aidata.defensepot) then return aidata.defensepot; end
	if (encounter) then return encounter.defensepot; end
end

--------------------------------------------------------------------
-- Encounter: Dispel Filter
--------------------------------------------------------------------

function Data_GetDispelFilter(aidata, data)
	assert(data, "Data_GetDispelFilter: no party data provided");
	if (data.encDispelFilter) then
		return data.encDispelFilter;
	end
	if (data.dungeon and data.dungeon.dispelFilter) then
		return data.dungeon.dispelFilter;
	end
	if (data.encounter and data.encounter.dispelFilter) then
		return data.encounter.dispelFilter;
	end
end

function Data_SetPartyDispelFilter(aidata, filter)
	aidata.encDispelFilter = filter;
end

function Data_GetIgnoreThreat(aidata, partyData)
	return Data_GetAttackers(aidata, partyData).ignoreThreat;
end

--------------------------------------------------------------------
-- Encounter: Heal Mode - max healing
--------------------------------------------------------------------

function Data_SetAgentHealModeMax(aidata, value)
	aidata.encHealModeMax = value;
end

function Data_GetHealModeMax(aidata, partyData)
	if (aidata.encHealModeMax) then
		return true;
	end
	return partyData.encounter and partyData.encounter.healmax;
end

--------------------------------------------------------------------
-- Encounter: Scripts
--------------------------------------------------------------------

function Data_IsAgentRunningScript(ai, aidata, scriptName)
	return ai:CmdType() == CMD_SCRIPT and aidata.script ~= nil and aidata.script.name == scriptName;
end

--------------------------------------------------------------------
-- Encounter: Self Defense
--------------------------------------------------------------------

function Data_GetShouldSelfDefense(aidata, partyData)
	return partyData.encounter and partyData.encounter.selfdef;
end

function Data_SetSelfDefenseFn(aidata, fn)
	aidata.encSelfDefenseFn = fn;
end

function Data_GetAgentSelfDefenseFn(aidata)
	return aidata.encSelfDefenseFn;
end

function Data_GetTankOrientation(aidata, partyData)
	return partyData.encounter and partyData.encounter.tanko;
end

function Data_AgentRegisterChanneledAoe(data, ...)
	local n = select("#", ...);
	if (n < 1) then
		error("Data_AgentRegisterChanneledAoe: no aoe spells specified");
	end
	data.channeledAoe = {};
	for i = 1,n,2 do
		local spell = select(i, ...);
		local r     = select(i + 1, ...);
		if (type(spell) ~= "number" or type(r) ~= "number") then
			error("Data_AgentRegisterChanneledAoe: spell id expected, got " .. tostring(spell) .. " " .. tostring(r));
		end
		data.channeledAoe[spell] = r;
	end
end
