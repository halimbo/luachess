require("global")
function normal(pos,l,s)
	local map = Map:copy(pos)
	local str
	if map[s] == 0 then
		str = names[abs(map[l])]..letters[s.x]..s.y
	elseif abs(map[l]) == 1 then
		str = letters[l.x].."x"..letters[s.x]..s.y
	else
		str = names[abs(map[l])].."x"..letters[s.x]..s.y
	end
	map[s] = map[l]
	map[l] = 0
	print(str)
	return map
end
function castles(pos,l,s,rook0,rook)
	local map = Map:copy(pos)
	map[s] = map[l]
	map[l] = 0
	map[rook] = map[rook0]
	map[rook0] = 0
	if rook0.x == 8 then
		print("0-0")
	else
		print ("0-0-0")
	end
	return map
end
function enpas(pos,l,s,e)
	local map = Map:copy(pos)
	map[s] = map[l]
	map[l] = 0
	map[e] = 0
	print( letters[l.x].."x"..letters[s.x]..s.y )
	return map
end
function queening(pos,l,s,queen)
	local map = Map:copy(pos)
	map[s] = queen
	map[l] = 0
	print( letters[s.x]..s.y.."=Q")
	return map
end
