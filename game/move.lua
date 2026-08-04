require("global")
function visionM(pos,l,dir)
	local square = l
	local id = pos[l]
	local m = {}
	local function go()
		local s = square:move(dir)
		if not s then return end
		if pos[s]==0 then
			table.insert(m,s)
			square = s
			return go()
		elseif opponents(id,pos[s]) then
			table.insert(m,s)
			return
		end
	end
	go()
	return m
end
function pawnM(pos,l,fresh)
	local id = pos[l]
	local m = {}
	local forw
	if id < 0 then
		forw = 5
		take = {4,6} 
	else
		forw = 1
		take = {2,8}
	end
	local s = l:move(forw)
	if s and pos[s]==0 then
		table.insert(m,s)
		if fresh then
			s = s:move(forw)
			if s and pos[s]==0 then
				table.insert(m,s)
			end
		end
	end
	for _,dir in pairs(take) do
		local t = l:move(dir)
		if t and not (pos[t]==0) and opponents(id,pos[t]) then
			table.insert(m,t)
			if abs(pos[t])==7 then m[#m].enpas = true end --7 is en Passant
		end
	end
	return m
end
function knightM(pos,l)
	local id = pos[l]
	local dir = 9 --9-16 are knight moves
	local m = {}
	local function jump()
		if dir > 16 then return end
		local s = l:move(dir)
		if s and ( pos[s]==0 or opponents(id,pos[s]) ) then
			table.insert(m,s)
		end
		dir = dir + 1
		return jump()
	end
	jump()
	return m
end
function kingM(pos,l,at)
	local dir = 1
	local id = pos[l]
	local try = {}
	local function go()
		if dir > 8 then return end
		local s = l:move(dir)
		if s and ( pos[s]==0 or opponents(id,pos[s]) ) then
			table.insert(try,s)
		end
		dir = dir + 1
		return go()
	end
	go()
	local legal = {}
	for _,move in ipairs(try) do
		if not contains(at,move) then
			table.insert(legal,move)
		end
	end
	return legal
end
