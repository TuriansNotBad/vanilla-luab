--[[*******************************************************************************************
	Common encounter script functions
*********************************************************************************************]]

-- remember everyone's roles
function Encounter_PreprocessAgents(key, data)
	for i,ai in ipairs(data.agents) do
		local aidata = ai:GetData();
		if (nil == aidata[key]) then
			aidata[key] = ai:GetRole();
		end
	end
end

-- reset everyone's roles
function Encounter_RestoreAgents(key, data, fnOnRestore)
	for i,ai in ipairs(data.agents) do
		local agent = ai:GetPlayer();
		local aidata = ai:GetData();
		if (fnOnRestore) then
			fnOnRestore(ai, agent, aidata, data);
		end
		if (aidata[key]) then
			Command_ClearAll(ai, key .. ".RestoreAgents");
			ai:SetRole(aidata[key]);
			aidata[key] = nil;
		end
	end
end

function Encounter_ChangeRole(ai, key, newRole)
	if (nil == ai:GetData()[key]) then
		error(key .. ".ChangeRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	ai:SetRole(newRole);
end

function Encounter_GetRealRole(ai, key)
	local data = ai:GetData();
	if (nil == data[key]) then
		error(key .. ".GetRealRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
	end
	return data[key];
end

function Encounter_RestoreRole(ai, key)
	local data = ai:GetData();
	if (data[key]) then
		ai:SetRole(data[key]);
		return;
	end
	error(key .. ".RestoreRole: " .. ai:GetPlayer():GetName() .. " - has no saved role, agent will not function correctly");
end
