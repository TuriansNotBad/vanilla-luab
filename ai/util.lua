
function table.ifind(t, v)
	for i = 1,#t do
		if (t[i] == v) then
			return i
		end
	end
	return 0;
end

function table.merge(t, ...)
	for i = 1, select("#", ...) do
		local rhs = select(i, ...);
		for j = 1, #rhs do
			table.insert(t, rhs[j]);
		end
	end
	return t;
end

function dist2sqr(x,y,a,b)
	return (x-a)*(x-a) + (y-b)*(y-b);
end
