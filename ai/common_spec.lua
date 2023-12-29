--[[*******************************************************************************************
	Common functions to apply agent gear and talent specs easily.
	Notes:
		<blank>
*********************************************************************************************]]

-- local function print() end

--[[*****************************************************
	- Given a list of candidates returned by 
	AI_SpecGenerateGearMakeCandidates picks one with
	highest utility and inserts it into the list.
	- if num is equal to 2 will insert the item again so
	long as its not unique, otherwise inserts 2nd best
	candidate.
*******************************************************]]
local function GetBestCandidate(ai, list, candidates, gsi, num)

	print();
	if (num ~= 1 and num ~= 2) then
		error("GetBestCandidate num allowed values [1,2], got " .. tostring(num));
	end
	
	table.sort(candidates, function(a,b) return a[2] > b[2]; end);
	for i,v in ipairs(candidates) do
		local item = Item_GetItemFromId(v[1]);
		-- io.write(v[1] .. " " .. item:GetName() .. ", score=" .. v[2] .. " " .. tostring(v[3]) .. "    "); --item:Print();--item:GetUtility(ai, gsi);-- .. "\n");
	end
	
	local result = candidates[1];
	if (not result) then
		return;
	end
	
	table.insert(list, result);
	if (num == 2) then
	
		local item = Item_GetItemFromId(result[1]);
		if (not item:IsUnique()) then
			table.insert(list, result);
			return;
		end
		
		if (candidates[2]) then
			table.insert(list, candidates[2]);
		end
		
	end
	
end

--[[*****************************************************
	Creates a table of items that are either same level
	as agent or no more than 10 levels lower. Includes
	utility and chosen random property enchant.
*******************************************************]]
local function AI_SpecGenerateGearMakeCandidates(ai, lvl, full, gsi, candidates, slot)

	for i = 1, #full do
	
		local id = full[i];
		local item = Item_GetItemFromId(id);
		local itemLvl = item:GetContextualLevel();
		
		-- items that are same level or lower level by no more than 10 levels
		if (lvl - itemLvl <= 10 and lvl >= itemLvl) then
			local rp, utility = item:GetUtility(ai, gsi);
			if (utility > 0 and (nil == slot or item:CanEquipToSlot(slot, ai:GetPlayer():GetClass()))) then
				table.insert(candidates, {id, utility, rp});
			end
		end
		
	end
	
end

--[[*****************************************************
	Given item list inserts the item with highest utility
	into the list.
*******************************************************]]
local function AI_SpecGenerateGearSubTbl(ai, full, tpTbl, lvl, list, gsi, num, slot)
	
	print("\n======================================")
	print("Generating Gear\n")
	
	local candidates = {};
	if (tpTbl) then
		for i = 1, #tpTbl do
			AI_SpecGenerateGearMakeCandidates(ai, lvl, full[tpTbl[i]], gsi, candidates, slot);
		end
	else
		AI_SpecGenerateGearMakeCandidates(ai, lvl, full, gsi, candidates, slot);
	end
	GetBestCandidate(ai, list, candidates, gsi, num or 1);
	
	print("\n======================================\n")

end

--[[*****************************************************
	Checks if item uses any of the slots in exceptSlot
*******************************************************]]
local function AI_SpecGenerateGearSlotCheck(item, class, exceptSlot)
	if (exceptSlot == nil) then
		return true;
	end
	local slots = {item:GetSlots(class, exceptSlot.dw or false)};
	for i = 1, #slots do
		if (slots[i] ~= EquipSlot.Null) then
			if (exceptSlot[slots[i]]) then
				return false;
			end
		end
	end
	return true;
end

