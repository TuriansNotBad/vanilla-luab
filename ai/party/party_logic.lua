--[[*******************************************************************************************
	LOGIC_ID_Party = 0;
	
	Logic for PartyIntelligence agents.
	Description:
		Used to assign top goal on initialization.
		All decision making should be handled by PartyIntelligence.
*********************************************************************************************]]
REGISTER_LOGIC_FUNC(LOGIC_ID_Party, "Party_Logic", "Party_Init");

--[[*******************************************************
	Init.
	Assigns top goal.
*********************************************************]]
function Party_Init(ai)
	local spec = ai:GetSpec();
	if (#spec == 0) then
		error("PI agent has no spec assigned - " .. ai:GetPlayer():GetName());
	end
	local classTable = t_agentSpecs[ ai:GetPlayer():GetClass() ];
	if (nil == classTable) then
		error("No spec table exists for class " .. ai:GetPlayer():GetClass());
	end
	local specTable = classTable[spec];
	if (nil == specTable) then
		error("No spec table exists for spec " .. spec);
	end
	local data = ai:GetData();
	data.battleGoalID = specTable.BattleGoalID;
	ai:AddTopGoal(data.battleGoalID, -1);
end

--[[*******************************************************
	Logic.
*********************************************************]]
function Party_Logic(ai)
	local data = ai:GetData();
	if (not ai:HasTopGoal(data.battleGoalID)) then
		ai:AddTopGoal(data.battleGoalID, -1);
	end
end

