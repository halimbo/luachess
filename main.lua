require("display/board")
require("display/interface")
require("display/colors")
require("game/input")
require("game/game")
require("game/standard")
require("global")

-- Window
local dim_x
local dim_y
local resize

---- Chess
local I
local B
local G
local H = {}

----- GUI
local leftIsDown = 0
local rightIsDown = 0
local M
local LOG = {} 
local function cut_log(turn)
	local n = #LOG
	while n>=turn do
		table.remove(LOG)
		n=n-1
	end
end

function love.draw()
	if resize then love.graphics.clear(0,0,0) return end
	love.graphics.setColor(1,1,1)
	love.graphics.setBlendMode("alpha","premultiplied")
	love.graphics.draw(B.canvas,B.bX,B.bY)
	for _,d in pairs(B.diff) do
		if d then B:drawSquare(d.l,d.c,d.a) end
	end
	B:drawPieces()
	if B.float then
		B:drawFloat()
	end
	love.graphics.setBlendMode("alpha")
	if M then
		M:draw()
	end
end
function love.load()
	font = love.graphics.newFont("display/Roboto-Regular.ttf",19)
	fontPaddingX = math.floor(font:getWidth("6")/2+0.5)
	rowMoveWidth = math.floor(font:getWidth("6.")+0.5) + fontPaddingX*2
	rowWidth = rowMoveWidth + math.floor(font:getWidth("Qxh6##+")*2+0.5) + fontPaddingX
	fontHeight = font:getHeight()
	rowHeight = math.floor(fontHeight+fontHeight/4+0.5)
	local x,y = love.graphics.getDimensions()
	local f = love.window.getFullscreen()
	if not f then dim_x,dim_y = x,y end
	local bdim, ld = Layout(x,y,f)
	if ld then
		M = Movelist(ld)
	end
	love.graphics.setFont(font)
	G = Game(standard())
	B = Board(standard())
	B:init(bdim)
	I = click_and_drag()
end
function love.update(dt)
	if resize then
		resize = resize + dt
		if resize > 0.5 then
			resize = false
			local x,y = love.graphics.getDimensions()
			local f = love.window.getFullscreen()
			local bdim,ld = Layout(x,y,f)
			if ld then
				M = Movelist(ld)
				local move = 1
				for i,s in ipairs(LOG) do
					M:add(math.floor(move),s,i+1) --button No°1 --> Position No°2
					move = move + 0.5
				end
				M:scroll(G.current.turn-1)
			else
				M = false
			end
			B:init(bdim)
		end
	end
	if love.keyboard.isDown("left") then
		leftIsDown = leftIsDown + dt
		if leftIsDown > 0.1 then
			I:reset();B:setDiff("select",false)
			if B.float then B:unsetFloat() end
			local info = G:lookback()
			if info then
				B:newPos(info)
				if M then
					M:scroll(info.lastTurn)
				end
			end
			leftIsDown = 0
		end
	elseif love.keyboard.isDown("right") then
		rightIsDown = rightIsDown + dt
		if rightIsDown > 0.1 then
			I:reset();B:setDiff("select",false)
			if B.float then B:unsetFloat() end
			local info = G:lookforward()
			if info then
				B:newPos(info)
				if M then
					M:scroll(info.lastTurn)
				end
			end
			rightIsDown = 0
		end
	else
		rightIsDown = 0
		leftIsDown = 0
	end
end
function love.resize(x,y)
	resize = 0
end
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "f" then
		B:Flip()
	elseif key == "left" then
		I:reset();B:setDiff("select",false)
		if B.float then B:unsetFloat() end
		local info = G:lookback()
		if info then
			B:newPos(info)
			if M then
				M:scroll(info.lastTurn)
			end
		end
		leftIsDown = -0.3
	elseif key == "right" then
		I:reset();B:setDiff("select",false)
		if B.float then B:unsetFloat() end
		local info = G:lookforward()
		if info then
			B:newPos(info)
			if M then
				M:scroll(info.lastTurn)
			end
		end
		rightIsDown = -0.3
	elseif key == "c" then
		B:changeColor()
	elseif key == "s" then
		B:changeStyle()
	elseif key == "v" then
		local f = love.window.getFullscreen()
		if f then
			local dim_x,dim_y = dim_x or 400,dim_y or 500
			love.window.setMode(dim_x,dim_y,
				{fullscreen = not f,
				resizable = true,
				minwidth = 500,
				minheight = 400})
		else
			dim_x = love.graphics.getWidth()
			dim_y = love.graphics.getHeight()
			love.window.setMode(dim_x,dim_y,
			{fullscreen = not f,
			resizable = true,
			minwidth = 500,
			minheight = 400})
		end
		resize = 0
	end
end
function love.mousepressed(x,y,key)
	if key==1 then
		local click, here = B:click(x,y)
		if not click then
			I:reset()
			B:setDiff("select",false)
			local turn = M:click(x,y)
			if turn then
				local info = G:jumpto(turn)
				B:newPos(info)
			end
			return
		end
		local sel, dest = I:mouseOn(here,G:isPiece(here))
		if not sel then I:reset();B:setDiff("select",false) return end
		if not dest then
			B:setDiff("select",click,C.yellow,0.7)
			if I:float() then
				B:newFloat(click)
			end
		else
			I:reset();B:setDiff("select",false)
			local info, h, seen = G:tryMove(sel,dest)
			if info then
				B:newPos(info)
				if h then
					table.insert(H,h)
					cut_log(h.split)
					table.insert(LOG,info.str)
					if M then
						M:cut(h.split)
						M:add(info.lastMove,info.str,info.turn)
					end
				elseif seen then
					M:scroll(info.lastTurn)
				else
					table.insert(LOG,info.str)
					if M then
						M:add(info.lastMove,info.str,info.turn)
					end
				end
			elseif I:mouseOn(here,G:isPiece(here)) then
				B:setDiff("select",click,C.yellow,0.7)
				if I:float() then
					B:newFloat(click)
				end
			elseif B.float then
				B:unsetFloat()
			end
		end
	elseif key == 2 then
		I:reset();B:setDiff("select",false)
		B:unsetFloat()
	end
end
function love.mousereleased(x,y,key)
	if key == 1 and B.float then
		local click, here = B:click(x,y)
		if not click then return end
		local sel, dest = I:mouseOff(here)
		if not sel then I:reset();B:setDiff("select",false) return end
		if dest then
			I:reset();B:setDiff("select",false)
			local info,h,seen = G:tryMove(sel,dest)
			if info then
				B:newPos(info)
				if h then
					table.insert(H,h)
					cut_log(h.split)
					table.insert(LOG,info.str)
					if M then
						M:cut(h.split)
						M:add(info.lastMove,info.str,info.turn)
					end
				elseif seen then
					M:scroll(info.lastTurn)
				else
					table.insert(LOG,info.str)
					if M then
						M:add(info.lastMove,info.str,info.turn)
					end
				end
			end
		end
		B:unsetFloat()
	elseif key == 2 and B.float then
		B:unsetFloat()
	end
	B:unsetFloat()
end