--[[*****************************************************
	Equips best item for each slot based on utility.
	Refer to GearSelectionInfo description for info
	on gsi in ai_define_spec.lua.
*******************************************************]]
function AI_SpecGenerateGear(ai, info, gsi, exceptSlot, disablePrint)
	
	do
	
	local oprint,oPrint,ofmtprint,owrite=print,Print,fmtprint,io.write;
	if (disablePrint == true) then
		local function __null__ () end
		print,Print,fmtprint,io.write=__null__,__null__,__null__,__null__;
	end
	
	local agent = ai:GetPlayer();
	local level = agent:GetLevel();
	local class = agent:GetClass();
	
	local itemList = {};
	
	-- typed armor
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Chest    , info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Feet     , info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Hands    , info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Head     , info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Legs     , info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Shoulders, info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Waist    , info.ArmorType, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemArmorList.Wrists   , info.ArmorType, level, itemList, gsi);
	
	if (info.WeaponType.DualWield == true) then
		-- assuming we always can find at least 2 weapons for either slot
		-- get 2 for off hand in case of unique items that can be equipped into either
		AI_SpecGenerateGearSubTbl(ai, ItemWpnList, info.WeaponType, level, itemList, gsi, 1, EquipSlot.MainHand);
		AI_SpecGenerateGearSubTbl(ai, ItemWpnList, info.WeaponType, level, itemList, gsi, 2, EquipSlot.OffHand);
		-- remove extra off hand item
		local n = #itemList;
		if (itemList[n-1][1] == itemList[n-2][1] and Item_GetItemFromId(itemList[n-1][1]):IsUnique()) then
			table.remove(itemList, n-1);
		else
			table.remove(itemList, n);
		end
	else
		AI_SpecGenerateGearSubTbl(ai, ItemWpnList, info.WeaponType, level, itemList, gsi, 1, EquipSlot.MainHand);
		if (info.OffhandType) then
			AI_SpecGenerateGearSubTbl(ai, ItemWpnList,  info.OffhandType, level, itemList, gsi, 1, EquipSlot.OffHand);
		end
	end
	if (info.RangedType) then
		AI_SpecGenerateGearSubTbl(ai, ItemAccList,  info.RangedType, level, itemList, gsi);
	end
	
	AI_SpecGenerateGearSubTbl(ai, ItemAccList.Cloak,  nil, level, itemList, gsi);
	AI_SpecGenerateGearSubTbl(ai, ItemAccList.Finger, nil, level, itemList, gsi, 2);
	AI_SpecGenerateGearSubTbl(ai, ItemAccList.Neck,   nil, level, itemList, gsi);
		
	-- prevent combat interfering
	agent:SetGameMaster(true);
	ai:EquipDestroyAll();
	for i = 1, #itemList do
	
		local itemID = itemList[i][1];
		local item = Item_GetItemFromId(itemID);
		if (not disablePrint) then
			item:Print();
		end
		-- item:GetUtility(ai, gsi);
		
		if (AI_SpecGenerateGearSlotCheck(item, class, exceptSlot)) then
			ai:EquipItem(itemID, 0, itemList[i][3]);
		end
		
	end
	agent:SetHealthPct(100.0);
	agent:SetPowerPct(POWER_MANA, 100.0);
	agent:SetGameMaster(false);
	ai:UpdateVisibilityForMaster();
	
	if (disablePrint == true) then
		print,Print,fmtprint,io.write=oprint,oPrint,ofmtprint,owrite;
	end
	
	end
	
end

--[[*****************************************************
	Applies client appropriate talent spec to agent.
	Appropriate table is the "talents" table of the spec.
	- bNoCost to true to ignore talent costs.
	- dontLearn to true to not actually learn the talent.
*******************************************************]]
function AI_SpecApplyTalents(ai, level, alltalents, bNoCost, dontLearn)
	
	-- find client appropriate spec
	local talents;
	for i = 1, #alltalents do
		talents = alltalents[i][2];
		if (CVER >= alltalents[i][1]) then
			break;
		end
	end
	
	if (nil == talents) then
		error("No talents defined for spec " .. ai:GetSpec() .. " of agent " .. ai:GetPlayer():GetName());
	end
	
	local agent = ai:GetPlayer();
	agent:ResetTalents();
	local talentPoints = (bNocost and 500) or level - 9;
	local ranksLearned = {};
	
	for i = 1, #talents do
	
		local talent = talents[i];
		if (talent[2] > 0 and talentPoints > 0) then
		
			local talentPointCost = talent[2];
			-- adjust to how many ranks we already know
			if (ranksLearned[talent[3]]) then
				talentPointCost = talentPointCost - ranksLearned[talent[3]];
			end
			
			local rankToLearn = talent[2];
			-- find rank we can afford
			if (talentPoints < talentPointCost) then
			
				local diff = talentPointCost - talentPoints;
				rankToLearn = rankToLearn - diff;
				talentPointCost = talentPointCost - diff;
				
				if (rankToLearn <= 0) then
					print("Cost:", talentPointCost, " Has:", talentPoints, " Diff:", diff, "Wants:", talent[2], "Name:", talent[1]); 
					error("Unexpected error while learning talent");
				end
				
			end
			
			talentPoints = talentPoints - talentPointCost;
			if (not dontLearn) then
				agent:LearnTalent(talent[3], rankToLearn - 1, true);
			end
			ranksLearned[talent[3]] = rankToLearn;
			print(talent[3], talent[2], rankToLearn, talentPointCost, talentPoints, agent:GetName(), talent[1]);

		end
		
	end
	
end
