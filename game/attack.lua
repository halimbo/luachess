function visionAT(pos,l,dir)
	local square = l
	local a = {}
	local function go()
		local s = square:move(dir)
		if not s then return end
		if pos[s]==0 then
			table.insert(a,s)
			square = s
			return go()
		else
			table.insert(a,s)
			return
		end
	end
	go()
	return a
end
function pawnAT(pos,l)
	local id = pos[l]
	local a = {}
	if id < 0 then
		take = {4,6} 
	else
		take = {2,8}
	end
	for _,dir in pairs(take) do
		local s = l:move(dir)
		if s then
			table.insert(a,s)
		end
	end
	return a
end
function knightAT(pos,l)
	local dir = 9 --9-16 are knight moves
	local a = {}
	local function jump()
		if dir > 16 then return end
		local s = l:move(dir)
		if s then
			table.insert(a,s)
		end
		dir = dir + 1
		return jump()
	end
	jump()
	return a
end
function kingAT(pos,l)
	local dir = 1
	local a = {}
	local function go()
		if dir > 8 then return end
		local s = l:move(dir)
		if s then
			table.insert(a,s)
		end
		dir = dir + 1
		return go()
	end
	go()
	return a
end
