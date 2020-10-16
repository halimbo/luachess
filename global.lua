letters = {"a","b","c","d","e","f","g","h"}
names = { [1] = "", [2] = "N", [3] = "B", [4] = "R", [5] = "Q", [8]="K" }
local function outside(t)
	if t.x < 1 or t.y < 1 or t.x > 8 or t.y > 8 then
		return true
	else
		return false
	end
end
loc={}
function loc:new(x,y)
	local l = {}
	l.x = x
	l.y = y
	setmetatable(l,self)
	self.__index = self
	self.__eq = function(one,two)
		if (one.x==two.x)
		and (one.y==two.y) then
			return true
		else
			return false
		end
	end
	self.__add = function(one,two)
		return self:new(one.x+two.x,one.y+two.y)
	end
	function l:move(dir)
		local new = self:v(dir)
		if not new then print("errD",dir) return false end
		if outside(new) then
			return false
		else
			return new
		end
	end
	function l:v(dir)
		if dir == 1 then
			return self+{x=0,y=1}
		elseif dir == 2 then
			return self+{x=1,y=1}
		elseif dir == 3 then
			return self+{x=1,y=0}
		elseif dir == 4 then
			return self+{x=1,y=-1}
		elseif dir == 5 then
			return self+{x=0,y=-1}
		elseif dir == 6 then
			return self+{x=-1,y=-1}
		elseif dir == 7 then
			return self+{x=-1,y=0}
		elseif dir == 8 then
			return self+{x=-1,y=1}
		elseif dir == 9 then
			return self+{x=1,y=2}
		elseif dir == 10 then
			return self+{x=2,y=1}
		elseif dir == 11 then
			return self+{x=2,y=-1}
		elseif dir == 12 then
			return self+{x=1,y=-2}
		elseif dir == 13 then
			return self+{x=-1,y=-2}
		elseif dir == 14 then
			return self+{x=-2,y=-1}
		elseif dir == 15 then
			return self+{x=-2,y=1}
		elseif dir == 16 then
			return self+{x=-1,y=2}
		else
			return false
		end
	end
	return l
end
Map = {}
function Map:new(insert)
	local m = {}
	m.storage = {}
	self.__index = function(self,k)
			if type(k)=="table" then return self.storage[k.x][k.y] else return self.storage[k] end end
	self.__newindex = function(self,k,v)
			if type(k)=="table" then self.storage[k.x][k.y]=v else self.storage[k]=v end end
	setmetatable(m,self)
	for i=1,8 do
		m[i] = {}
		for j=1,8 do
			if type(insert)=="table" then
				m[i][j] = {}
			else
				m[i][j] = insert
			end
		end
	end
	return m
end
function Map:copy(M)
	-- M[i][j] is never a table
	local m = {}
	m.storage = {}
	self.__index = function(self,k)
			if type(k)=="table" then return self.storage[k.x][k.y] else return self.storage[k] end end
	self.__newindex = function(self,k,v)
			if type(k)=="table" then self.storage[k.x][k.y]=v else self.storage[k]=v end end
	setmetatable(m,self)
	for i=1,8 do
		m[i] = {}
		for j=1,8 do
			local v = M[i][j]
			if type(v)=="table" then print("errC") return false end
			m[i][j] = v
		end
	end
	return m
end
function scrollPieces(pos,f)
	for x=1,8 do
		for y=1,8 do
			if not (pos[x][y]==0) then
				f(pos[x][y],loc:new(x,y),x,y)
			end
		end
	end
end
function hasTurn(id,turn)
	if turn%2==0 and not (id<0) then return false
	elseif not (turn%2==0) and id<0 then return false end
	return true
end
function scrollTurn(pos,turn,f)
	for x=1,8 do
		for y=1,8 do
			local id = pos[x][y]
			if not (id==0) and hasTurn(id,turn) then
				f(id,loc:new(x,y),x,y)
			end
		end
	end
end
function do8x8(pos,f)
	for x=1,8 do
		for y=1,8 do
			f(pos[x][y],loc:new(x,y),x,y)
		end
	end
end
function do8x8break(pos,f)
	local b
	for x=1,8 do
		for y=1,8 do
			if f(pos[x][y],loc:new(x,y),x,y) then
				b = true
				break
			end
		end
		if b then break end
	end
end
function abs(x)
	return math.abs(x)
end
function opponents(a,b)
	if not (a/abs(a)==b/abs(b)) then
		return true
	else
		return false
	end
end
function contains(list,item)
	for _,v in pairs(list) do
		if v==item then
			return true
		end
	end
	return false
end
C = {}
C.black = { r = 0, g = 0, b = 0 }
C.red = { r = 255, g = 0, b = 0 }
C.blue = { r = 0, g = 0, b = 255 }
C.yellow = { r=205/255, g = 190/255, b = 112/255}
C.style1W = { r=187/255, g = 187/255, b = 187/255}
C.style1B = { r=86/255, g = 91/255, b = 93/255}
C.style2W = { r=209/255, g = 219/255, b = 210/255}
C.style2B = { r=49/255, g = 104/255, b = 75/255}
C.style3W = { r=208/255, g = 223/255, b = 244/255}
C.style3B = { r=75/255, g = 100/255, b = 138/255 }
