--[[*******************************************************************************************
	Tries to shapeshift to specified form. Does not check if form is valid for class.

	Parameter 0  Form  [ShapeshiftForm]

	goal:SetNumber() usage.
		0: Form id
		1: Flag if we successfully began casting

	Example of use
	-- Shifts to cat form
	goal:AddSubGoal(GOAL_COMMON_Shapeshift, -1, FORM_CAT);
*********************************************************************************************]]

-- GOAL_COMMON_Buff = 8;
REGISTER_GOAL(GOAL_COMMON_Shapeshift, "Shapeshift");

--[[******************************************************
	Goal start
********************************************************]]
function Shapeshift_Activate(ai, goal)
	local form = goal:GetParam(0);
	-- ai:SetForm(form);
	local agent = ai:GetPlayer();
	if (agent:GetShapeshiftForm() ~= FORM_NONE and agent:GetShapeshiftForm() ~= form) then
		agent:CancelAura(GetSpellForForm(agent:GetShapeshiftForm()));
	end
end

--[[******************************************************
	Goal update
********************************************************]]
function Shapeshift_Update(ai, goal)
	
	local form  = goal:GetParam(0);
	local agent = ai:GetPlayer();
	
	if (false == agent:IsAlive()) then
		return GOAL_RESULT_Failed;
	end
	
	-- cast in peace
	if (agent:IsNonMeleeSpellCasted()) then
		return GOAL_RESULT_Continue;
	end
	
	if (agent:GetShapeshiftForm() == form) then
		return GOAL_RESULT_Success;
	end
	
	local result = agent:CastSpell(agent, GetSpellForForm(form), false);
	
	return GOAL_RESULT_Continue;
	
end

--[[******************************************************
	Goal terminate
********************************************************]]
function Shapeshift_Terminate(ai, goal)
	-- ai:SetForm(goal:GetNumber(SN_PFORM));
end

--[[******************************************************
--  No interrupt
********************************************************]]
function Shapeshift_Interupt(ai, goal)	return false;end
