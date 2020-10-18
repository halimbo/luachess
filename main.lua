require("game/session")
require("global")
nofloat = false --deactivate floating pieces --> touch only input
local dim_x
local dim_y
local resize
local resize_dim_x
local resize_dim_y
local isFullscreen
local S
function love.draw()
	if resize then love.graphics.clear(0,0,0) return end
	local B = S.board
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
	local origin = function(x,y) if x<y then return 0,y/2-x/2 else return x/2-y/2,0 end end
	local size = function(x,y) return x<y and x or y end
	S = Session:new(origin,size)
	dim_x, dim_y = love.graphics.getDimensions()
	S.board:init(dim_x,dim_y)
end
function love.update(dt)
	if resize then
		resize = resize + dt
		if resize > 0.5 then
			resize = false
			S.board:init(resize_dim_x,resize_dim_y)
		end
	end
end
function love.resize(x,y)
	resize = 0
	resize_dim_x = x
	resize_dim_y = y
end
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "f" then
		S.board:Flip()
	elseif key == "left" then
		S:takeback()
	elseif key == "c" then
		S.board:changeColor()
	elseif key == "s" then
		S.board:changeStyle()
	elseif key == "v" then
		if isFullscreen then
			love.window.setMode(dim_x,dim_y,{fullscreen = false,resizable = true})
			isFullscreen = false
			resize_dim_x = dim_x
			resize_dim_y = dim_y
		else
			dim_x = love.graphics.getWidth()
			dim_y = love.graphics.getHeight()
			love.window.setMode(dim_x,dim_y,{fullscreen = true,resizable = true})
			isFullscreen = true
			resize_dim_x = love.graphics.getWidth()
			resize_dim_y = love.graphics.getHeight()
		end
		resize = 0
	end
end
function love.mousepressed(x,y,key)
	if key==1 then
		S:mouse(x,y)
	elseif key == 2 and not nofloat then
		S.board:unsetFloat()
	end
end
function love.mousereleased(x,y,key)
	if key == 1 then
		S:mouseRelease(x,y)
	end
end
