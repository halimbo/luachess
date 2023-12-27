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

----- GUI
local function reset()
	I:reset();B:setDiff("select",false)
	if B.float then B:unsetFloat() end
end

local leftIsDown = 0
local rightIsDown = 0

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
end
function love.load()
	local x,y = love.graphics.getDimensions()
	local f = love.window.getFullscreen()
	if not f then dim_x,dim_y = x,y end
	local bdim = Layout(x,y,f)
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
			local bdim = Layout(x,y,f)
			B:init(bdim)
		end
	end
	if love.keyboard.isDown("left") then
		leftIsDown = leftIsDown + dt
		if leftIsDown > 0.1 then
			reset()
			local info = G:lookback()
			if info then
				B:newPos(info)
			end
			leftIsDown = 0
		end
	elseif love.keyboard.isDown("right") then
		rightIsDown = rightIsDown + dt
		if rightIsDown > 0.1 then
			reset()
			local info = G:lookforward()
			if info then
				B:newPos(info)
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
		reset()
		local info = G:lookback()
		if info then
			B:newPos(info)
		end
		leftIsDown = -0.3
	elseif key == "right" then
		reset()
		local info = G:lookforward()
		if info then
			B:newPos(info)
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
		if not click then reset() return end
		local sel, dest = I:mouseOn(here,G:isPiece(here))
		if not sel then reset() return end
		if not dest then
			B:setDiff("select",click,C.yellow,0.7)
			if I:float() then
				B:newFloat(click)
			end
		else
			reset()
			local info = G:tryMove(sel,dest)
			if info then
				B:newPos(info)
			elseif I:mouseOn(here,G:isPiece(here)) then
				B:setDiff("select",click,C.yellow,0.7)
				if I:float() then
					B:newFloat(click)
				end
			end
		end
	elseif key == 2 then
		reset()
	end
end
function love.mousereleased(x,y,key)
	if not B.float then return end
	if key == 1 then
		local click, here = B:click(x,y)
		if not click then reset() return end
		local sel, dest = I:mouseOff(here)
		if not sel then reset() return end
		if dest then
			reset()
			local info = G:tryMove(sel,dest)
			if info then
				B:newPos(info)
			end
		end
		B:unsetFloat()
	end
end
