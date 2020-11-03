require("game/turn")
require("game/logic")
require("global")
function Game(pos)
	local g = {}
	g.timeline = {}
	local freshmap = Map:new(false)
	do8x8(pos,function(s,l)
		if not (s==0) then
			freshmap[l] = true
		end
	end)
	local T = Turn:new(pos,1,freshmap)
	g.current = T
	table.insert(g.timeline,T)
	function g:lookback()
		if self.current.turn < 2 then return false end
		local T = self.timeline[self.current.turn-1]
		self.current = T
		return { pos = T.pos, highlight = T.change, lastTurn = T.turn-1 }
	end
	function g:lookforward()
		if self.current.turn == #self.timeline then return false end
		local T = self.timeline[self.current.turn+1]
		self.current = T
		return { pos = T.pos, highlight = T.change, lastTurn = T.turn-1 }
	end
	function g:jumpto(turn)
		if turn<1 or turn>#self.timeline then return false end
		local T = self.timeline[turn]
		self.current = T
		return { pos = T.pos, highlight = T.change, lastTurn = T.turn-1 }
	end
	function g:save()
		local h = {}
		local n = #self.timeline
		local i = 1
		table.insert(h,self.timeline[i])
		i = 2
		while i<=n do
			table.insert(h,self.timeline[i].change)
			i=i+1
		end
		return h
	end
	function g:restore(h)
		local i = 1
		local pos = h[i]
		local freshmap = Map:new(false)
		do8x8(pos,function(s,l)
			if not (s==0) then
				freshmap[l] = true
			end
		end)
		local T = Turn:new(pos,1,freshmap)
		self.timeline={}
		table.insert(self.timeline,T)
		self.current = T
		local infos = {}
		i = 2
		local n = #h
		while i<=n do
			table.insert(infos,self:tryMove(h[i][1],h[i][2]))
			i=i+1
		end
		return infos
	end
	function g:isPiece(l)
		if self.current.pos[l]==0 or not hasTurn(self.current.pos[l],self.current.turn) then
			return false
		else
			return true
		end
	end
	function g:tryMove(l,s)
		local T = self.current:make_move(l,s)
		if T then
			return self:export(T)
		end
		return false 
	end
	function g:export(T)
		local i = {}
		local turn = T.turn
		local h
		local n = #self.timeline
		if turn<=n then
			h = self:save()
			h.split = self.current.turn
			local cut = self.current.turn + 1
			while cut<=n do
				self.timeline[cut]=nil
				cut = cut + 1
			end
		end
		local lastTurn = self.current.turn
		local lastMove = self.current.move
		i.kingToMove = T.kingPos
		if turn%2==1 then
			i.toMove = "White"
		else
			i.toMove = "Black"
		end
		if lastTurn%2==1 then i.str = lastMove..". "..T.lastAlg
		else i.str = T.lastAlg end
		if T.inCheck then
			i.str = i.str.."+"
			i.inCheck = true
		elseif T.checkmate then
			i.checkmate = true
			i.str = i.str.."#"
		end
		i.pos = T.pos
		i.highlight = T.change
		table.insert(self.timeline,T)
		print("New #Timeline:",#self.timeline)

		if not T.checkmate and
		( T.stalemate or T.drawCount>=100
		or drawRepetition(self.timeline) )then
			i.draw = true
		end
		self.current = T
		return i, h
	end
	return g
end
