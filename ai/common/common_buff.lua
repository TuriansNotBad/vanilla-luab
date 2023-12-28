--[[*******************************************************************************************
	Coordinated buffing implementation.
	Notes:
		<blank>
*********************************************************************************************]]

local data = {};
local board = {};

BUFF_SINGLE = 0;
BUFF_PARTY  = 1;

function board.gettbl(key)
	return data[key];
end

function board.post(key, id, guid, value)
	
	if (data[key] == nil) then
		data[key] = {};
	end
	data[key][id] = {guid, value};
	
end

function board.up(key, id)
	if (data[key] and data[key][id]) then
		return true;
	end
	return false;
end

function board.remove(key, id)
	if (data[key]) then
		data[key][id] = nil;
	end
end

function board.get(key, id)
	if (data[key]) then
		local post = data[key][id];
		if (post) then
			return post[1], post[2];
		end
	end
	error("board.get: post doesn't exist key = " .. tostring(key) .. " id = " .. tostring(id));
end

function AI_PostBuff(casterGuid, recieverGuid, key, value)
	if (board.up(key, recieverGuid:GetId())) then
		error("Agent posting buff while already having one key key = " .. tostring(key) .. " id = "
			.. tostring(recieverGuid:GetId()) .. " caster = " .. tostring(casterGuid:GetId()));
	end
	Print("Buff posted", key, value, casterGuid:GetId(), recieverGuid:GetId());
	board.post(key, recieverGuid:GetId(), casterGuid, value);
end

function AI_UnpostBuff(recieverGuid, key)
	Print("Buff removed", key, recieverGuid:GetId());
	board.remove(key, recieverGuid:GetId());
end

local function AI_HasBuffAssignedInternal(key, id)
	if (board.up(key, id)) then
		-- caster check
		local guid, value = board.get(key, id);
		local caster = GetPlayerByGuid(guid);
		if (nil == caster or false == caster:IsAlive()) then
			board.remove(key, id);
			return false;
		end
		return true;
	end
	return false;
end

function AI_HasBuffAssigned(recieverGuid, key, type)

	if (type == BUFF_SINGLE) then
	
		if (AI_HasBuffAssignedInternal(key, recieverGuid:GetId())) then
			return true;
		end
		
	elseif (type == BUFF_PARTY) then
		
		-- for buffs that apply to whole party
		local info = board.gettbl(key);
		if (info == nil) then
			return false;
		end
		
		local reciever = GetPlayerByGuid(recieverGuid);
		if (not reciever) then
			return false;
		end
		
		-- if any reciever is in same subgroup as us
		for id,buffinfo in next,info do
		
			local target = GetPlayerById(id);
			if (nil == target) then
				board.remove(key, id);
			elseif (reciever:IsInSameSubGroup(target)) then
				return true;
			end
			
		end
		
	else
		error("AI_HasBuffAssigned: unknown buff type - " .. tostring(type));
	end
	
	return false;
	
end

function AI_GetAssignedBuff(recieverGuid, key)
	return board.get(key, recieverGuid:GetId());
end
