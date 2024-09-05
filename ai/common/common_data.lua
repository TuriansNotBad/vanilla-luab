
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
