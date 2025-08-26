
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
	Returns true if string str starts with characters in string start.
****************************************************************************]]
function string_startswith(str, start)
   return str:sub(1, #start) == start;
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
	Returns Y value associated with given X on provided segment.
	Remarks:
	- Nil if X doens't lie on segment.
	- Highest Y value if line is vertical.
****************************************************************************]]
function lineSegmentGetYAtX(segment, x)
	if ((x - segment.a.x) * (x - segment.b.x) > 0) then
		return nil;
	end
	
	-- vertical line
	if (segment.a.x == segment.b.x) then
		return math.max(segment.a.y, segment.b.y);
	end
	
	local m = (segment.b.y - segment.a.y)/(segment.b.x - segment.a.x);
	return m * (x - segment.a.x) + segment.a.y;
end

do

	local function pointOnSegment(S, P)
		return (P.x - S.a.x) * (P.x - S.b.x) <= 0 and (P.y - S.a.y) * (P.y - S.b.y) <= 0;
	end
	
	local function sign(v)
		if (v == 0) then return 0; end
		if (v > 0) then return 1; end
		return -1;
	end
	
	local function tripletOrientation(p,q,r)
		return sign((q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y));
	end
	
	--[[**************************************************************************
		Returns true if 2 line segments intersect.
	****************************************************************************]]
	function lineSegmentCheckIntersect(S1, S2)
		local o1 = tripletOrientation(S1.a, S1.b, S2.a);
		local o2 = tripletOrientation(S1.a, S1.b, S2.b);
		local o3 = tripletOrientation(S2.a, S2.b, S1.a);
		local o4 = tripletOrientation(S2.a, S2.b, S1.b);
		
		if ((o1 ~= o2 and o3 ~= o4)
		or (o1 == 0 and pointOnSegment(S1, S2.a))
		or (o2 == 0 and pointOnSegment(S1, S2.b))
		or (o3 == 0 and pointOnSegment(S2, S1.a))
		or (o4 == 0 and pointOnSegment(S2, S1.b))) then
			return true;
		end
		
		return false;
	end
	
end

--[[**************************************************************************
	Checks whether shape is complex, convex, or concave.
	Can't handle triangles.
	Does not handle collinear overlap.
****************************************************************************]]
function polygonGetType(shape)
	
	assert(#shape.edges > 3, "shape does not define a polygon function can process. sides < 3");
	
	local function _polyEdgesAreNotAdj(s, t)
		return (s.a.x ~= t.b.x or s.a.y ~= t.b.y) and (s.b.x ~= t.a.x or s.b.y ~= t.a.y);
	end
	
	-- brute force self-intersection test
	for i,edgeCur in ipairs(shape.edges) do
		for j,edge in ipairs(shape.edges) do
			if (edgeCur ~= edge and _polyEdgesAreNotAdj(edgeCur, edge)) then
				if (lineSegmentCheckIntersect(edgeCur, edge)) then
					return POLYGON_COMPLEX;
				end
			end
		end
	end
	
	local prev = 0;
	for i = 1,#shape.edges do
		local a = shape.edges[i].a;
		local b = shape.edges[1 + (i % #shape.edges)].a;
		local c = shape.edges[1 + ((i + 1) % #shape.edges)].a;
		local dx1 = b.x - a.x;
		local dy1 = b.y - a.y;
		local dx2 = c.x - a.x;
		local dy2 = c.y - a.y;
		local X = dx1*dy2 - dy1*dx2;
		if (X ~= 0) then
			if (X * prev < 0) then
				return POLYGON_CONCAVE;
			else
				prev = X;
			end
		end
	end
	
	return POLYGON_CONVEX;
end

--[[**************************************************************************
	Returns string representing the name of given polygon type.
****************************************************************************]]
function polygonGetTypeName(tp)
	if tp == POLYGON_COMPLEX then return "complex"; end
	if tp == POLYGON_CONVEX then return "convex"; end
	if tp == POLYGON_CONCAVE then return "concave"; end
	return "unknown";
end

--[[**************************************************************************
	Checks whether x,y lie inside concave polygon defined by shape.
	Points that lie on the edges/vertices aren't checked.
****************************************************************************]]
function pointInConcavePolygon(x,y,shape)
	local c = 0;
	for i = 1,#shape.edges do
		local edge = shape.edges[i];
		local a,b = edge.a,edge.b;
		-- edge isn't horizontal and point's Y lies between endpoints
		if (a.y ~= b.y and math.min(a.y, b.y) <= y and math.max(a.y,b.y) >= y) then
			local intersectX = (y - a.y) * (b.x - a.x) / (b.y - a.y) + a.x;
			if (intersectX > x) then
				c = c + 1;
			end
		end
	end
	
	return c % 2 == 1;
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
function pointInArea(x,y,z,shape,concave,checkZ)
	local check;
	if (concave) then
		check = pointInConcavePolygon(x,y,shape);
	else
		check = pointInConvexPolygon(x,y,shape);
	end
	if (check) then
		if (checkZ) then
			return z >= shape.minZ and z <= shape.maxZ;
		end
		return true;
	end
	return false;
end

--[[**************************************************************************
	Returns true if file was able to be opened for reading.
****************************************************************************]]
function Util_DoesFileOpenForReading(name)
	local f=io.open(name,"r");
	if f~=nil then io.close(f); return true; else return false; end
end
