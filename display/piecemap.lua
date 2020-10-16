require("global")
local function loveMatrix(matrix)
	local m = Map:new(0)
	for x=1,8 do
		for y=1,8 do
			m[x][y] = matrix[x][8-y+1]
		end
	end
	return m
end
local function flipMatrix(matrix)
	local m = Map:new(0)
	for x=1,8 do
		for y=1,8 do
			m[x][y] = matrix[8-x+1][8-y+1]
		end
	end
	return m
end
PieceMap = {}
function PieceMap:new(pos,flip)
	local p = {}
	if flip then
		p.isFlipped = true
	else
		p.isFlipped = false
	end
	local m = Map:new(0)
	do8x8(pos,function(s,l) m[l]=s end) 
	p.normal = loveMatrix(m)
	p.flipped = flipMatrix(p.normal)
	function p:get()
		local m = Map:new(0)
		if self.isFlipped then
			do8x8(self.flipped,function (s,l) m[l]=s end)
			return m
		else
			do8x8(self.normal,function (s,l) m[l]=s end)
			return m
		end
	end
	function p:ref()
		if self.isFlipped then
			return self.flipped
		else
			return self.normal
		end
	end
	function p:float(l)
		local id = self:ref()[l]
		local f = loc:new(l.x,l.y)
		f.id = id
		return f
	end
	function p:unFloat(l)
		return self:ref()[l]
	end
	function p:flipBoard()
		self.isFlipped = not self.isFlipped
	end
	function p:rotation()
		if self.isFlipped then return true else return false end
	end 
	function p:translate(s)
		if self.isFlipped then
			 return loc:new(8-s.x+1,s.y)
		else
			return loc:new(s.x,8-s.y+1)
		end
	end
	return p
end
