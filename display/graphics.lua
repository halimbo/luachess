require("global")
function BoardMap(square,bX,bY)
	local bMap = Map:new{}
	local cX,cY = 0,0
	for x=1,8 do
		for y=1,8 do
			bMap[x][y].x = cX+bX
			bMap[x][y].y = cY+bY
			cY = cY + square
		end
		cY = 0
		cX = cX + square
	end
	return bMap
end
function CanvasMap(square)
	local cMap = Map:new{}
	local cX,cY = 0,0
	for x=1,8 do
		for y=1,8 do
			cMap[x][y].x = cX
			cMap[x][y].y = cY
			cY = cY + square
		end
		cY = 0
		cX = cX + square
	end
	return cMap
end
function PngMap(square,bX,bY,pngSize,scale)
	local map = Map:new{}
	local cX,cY = bX, bY
	for x=1,8 do
		for y=1,8 do
			map[x][y].x = cX + square/2 - (pngSize/2*scale)
			map[x][y].y = cY + square/2 - (pngSize/2*scale)
			cY = cY + square
		end
		cY = bY
		cX = cX + square
	end
	return map
end
function ArrowMap(canvasX,canvasY,square)
	local map = Map:new{}
	local cX,cY = canvasX,canvasY
	for x=1,8 do
		for y=1,8 do
			map[x][y].x = cX+square/2
			map[x][y].y = cY+square/2
			cY = cY+square
		end
		cY = canvasY
		cX = cX+square
	end
	return map
end
function InputMap(square,cX,cY) 	--inputMap shows square from love's POVS
	local m = Map:new{}
	local startY = cY
	for x=1,8 do
		for y=1,8 do
			m[x][y].left = cX
			m[x][y].right = cX + square
			m[x][y].up = cY
			m[x][y].down = cY + square
			cY = cY + square
		end
		cY = startY
		cX = cX + square
	end
	return m
end
