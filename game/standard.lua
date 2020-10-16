require("global")
--0 -> empty
--1 -> pawn
--2 -> knight
--3 -> bishop
--4 -> rook
--5 -> queen
--8 -> king
function standard()
	local pos = Map:new(0)
	local setup = {}
	setup[1] = {4,2,3,5,8,3,2,4}
	setup[2] = {1,1,1,1,1,1,1,1}
	setup[7] = {-1,-1,-1,-1,-1,-1,-1,-1}
	setup[8] = {-4,-2,-3,-5,-8,-3,-2,-4}
	for y,s in pairs(setup) do
		for x = 1,8 do
			pos[x][y] = s[x]
		end
	end
	return pos
end
