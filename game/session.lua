require("global")
require("game/standard")
require("game/turn")
require("display/input")
require("display/board")
Session = {}
function Session:new(origin,size)
	local s = {}
	local pos = standard()
	local turn = 1
	s.timeline = {}
	setmetatable(s,self)
	self.__index = self
	s.board = Board:new(origin,size,pos)
	s.input = Input:new()
	local freshmap = Map:new(false)
	do8x8(pos,function(s,l)
		if not (s==0) then
			freshmap[l] = true
		end
	end)
	local T = Turn:new(pos,turn,freshmap)
	s.activeTurn = turn
	table.insert(s.timeline,T)
	function s:mouse(x,y)
		local click, here = self.board:click(x,y)
		if click then
			local B = self.board
			local T = self.timeline[self.activeTurn]
			local sel,newT = self.input:touch(T,here)
			if sel then
				B:setDiff("select",click,C.yellow,0.7)
				if not nofloat then B:newFloat(click) end
			elseif newT then
				self.activeTurn = newT.turn
				table.insert(self.timeline,newT)
				B:newTurn(newT)
			else
				B:setDiff("select",false)
			end
		end
	end
	function s:mouseRelease(x,y)
		local B = self.board
		if not B.float then return end
		local click, here = B:click(x,y)
		if click then
			local T = self.timeline[self.activeTurn]
			local same,newT = self.input:mouseOff(T,here)
			if newT then
				self.activeTurn = newT.turn
				table.insert(self.timeline,newT)
				B:newTurn(newT)
			elseif not same then
				B:setDiff("select",false)
			end
		end
		B:unsetFloat()
	end
	function s:takeback()
		local turn = self.activeTurn
		if turn < 2 then return end
		local B = self.board
		turn = turn - 1
		local T = self.timeline[turn]
		table.remove(self.timeline)
		B.diff = {}
		B:newTurn(T)
		self.activeTurn = turn
	end
	return s
end
