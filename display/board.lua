require("display/graphics")
require("display/piecemap")
require("global")
function Board(pos)
	local d = {}
	d.settings = {
		style = 1,
		color = 2
	}

    local shader_code = [[
        extern number time;
        extern vec2 squareSize;
        extern number isHighlight;
        extern vec2 boardOffset;

        float rand(vec2 co) {
            return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 local_coords = screen_coords - boardOffset;
            vec2 uv = mod(local_coords, squareSize) / squareSize;

            vec2 centered = abs(uv - 0.5);
            float boxDist = max(centered.x, centered.y);

            // Softer, wider falloff for an airy, whispered look
            float tileMask = 1.0 - smoothstep(0.25, 0.49, boxDist);

            float pulse = 1.0;
            if (isHighlight > 0.5) {
                vec2 gridId = floor(local_coords / squareSize);
                float phase = rand(gridId) * 6.2831;

                // LOWER BASELINE: Ranges between 0.1 and 0.5 opacity. 
                // This keeps it feeling like a faint shimmer rather than a flashlight.
                pulse = 0.3 + 0.2 * sin((time * 6.0) + phase);
            }

            return vec4(color.rgb, color.a * tileMask * pulse);
        }
    ]]

    d.squareShader = love.graphics.newShader(shader_code)
    d.shaderTime = 0

	d.styles = {"merida","alpha","leipzig"}
        d.colors = {
            {    cW = C.slate_light,
                 cB = C.slate_dark
            },
		{	cW = C.style1W,
			cB = C.style1B
		},
		{	cW = C.style2W,
			cB = C.style2B
		},
		{	cW = C.style3W,
			cB = C.style3B
		},
		{	cW = C.style3W,
			cB = C.lightblue
		}
	}
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

    function d:drawSquare(h, c, alpha, is_animated)
        local map = self.boardMap
        local square = self.squareSize
        local r, g, b = love.graphics.getColor()

        love.graphics.setColor(c.r, c.g, c.b, alpha)

        if is_animated then
            -- The Cyberpunk Shader (Vignette + Pulse) exclusively for raycasts
            self.squareShader:send("squareSize", {square, square})
            self.squareShader:send("boardOffset", {self.bX, self.bY})
            self.squareShader:send("time", self.shaderTime)
            self.squareShader:send("isHighlight", 1.0)

            love.graphics.setShader(self.squareShader)
            love.graphics.rectangle("fill", map[h].x, map[h].y, square, square)
            love.graphics.setShader()
        else
            -- Vanilla Flat Rectangle Fill for select, from, and to
            love.graphics.rectangle("fill", map[h].x, map[h].y, square, square)
        end

        love.graphics.setColor(r, g, b)
    end

	function d:init(t)
		local boardSize = t.size
		local bX,bY = t.ox,t.oy
		self.boardSize = t.size
		self.bX,self.bY = t.ox,t.oy
		local pngSize, pngFolder
		if boardSize <= 525 then
			pngSize = 80
			pngFolder = "80"
		else
			pngSize = 150
			pngFolder = "150"
		end
		local square = math.floor(boardSize/8+0.5)
		self.squareSize = square
		self.scale = 1/(pngSize/(square*0.96)) --scale *0.96
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
		local square = self.squareSize
		local cW = self.colors[self.settings.color].cW
		local cB = self.colors[self.settings.color].cB
		white = true
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
	end
	function d:drawPieces()
		local pos = self.pieces
		local map = self.pngMap
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
	end
	function d:drawFloat()
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
		local n = self.settings.style +1
		if n>#self.styles then n = 1 end
		self.settings.style = n
		self:loadpng()
	end
	function d:changeColor()
		local n = self.settings.color +1
		if n>#self.colors then n = 1 end
		self.settings.color = n
		love.graphics.setCanvas(self.canvas)
			love.graphics.setBlendMode("alpha")
			self:drawBoard()
		love.graphics.setCanvas()
	end
	function d:loadpng()
		local function pngfile(color, piece)
			return tostring("pieces/"..self.styles[self.settings.style] .. "/" .. self.pngFolder .. "/" .. color .. piece .. ".png")
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
		self.pieces[self.float] =  self.pMap:unFloat(self.float)
		self.float = false
	end
	function d:newFloat(l)
		if self.float then self:unsetFloat() end
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
	function d:newPos(i)
		local flip = self.pMap:rotation()
		self.pMap = PieceMap(i.pos)
		if flip then self.pMap:flipBoard() end
		self.pieces = self.pMap:get()
		self.diff = {}
		if i.highlight then
			self:setDiff("from",self.pMap:translate(i.highlight[1]),C.black,0.4)
			self:setDiff("to",self.pMap:translate(i.highlight[2]),C.black,0.4)
		end
		if i.checkmate then
			self:setDiff("king",self.pMap:translate(i.kingToMove),C.red,0.4)
		elseif i.draw then
			self:setDiff("king",self.pMap:translate(i.kingToMove),C.brown,0.4)
		end
	end
	return d
end
