require("game/turn")
require("game/logic")
require("global")
function Game(pos)
	local g = {}
	g.timeline = {}
	g.draw50 = 0
	local freshmap = Map:new(false)
	do8x8(pos,function(s,l)
		if not (s==0) then
			freshmap[l] = true
		end
	end)
	local T = Turn:new(pos,1,freshmap)
	g.current = T
	table.insert(g.timeline,T)
	function g:takeback()
		if self.current.turn < 2 then return false end
		local T = self.timeline[self.current.turn-1]
		table.remove(self.timeline)
		self.current = T
		if self.draw50 > 0 then
			self.draw50 = self.draw50 -1
		end
		return T
	end
	function g:isPiece(l)
		if self.current.pos[l]==0 or not hasTurn(self.current.pos[l],self.current.turn) then
			return false
		else
			return true
		end
	end
	function g:tryMove(l,s)
		local T = self.current:move(l,s)
		if T then
			table.insert(self.timeline,T)
			self.current = T
			self.draw50 = check_draw(self.timeline,self.draw50)
		end
		return T
	end
	return g
end
