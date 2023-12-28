--[[*******************************************************************************************
	Just a test logic
*********************************************************************************************]]

-- LOGIC_ID_InvaderPvp = 3000;
REGISTER_LOGIC_FUNC(LOGIC_ID_InvaderPvp, "InvaderPvp_Logic", "InvaderPvp_Init");

local function give_invuln(agent)
	if (not agent:HasAura(498)) then
		agent:CastSpell(agent, 498, true);
		agent:RemoveSpellCooldown(498);
	end
end

function InvaderPvp_Init(ai)
	local master = ai:GetMaster();
	if (master) then
		ai:SetDesiredLevel(master:GetLevel());
	end
	give_invuln(ai:GetPlayer());
end

--[[*******************************************************
*********************************************************]]
function InvaderPvp_Logic(ai)
	
	local agent = ai:GetPlayer();
	local data = ai:GetData();
	
	-- Soft reset if we died;
	if (not agent:IsAlive() or nil == data.droneInfo or nil ~= data._pvpCoreDespawnTimer) then
		if (agent:IsAlive()) then
			give_invuln(agent);
		end
		ai:AddTopGoal(GOAL_COMMON_DoNothing, -1);
		return;
	end
	
	if (agent:GetMapId() ~= data.droneInfo.map
	or agent:GetZoneId() ~= data.droneInfo.zone
	or agent:GetDistance(data.droneInfo.x, data.droneInfo.y, data.droneInfo.z) > 400) then
		if (not agent:GetVictim() or not agent:GetVictim():IsPlayer()) then
			give_invuln(agent);
			ai:AddTopGoal(GOAL_COMMON_DoNothing, -1);
			agent:TeleportTo(data.droneInfo.map, data.droneInfo.x, data.droneInfo.y, data.droneInfo.z);
			return;
		end
	end
	
	if (agent:GetClass() == CLASS_WARRIOR) then
		ai:AddTopGoal(GOAL_WARRIOR_OpenWorldPvp, -1);
	end
	
end
