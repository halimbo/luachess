require("display/graphics")
require("display/piecemap")
require("global")
function Board(origin,size,pos)
	local d = {}
	d.defaults = {
		style = 1,
		color = 3
	}
	d.styles = {"merida","alpha","leipzig"}
	d.colors = {
		{	cW = C.style1W,
			cB = C.style1B
		},
		{	cW = C.style2W,
			cB = C.style2B
		},
		{	cW = C.style3W,
			cB = C.style3B
		}
	}
	d.origin = origin
	d.size = size
	d.diff = {}
	d.pMap = PieceMap(pos)
	d.pieces = d.pMap:get()
	function d:setDiff(type,l,c,a)
		if l then
			self.diff[type] = { l = l, c = c, a= a }
		else
			self.diff[type] = false
		end
	end
	function d:drawSquare(h,c,alpha)
		local map = self.boardMap
		local square = self.boardSize/8
		local r,g,b = love.graphics.getColor()
		love.graphics.setColor(c.r,c.g,c.b,alpha)
		love.graphics.rectangle( "fill", map[h].x,map[h].y, square, square)
		love.graphics.setColor(r,g,b)
	end
	function d:init(x,y)
		local bX, bY = self.origin(x,y)
		local boardSize = self.size(x,y)
		self.boardSize = boardSize
		self.bX,self.bY = bX,bY
		local pngSize, pngFolder
		if boardSize <= 525 then
			pngSize = 80
			pngFolder = "80"
		else
			pngSize = 150
			pngFolder = "150"
		end
		local square = boardSize/8
		self.scale = 1/(pngSize/(square*0.96)) --tweaking scale *0.96
		self.inputMap = InputMap(square,bX,bY)
		self.pngMap = PngMap(square,bX,bY,pngSize,self.scale)
		self.boardMap = BoardMap(square,bX,bY)
		self.canvas = love.graphics.newCanvas(boardSize,boardSize)
		self.canvasMap = CanvasMap(square) 
		love.graphics.setCanvas(self.canvas)
			love.graphics.setBlendMode("alpha")
			self:drawBoard()
		love.graphics.setCanvas()
		if not (pngSize==self.pngSize) then
			self.pngSize = pngSize
			self.pngFolder = pngFolder
			self:loadpng()
		end
	end
	function d:checkMouse(mX,mY)
		local map = self.inputMap --inputMap is Love POV
		for x=1,8 do
			if map[x][1].left < mX and mX < map[x][1].right then
				for y=1,8 do
					if map[x][y].up < mY and mY < map[x][y].down then
						return x,y
					end
				end
			end
		end
		return false
	end
	function d:drawBoard()
		local map = self.canvasMap
		local square = self.boardSize/8
		local cW = self.colors[self.defaults.color].cW
		local cB = self.colors[self.defaults.color].cB
		white = true
		local r,g,b = love.graphics.getColor()
		for x=1,8 do
			for y=1,8 do
				if white then
					love.graphics.setColor (cW.r,cW.g,cW.b)
				else
					love.graphics.setColor(cB.r,cB.g,cB.b)
				end
				love.graphics.rectangle( "fill", map[x][y].x,map[x][y].y, square, square)
				white = not white
			end
			white = not white
		end
		love.graphics.setColor(r,g,b)
	end
	function d:drawPieces()
		local pos = self.pieces
		local map = self.pngMap
		local r,g,b = love.graphics.getColor()
		love.graphics.setColor (1,1,1)
		for x=1,8 do
			for y=1,8 do
				if not (pos[x][y]==0) then
					love.graphics.draw(
					self.png[pos[x][y]],
					map[x][y].x,
					map[x][y].y,
					0,
					self.scale,
					self.scale)
				end
			end
		end
		love.graphics.setColor(r,g,b)
	end
	function d:drawFloat()
		local r,g,b = love.graphics.getColor()
		love.graphics.setColor (1,1,1)
		local x,y = love.mouse.getPosition()
		local fX = x-self.pngSize/2*self.scale
		local fY = y-self.pngSize/2*self.scale
		love.graphics.draw(
			self.png[self.float.id],
			fX,
			fY,
			0,
			self.scale,
			self.scale)
		love.graphics.setColor(r,g,b)
	end
	function d:Flip()
		local function flipXY(s)
			return loc:new(8-s.x+1,8-s.y+1)
		end
		self.pMap:flipBoard()
		self.pieces = self.pMap:get()
		if self.float then
			self.float = self.pMap:float(flipXY(self.float))
			self.pieces[self.float]=0
		end
		for _,d in pairs(self.diff) do
			if d then d.l = flipXY(d.l) end
		end
	end
	function d:changeStyle()
		local n = self.defaults.style +1
		if n>#self.styles then n = 1 end
		self.defaults.style = n
		self:loadpng()
	end
	function d:changeColor()
		local n = self.defaults.color +1
		if n>#self.colors then n = 1 end
		self.defaults.color = n
		love.graphics.setCanvas(self.canvas)
			love.graphics.setBlendMode("alpha")
			self:drawBoard()
		love.graphics.setCanvas()
	end
	function d:loadpng()
		local function pngfile(color, piece)
			return tostring("pieces/"..self.styles[self.defaults.style] .. "/" .. self.pngFolder .. "/" .. color .. piece .. ".png")
		end
		self.png = {}
		self.png[1] = love.graphics.newImage(pngfile ("White", "Pawn") )
		self.png[2] = love.graphics.newImage(pngfile ("White", "Knight") )
		self.png[3] = love.graphics.newImage(pngfile ("White", "Bishop") )
		self.png[4] = love.graphics.newImage(pngfile ("White", "Rook") )
		self.png[5] = love.graphics.newImage(pngfile ("White", "Queen") )
		self.png[8] = love.graphics.newImage(pngfile ("White", "King") )
		self.png[-1] = love.graphics.newImage(pngfile ("Black", "Pawn") )
		self.png[-2] = love.graphics.newImage(pngfile ("Black", "Knight") )
		self.png[-3] = love.graphics.newImage(pngfile ("Black", "Bishop") )
		self.png[-4] = love.graphics.newImage(pngfile ("Black", "Rook") )
		self.png[-5] = love.graphics.newImage(pngfile ("Black", "Queen") )
		self.png[-8] = love.graphics.newImage(pngfile ("Black", "King") )
	end
	function d:unsetFloat()
		if not self.float then return end
		self.pieces[self.float.x][self.float.y] =  self.pMap:unFloat(self.float)
		self.float = false
	end
	function d:newFloat(l)
		self.float = self.pMap:float(l)
		self.pieces[l]=0
	end
	function d:click(mX,mY)
		local x,y = self:checkMouse(mX,mY)
		if not (x and y) then return false end
		local click = loc:new(x,y)
		local board =  self.pMap:translate(click)
		return click,board
	end
	function d:newTurn(T)
		local flip = self.pMap:rotation()
		self.pMap = PieceMap(T.pos)
		if flip then self.pMap:flipBoard() end
		self.pieces = self.pMap:get()
		if T.lastMove then
			self:setDiff("from",self.pMap:translate(T.lastMove[1]),C.black,0.4)
			self:setDiff("to",self.pMap:translate(T.lastMove[2]),C.black,0.4)
		else
			self:setDiff("from",false)
			self:setDiff("to",false)
		end
		if T.checkmate then
			self:setDiff("CM",self.pMap:translate(T.checkmate),C.red,0.4)
		elseif T.stalemate then
			self:setDiff("SM",self.pMap:translate(T.stalemate),C.blue,0.4)
		end
	end
	return d
end
