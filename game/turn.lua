require("global")
require("game/logic")
local function normal(pos,l,s)
	local map = Map:copy(pos)
	local str
	if map[s] == 0 then
		str = names[abs(map[l])]..letters[s.x]..s.y
	elseif abs(map[l]) == 1 then
		str = letters[l.x].."x"..letters[s.x]..s.y
	else
		str = names[abs(map[l])].."x"..letters[s.x]..s.y
	end
	map[s] = map[l]
	map[l] = 0
	print(str)
	return map
end
local function castles(pos,l,s,rook0,rook)
	local map = Map:copy(pos)
	map[s] = map[l]
	map[l] = 0
	map[rook] = map[rook0]
	map[rook0] = 0
	if rook0.x == 8 then
		print("0-0")
	else
		print ("0-0-0")
	end
	return map
end
local function enpas(pos,l,s,e)
	local map = Map:copy(pos)
	map[s] = map[l]
	map[l] = 0
	map[e] = 0
	print( letters[l.x].."x"..letters[s.x]..s.y )
	return map
end
local function queening(pos,l,s,queen)
	local map = Map:copy(pos)
	map[s] = queen
	map[l] = 0
	print( letters[s.x]..s.y.."="..names[abs(queen)])
	return map
end
local function validate(pc,s)
	for _,l in pairs(pc.moves) do
		if l==s and l.enpas then
			return true,true
		elseif l==s and l.castles then
			return true,nil,l.castles
		elseif l==s then
			return true
		end
	end
	return false
end
Turn = {}
function Turn:new(pos,turn,freshmap,eptoken,lastMove)
	local t = {}
	local check,avail = inCheck(pos,turn,freshmap,eptoken)
	if check and avail then
		t.possible = avail
	elseif check and not avail then
		t.possible = Map:new(false)
		t.checkmate = findKing(pos,turn)
	else
		t.possible = possible(pos,turn,freshmap,eptoken)
		print ("stalecheck")
		local stalemate = true
		do8x8break(t.possible,function (s,l) if s and #s.moves>0 then print(l.x,l.y,#s.moves) stalemate = false return true end end)
		if stalemate then
			print("stalemate")
			t.stalemate = findKing(pos,turn)
		end
	end
	t.pos = pos
	t.turn = turn
	t.freshmap = freshmap
	t.lastMove = lastMove
	function t:move(l,s)
		local eptoken
		local pc = self.possible[l]
		if not pc then print("?") return false end
		local valid,ep,cs = validate(pc,s)
		if not valid then return false end
		local pos = self.pos
		local new
		if cs then
			new = castles(pos,l,s,cs[1],cs[2])
		elseif ep then
			new = enpas(pos,l,s,loc:new(s.x,s.y-pc.id)) -- subtract capturing pawn
		elseif abs(pc.id)==1 and (s.y==1 or s.y==8) then
			local prom
			if love.keyboard.isDown("2") then
				prom = 2
			elseif love.keyboard.isDown("3") then
				prom = 3
			elseif love.keyboard.isDown("4") then
				prom = 4
			else
				prom = 5
			end
			new = queening(pos,l,s,prom*pc.id)
		else
			new = normal(pos,l,s)
		end
		-- creating new turn data
		if abs(new[s]) == 1 and abs(l.y-s.y)==2 then
			eptoken = loc:new( s.x, s.y-pc.id ) -- subtract pushed pawn
			eptoken.id = 7*new[s]
		end
		local fmap = Map:copy(self.freshmap)
		if fmap[l] then
			fmap[l] = false
		end
		if cs then
			fmap[ cs[1] ] = false
		end
		return Turn:new(new,self.turn+1,fmap,eptoken,{l,s})
	end
	return t
end
