
function table.ifind(t, v)
	for i = 1,#t do
		if (t[i] == v) then
			return i
		end
	end
	return 0;
end
