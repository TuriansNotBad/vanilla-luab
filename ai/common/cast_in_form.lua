--[[*******************************************************************************************
	Tries to cast a spell in specified form.

	Parameter 0  Initial target [Guid]
	Parameter 1  Spell id       [int]
	Parameter 2  Form           [ShapeshiftForm]

	goal:SetNumber() usage.
		0: Form id
		1: Flag if we successfully began casting

	Example of use
	-- Applies Manual Crowd Pummeler effect to self when shapeshifted out
	goal:AddSubGoal(GOAL_COMMON_CastInForm, -1, target:GetGuid(), SPELL_GEN_PUMMELER, FORM_NONE);
*********************************************************************************************]]

-- GOAL_COMMON_Buff = 7;
REGISTER_GOAL(GOAL_COMMON_CastInForm, "CastInForm");

local SN_PFORM = 0; -- previous form
local SN_CAST  = 1; -- has started casting

--[[******************************************************
	Goal start
********************************************************]]
function CastInForm_Activate(ai, goal)
	goal:SetNumber(SN_PFORM, ai:GetForm());
	local form = goal:GetParam(2);
	ai:SetForm(form);
end

--[[******************************************************
	Goal update
********************************************************]]
function CastInForm_Update(ai, goal)
	
	local guid 	= goal:GetParam(0);
	local spell = goal:GetParam(1);
	local form  = goal:GetParam(2);
	local buffer= goal:GetParam(3);
	local agent = ai:GetPlayer();
	local target = GetUnitByGuid(agent, guid);
	
	if (nil == target or false == target:IsAlive()) then
		return GOAL_RESULT_Failed;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted() or goal:GetSubGoalNum() > 0) then
		return GOAL_RESULT_Continue;
	end
	
	if (goal:GetNumber(SN_CAST) == 1) then
		return GOAL_RESULT_Success;
	end
	
	local data = ai:GetData();
	if (nil ~= data.UpdateShapeshift) then
		data:UpdateShapeshift(ai, agent, goal);
	else
		error("CastInForm: UpdateShapeshift function not defined for agent " .. agent:GetName());
	end
	
	if (CAST_OK ~= agent:IsInPositionToCast(target, spell, buffer)) then
		goal:AddSubGoal(GOAL_COMMON_MoveInPosToCast, 10.0, guid, spell, buffer);
	elseif (agent:GetShapeshiftForm() == form) then
		if (CAST_OK == agent:CastSpell(target, spell, false)) then
			goal:SetNumber(SN_CAST, 1);
		end
	end
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function CastInForm_Terminate(ai, goal)
	ai:SetForm(goal:GetNumber(SN_PFORM));
	local data = ai:GetData();
	if (nil ~= data.UpdateShapeshift) then
		data:UpdateShapeshift(ai, ai:GetPlayer(), goal);
	else
		error("CastInForm_Terminate: UpdateShapeshift function not defined for agent " .. agent:GetName());
	end
end

--[[******************************************************
--  No interrupt
********************************************************]]
function CastInForm_Interupt(ai, goal)	return false;end
