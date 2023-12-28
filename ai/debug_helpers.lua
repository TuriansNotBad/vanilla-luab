--[[*******************************************************************************************
	Misc funcs to help with debug efforts.
	Notes:
		<blank>
*********************************************************************************************]]

function Debug_PrintTable( T, msg ,indent )
	local outputStr = ""
	if( msg ~= nil ) then
		print( msg )
	end
	
	if( indent == nil ) then indent = 0 end
	
	-- print indent
	local indentStr = ""
	for i = 0, ( indent - 1) do 
		indentStr = indentStr.."    "
	end
	
	-- print all key values
	for k,v in pairs( T ) do
		if( type( v ) == "table" ) then
			--print( "T["..k.."]=tableref" )
			Debug_PrintTable( v, indentStr.."T["..tostring(k).."]=tableref:", indent + 1 )
		else
			print( indentStr.."T["..tostring(k).."]="..tostring(v) )
		end
	end
end

function fmtprint(fmt, ...)
	print(string.format(fmt, ...));
end

function Print(...)
	local n = select("#", ...);
	for i = 1, n do
		local value = select(i, ...);
		if (type(value) == "number") then
			if (math.floor(value) == value) then
				value = string.format("%d", value);
			else
				value = string.format("%.3f", value);
			end
		else
			value = tostring(value);
		end
		io.write(value);
		if (i < n) then
			io.write " ";
		end
	end
	io.write "\n";
end

--[[*****************************************************
	Returns talent table structured by the tabs,
	columns and rows, as it would appear in game.
*******************************************************]]
function DebugPlayer_GetNiceTalentTbl(player)	
	local t = player:GetTalentTbl();
	local tree = {};
	for i = 1,#t do
		local talent = t[i];
		local tab = talent.TalentTab;
		local row = talent.Row;
		local col = talent.Col;
		tree[tab] = tree[tab] or {};
		tree[tab][row] = tree[tab][row] or {};
		tree[tab][row][col] = {};
		local entry = tree[tab][row][col];
		entry[1] = talent.spellName;
		entry[2] = 0;
		entry[3] = talent.TalentID;
	end
	return tree;
end

--[[*****************************************************
	Prints the player's talent trees.
	If bPrintLearnedN is true prints how many points
	player invested into the talent.
*******************************************************]]
function DebugPlayer_PrintTalentsNice(player, bPrintLearnedN)
	local tree = DebugPlayer_GetNiceTalentTbl(player);
	for k,tab in next,tree do
		local str = k;
		io.write("[\"", str, "\"] = {\n");
		for i = 0, #tab do
			io.write '    '
			local row = tab[i];
			for j = 0, 10 do
				local col = row[j];
				if (not col) then
					
				else
					local ranks = bPrintLearnedN and player:GetTalentRank(col[3]) + 1 or col[2];
					io.write("{\"", col[1], "\", ", ranks, ", ", col[3], "}, ");
				end
			end
			io.write "\n";
		end
		io.write '},\n';
	end
end
