require("global")
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
function PngMap(square,bX,bY,pngSize,scale)
	local m= Map:new{}
	local cX,cY = bX, bY
	for x=1,8 do
		for y=1,8 do
			m[x][y].x = cX + square/2 - (pngSize/2*scale)
			m[x][y].y = cY + square/2 - (pngSize/2*scale)
			cY = cY + square
		end
		cY = bY
		cX = cX + square
	end
	return m
end
function ArrowMap(bX,bY,square)
	local m = Map:new{}
	local cX,cY = bX,bY
	for x=1,8 do
		for y=1,8 do
			m[x][y].x = cX+square/2
			m[x][y].y = cY+square/2
			cY = cY+square
		end
		cY = bY
		cX = cX+square
	end
	return m
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
