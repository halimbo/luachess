require("display/board")
require("game/input")
require("game/game")
require("game/standard")
require("global")
local dim_x
local dim_y
local resize
local I
local B
local G
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
end
function love.load()
	local origin = function(x,y)
		if x<y then
			return 0,math.floor(y/2-x/2+0.5)
		else
			return math.floor(x/2-y/2+0.5),0
		end
	end
	local size = function(x,y)
		return x<y and x or y
	end
	G = Game(standard())
	B = Board(origin,size,standard())
	B:init(love.graphics.getDimensions())
	if love.window.getFullscreen() then
		dim_x, dim_y = 500,500
	end
	I = click_and_drag()
end
function love.update(dt)
	if resize then
		resize = resize + dt
		if resize > 0.5 then
			resize = false
			B:init(love.graphics.getDimensions())
		end
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
		local T = G:takeback()
		if T then
			B:newTurn(T)
		end
	elseif key == "c" then
		B:changeColor()
	elseif key == "s" then
		B:changeStyle()
	elseif key == "v" then
		local f = love.window.getFullscreen()
		if f then
			love.window.setMode(dim_x,dim_y,
				{fullscreen = not f,
				resizable = true,
				minwidth = 300,
				minheight = 300})
		else
			dim_x = love.graphics.getWidth()
			dim_y = love.graphics.getHeight()
			love.window.setMode(dim_x,dim_y,
			{fullscreen = not f,
			resizable = true,
			minwidth = 300,
			minheight = 300})
		end
		resize = 0
	end
end
function love.mousepressed(x,y,key)
	if key==1 then
		local click, here = B:click(x,y)
		if not click then return end
		local sel, dest = I:mouseOn(here,G:isPiece(here))
		if not sel then I:reset();B:setDiff("select",false) return end
		if not dest then
			B:setDiff("select",click,C.yellow,0.7)
			if I:float() then
				B:newFloat(click)
			end
		else
			I:reset()
			local T = G:tryMove(sel,dest)
			if T then
				B:newTurn(T)
			end
		end
	elseif key == 2 then
		I:reset();B:setDiff("select",false)
		B:unsetFloat()
	end
end
function love.mousereleased(x,y,key)
	if key == 1 then
		local click, here = B:click(x,y)
		if not click then return end
		local sel, dest = I:mouseOff(here)
		if not sel then I:reset();B:setDiff("select",false) return end
		if dest then
			I:reset()
			local T = G:tryMove(sel,dest)
			if T then
				B:newTurn(T)
			end
		end 
	end
	B:unsetFloat()
end
