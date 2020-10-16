require("global")
require("game/logic")
require("game/change")
local function validate(pc,s)
	for _,l in ipairs(pc.moves) do
		if l==s and l.enpas then -- true since pawnM() in Logic:new()
			return true,true --trigger en passant in game:move()
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
	local g = {}
	setmetatable(g,self)
	self.__index = self
	local check,avail = isCheck(pos,turn,freshmap,eptoken)
	if check and avail then
		g.possible = avail
	elseif check and not avail then
		g.possible = Map:new(false)
		g.checkmate = findKing(pos,turn)
	else
		g.possible = possible(pos,turn,freshmap,eptoken)
		local stalemate = true
		do8x8break(g.possible,function (s,l) if s and #s.moves>0 then stalemate = false return true end end)
		if stalemate then
			print("stalemate")
			g.stalemate = findKing(pos,turn)
		end
	end
	g.pos = pos
	g.turn = turn
	g.freshmap = freshmap
	g.lastMove = lastMove
	function g:move(l,s)
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
			new = enpas(pos,l,s,loc:new(s.x,s.y-pc.id))
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
			eptoken = loc:new( s.x, l.y-(l.y-s.y)/2 )
			eptoken.id = 7*new[s]
		end
		local fmap = Map:copy(self.freshmap)
		if fmap[l] then
			fmap[l] = false
		end
		if cs then
			fmap[ cs[1] ] = false
		end
		return self:new(new,self.turn+1,fmap,eptoken,{l,s})
	end
	function g:isPiece(l)
		if self.pos[l]==0 or not hasTurn(self.pos[l],self.turn) then
			return false
		else
			return true
		end
	end
	return g
end
