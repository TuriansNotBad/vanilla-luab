
--[[**************************************************************************
	Searches for value v in array portion of table t.
	If found returns its index, otherwise returns 0.
****************************************************************************]]
function table_ifind(t, v)
	for i = 1,#t do
		if (t[i] == v) then
			return i
		end
	end
	return 0;
end

--[[**************************************************************************
	Performs a shallow copy of all array elements of tables into table t.
****************************************************************************]]
function table_merge(t, ...)
	for i = 1, select("#", ...) do
		local rhs = select(i, ...);
		for j = 1, #rhs do
			table.insert(t, rhs[j]);
		end
	end
	return t;
end

--[[**************************************************************************
	Returns a shallow copy of table t.
****************************************************************************]]
function table_clone(t)
	local result = {};
	for k,v in next,t do
		result[k] = v;
	end
	return result;
end

--[[**************************************************************************
	Returns a deep copy of simple table t.
	t should not contain tables used as keys. t should not be recursive.
	Does not handle metatables.
****************************************************************************]]
function table_deepclone(t)
	if (type(t) ~= "table") then return t; end
	local result = {};
	for k,v in next,t do
		result[k] = table_deepclone(v);
	end
	return result;
end

--[[**************************************************************************
	Returns number of keys in a table.
****************************************************************************]]
function table_numkeys(t)
	local c=0;
	for k,v in next,t do c=c+1; end
	return c;
end

--[[**************************************************************************
	Returns square of 2D distance between points (x,y) and (a,b).
****************************************************************************]]
function dist2sqr(x,y,a,b)
	return (x-a)*(x-a) + (y-b)*(y-b);
end

--[[**************************************************************************
	Creates a 2D point table.
****************************************************************************]]
function makePoint2d(x,y)
	return {x=x,y=y};
end

local function makePolygonEdge(a,b)
	return {a=a,b=b};
end

--[[**************************************************************************
	Creates a shape table for an area with polygon base.
	vertices - list of vertices as 2d points
	z - reference z coordinate of the rectangle
	hUp - how far into positive direciton of Z axis does area extend
	hDn - how far into negative direciton of Z axis does area extend
****************************************************************************]]
function makePolygonArea(vertices,z,hUp,hDn)
	if (not hDn) then hDn = hUp; end
	local shape = {};
	shape.vertices = vertices;
	shape.edges = {};
	shape.minZ = z - hDn;
	shape.maxZ = z + hUp;
	for i = 1,#vertices do
		local a = vertices[i];
		local b = vertices[i + 1] or vertices[1];
		table.insert(shape.edges, makePolygonEdge(a,b));
	end
	shape.type = SHAPE_POLYGON;
	return shape;
end

--[[**************************************************************************
	Checks whether x,y lie inside convex polygon defined by shape.
****************************************************************************]]
function pointInConvexPolygon(x,y,shape)
	local nPos = 0;
	local nNeg = 0;
	for i = 1,#shape.edges do
		local edge = shape.edges[i];
		local a,b = edge.a,edge.b;
		local d = (b.x - a.x) * (y - a.y) - (x - a.x) * (b.y - a.y);
		if (d >= 0) then
			nPos = nPos + 1;
		else
			nNeg = nNeg + 1;
		end
		if (nPos > 0 and nNeg > 0) then
			return false;
		end
	end
	return true;
end

--[[**************************************************************************
	Checks whether x,y,z lie inside area.
****************************************************************************]]
function pointInArea(x,y,z,shape,checkZ)
	if (pointInConvexPolygon(x,y,shape)) then
		if (checkZ) then
			return z >= shape.minZ and z <= shape.maxZ;
		end
		return true;
	end
	return false;
end
