--global variables (font*,row*)
function Layout(x,y,f,zen)
	local ROWS = 1
	local LINES = 3
	local b = {}
	local mlist = {}
	local horizontal = x>y and true or false
	if not f and horizontal then
		b.size = y
		b.ox,b.oy = 0,0
		mlist.ox = y
		mlist.oy = 0
		mlist.w = x-y
		mlist.h = y
		if zen or (mlist.w<rowWidth*ROWS or mlist.h<rowHeight*LINES) then
			b.ox,b.oy = math.floor(x/2-y/2+0.5),0
			mlist = false
		else
			mlist.horizontal = horizontal
		end
	elseif not f and not horizontal then
		b.size = x
		b.ox,b.oy = 0,0
		mlist.ox = 0
		mlist.oy = x
		mlist.w = x
		mlist.h = y-x
		if zen or (mlist.w<rowWidth*ROWS or mlist.h<rowHeight*LINES) then
			b.ox,b.oy = 0,math.floor(y/2-x/2+0.5)
			mlist = false
		else
			mlist.horizontal = horizontal
		end
	elseif f and horizontal then
		b.size = y
		b.ox,b.oy = math.floor(x/2-y/2+0.5),0
		if zen then
			mlist = false
		else
		-- tbc
			mlist.ox = b.ox+b.size
			mlist.oy = 0
			mlist.w = x-y
			mlist.h = y
			mlist.horizontal = horizontal
		end
	elseif f and not horizontal then
		b.size = x
		b.ox,b.oy = 0,math.floor(y/2-x/2+0.5)
		if zen then
			mlist = false
		else
		-- tbc
			mlist.ox = 0
			mlist.oy = b.oy+b.size
			mlist.w = x
			mlist.h = y-x
			mlist.horizontal = horizontal
		end
	end
	return b,mlist
end

local function MoveButton(x,y,w,h,color,str,turn)
	m = {}
	m.x = x
	m.y = y
	m.w = w
	m.h = h
	m.color = color
	m.str = str
	m.turn = turn
	m.fX = math.floor(x+fontPaddingX)
	m.fY = math.floor(y+h/2-fontHeight/2)
	function m:draw()
		love.graphics.setColor(self.color.r,self.color.g,self.color.b)
		love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
		love.graphics.setColor(1,1,1)
		love.graphics.print(self.str,self.fX,self.fY)
	end
	function m:dump()
		return self.str
	end
	return m
end
local function Row(x,y,w,h)
	local r = {}
	r.moves = {}
	r.x = x
	r.y = y
	r.w = w
	r.h = h
	function r:add(str,turn)
		if #self.moves == 0 then
			local button = MoveButton(
				self.x,
				self.y,
				self.w/2,
				self.h,
				C.black,
				str,
				turn
			)
			table.insert(self.moves,button)
			return button
		elseif #self.moves == 1 then
			local button = MoveButton(
				self.x+self.w/2,
				self.y,
				self.w/2,
				self.h,
				C.black,
				str,
				turn
			)
			table.insert(self.moves,button)
			return button
		else
			return false
		end
	end
	function r:delete()
		table.remove(self.moves)
		if #self.moves==0 then return true else return false end
	end
	function r:draw()
		for _,m in ipairs(self.moves) do
			m:draw()
		end
	end
	return r
end
local function Page(x,y,w,h)
	local p = {}
	p.x = x
	p.y = y
	p.w = w
	p.h = h
	p.startY = y
	p.startX = x
	p.rows = {}
	function p:add(str,turn)
		if #self.rows==0 then
			table.insert(p.rows,Row(x,y,rowWidth,rowHeight))
		end
		local button = self.rows[#self.rows]:add(str,turn)
		if button then return button end
		if (self.y+rowHeight*2) > self.startY+self.h then
			self.lastPossibleY = self.y
			if self.x+rowWidth*2 > self.startX+self.w then
				return false
			end
			self.x = self.x + rowWidth
			self.y = self.startY
			table.insert(p.rows,Row(self.x,self.y,rowWidth,rowHeight))
			button = self.rows[#self.rows]:add(str,turn)
			return button
		end
		self.y = self.y+rowHeight
		table.insert(p.rows,Row(self.x,self.y,rowWidth,rowHeight))
		button = self.rows[#self.rows]:add(str,turn)
		return button
	end
	function p:delete()
		local empty = self.rows[#self.rows]:delete()
		if empty then
			table.remove(self.rows)
			if #self.rows==0 then
				return true
			else
				self.y = self.y-rowHeight
				if self.y < self.startY then
					self.x = self.x-rowWidth
					self.y = self.lastPossibleY
					return false
				end
			end
		end
		return false
	end
	function p:draw()
		for _,r in ipairs(self.rows) do
			r:draw()
		end
	end
	return p
end
function Movelist(t)
	local mlist = {}
	mlist.pages = {}
	mlist.sum = 0
	function mlist:add(str,turn)
		if #self.pages==0 then
			table.insert(mlist.pages,Page(t.ox,t.oy,t.w,t.h))
			self.show = #self.pages
		end
		local button = self.pages[#self.pages]:add(str,turn)
		if not button then
			table.insert(self.pages,Page(t.ox,t.oy,t.w,t.h))
			self.show = #self.pages
			button = self.pages[self.show]:add(str,turn)
		end
		if self.cursor then
			self.cursor.color = C.black
		end
		button.color = C.grey
		self.cursor = button
		self.sum=self.sum+1
	end
	function mlist:scroll(n)
		if #self.pages==0 then print("no pages but cursor?") return false end
		if self.cursor then
			self.cursor.color = C.black
			if n==0 then self.cursor= false return end
		end
		local row
		local button
		local page
		if #self.pages==1 then
			row  = math.floor(n/2+0.5)
			button = n%2==1 and 1 or 2
			self.cursor = self.pages[1].rows[row].moves[button]
			self.cursor.color = C.grey
		elseif #self.pages>1 then
			local pageCount = #self.pages[1].rows
			local fullPages = math.floor(n/(pageCount*2))
			if fullPages>0 then
				row = math.floor(n%(pageCount*(fullPages))/2+0.5)
			else
				row = math.floor(n/2+0.5)
			end
			if row==0 then 
				page = fullPages
				row = pageCount
			else
				page = fullPages + 1
			end
			button = n%2==1 and 1 or 2
			print("page",page)
			print("row",row)
			print("button",button)
			self.cursor = self.pages[page].rows[row].moves[button]
			self.cursor.color = C.grey
			self.show = page
		end
	end
	function mlist:draw()
		if self.show then
			self.pages[self.show]:draw()
		end
	end
	function mlist:cut(turn)
		local i = self.sum
		while i>=turn do
			self:delete()
			i=i-1
		end
	end
	function mlist:delete()
		if self.sum==0 then print("is already empty") return false end
		local empty = self.pages[#self.pages]:delete()
		if empty then
			table.remove(self.pages)
			if #self.pages==0 then
				self.sum = self.sum - 1
				self.show= false
				return
			end
		end
		self.show = #self.pages
		self.sum = self.sum - 1
	end
	return mlist
end
