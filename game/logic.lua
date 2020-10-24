require("global")
require("game/move")
require("game/attack")
local directions = {}
directions[3] = {2,4,6,8}
directions[4] = {1,3,5,7}
directions[5] = {1,2,3,4,5,6,7,8}
function findKing(pos,turn)
	local king
	if hasTurn(8,turn) then
		king = 8
	else
		king = -8
	end
	local kingPos
	do8x8break(pos,function(s,l)
		if s==king then
			 kingPos = l
			 return true
		end
	end)
	return kingPos
end
local function superVision(l,dir)
	local square = l
	local v = {}
	local function go()
		local s = square:move(dir)
		if not s then return end
		table.insert(v,s)
		square = s
		return go()
	end
	go()
	return v
end
local function aligned(a,b)
	for i=1,8 do
		local vision = superVision(a,i)
		for _,square in ipairs(vision) do
			if square==b then return i end
		end
	end
	return false
end
local function castles_free(pos,l,x,y,freshmap)
	local ks,qs = false,false
	if freshmap[l] and freshmap[8][y] and pos[7][y]==0 and pos[6][y]==0 then
		ks = {l,loc:new(x+1,y),loc:new(x+2,y)}
	end
	if freshmap[l] and freshmap[1][y] and pos[4][y]==0 and pos[3][y]==0 and pos[2][y]==0 then
		qs = {l,loc:new(x-1,y),loc:new(x-2,y),loc:new(x-3)}
	end
	return ks,qs
end
local function castles_safe(atk,cs)
	for _,a in pairs(atk) do
		if contains(cs,a) then
			return false
		end
	end
	return true
end
local function attackgen(position,turn)
	local atk={}
	local pos = Map:copy(position)
	local kingPos = findKing(pos,turn+1) --remove enemy king for xray in check analysis
	pos[kingPos] = 0
	scrollTurn(pos,turn,function(s,l)
		if abs(s) == 1 then
			local moves = pawnAT(pos,l)
			for _,m in ipairs(moves) do
				local a = m
				a.id = s
				a.loc = l
				table.insert(atk,a)
			end
		elseif abs(s) == 2 then
			local moves = knightAT(pos,l)
			for _,m in ipairs(moves) do
				local a = m
				a.id = s
				a.loc = l
				table.insert(atk,a)
			end
		elseif abs(s) == 3 or abs(s)==4 or abs(s)==5 then
			for _,d in ipairs(directions[abs(s)]) do
				local mlist = visionAT(pos,l,d)
				for _,m in ipairs(mlist) do
					local a = m
					a.id = s
					a.loc = l
					a.dir = d
					table.insert(atk,a)
				end
			end
		elseif abs(s) == 8 then
			local moves = kingAT(pos,l,d)
			for _,m in ipairs(moves) do
				local a = m
				a.id = s
				a.loc = l
				table.insert(atk,a)
			end
		end
	end)
	return atk
end
local function nextPiece(pos,l,dir)
	local s = l:move(dir)
	while s do
		if pos[s]==0 then
			s = s:move(dir)
		else
			return s
		end
	end
	return false
end
local function reverse(dir)
	local r = dir - 4
	if r <= 0 then
		return 8 - abs(r)
	else
		return r
	end
end
--pinned pieces are able to move inside the pin 
local function pinned(pos,pc,king)
	local toKing = aligned(pc,king)
	local kingID = pos[king]
	if not toKing then
		return false
	elseif nextPiece(pos,pc,toKing) == king then
		local away = reverse(toKing)
		local otherSide = nextPiece(pos,pc,away)
		if not otherSide then return false end
		if opponents(pos[otherSide],kingID) then
			local enemy = abs(pos[otherSide])
			if (enemy==3 or enemy==4 or enemy==5) and contains(directions[enemy],toKing) then
				print(names[abs(pos[pc])].." on "..letters[pc.x]..pc.y,"pinned by ", names[enemy].." on "..letters[otherSide.x]..otherSide.y)
				local avail = {}
				local s = pc:move(away)
				while not (s==otherSide) do
					table.insert(avail,s)
					s = s:move(away)
				end
				table.insert(avail,otherSide)
				local s = pc:move(toKing)
				while not (s==king) do
					table.insert(avail,s)
					s = s:move(toKing)
				end
				return avail
			end
		end
	end
	return false
end
local function filterPin(mlist,insidePin)
	local filtered = {}
	for  i,move in ipairs(mlist) do
		if contains(insidePin,move) then
			table.insert(filtered,move)
		end
	end
	return filtered
end
function possible(pos,turn,freshmap,eptoken)
	local enpasMap
	if eptoken then
		enpasMap = Map:new(0)
		do8x8(pos,function(s,l) enpasMap[l] = s end)
		enpasMap[eptoken] = eptoken.id
		--invisible pawn 
	end
	local p = Map:new(false)
	scrollTurn(pos,turn,function(s,l,x,y)
		if abs(s) == 1 then
			p[l] = { id = s}
			p[l].moves = pawnM(enpasMap or pos,l,freshmap[l])
		elseif abs(s) == 2 then
			p[l] = { id = s }
			p[l].moves = knightM(pos,l)
		elseif abs(s) == 3 or abs(s)==4 or abs(s)==5 then
			local moves = {}
			for _,d in ipairs(directions[abs(s)]) do
				local mlist = visionM(pos,l,d)
				for _,m in ipairs(mlist) do
					table.insert(moves,m)
				end
			end
			p[l] = { id = s }
			p[l].moves = moves
		elseif abs(s) == 8 then
			local atk = attackgen(pos,turn+1)
			p[l] = { id = s }
			p[l].moves = kingM(pos,l,atk)
			local ks, qs = castles_free(pos,l,x,y,freshmap) --ks,qs --> squares that must not be attacked
			if ks and castles_safe(atk,ks) then
				local n = #p[l].moves+1
				p[l].moves[n] = loc:new(7,y)
				p[l].moves[n].castles = {loc:new(8,y),ks[2]} --rook move
			end
			if qs and castles_safe(atk,qs) then
				local n = #p[l].moves+1
				p[l].moves[n] = loc:new(3,y)
				p[l].moves[n].castles = {loc:new(1,y),qs[2]} --rook move
			end
		end
	end)
	local kingPos = findKing(pos,turn)
	scrollTurn(pos,turn,function(s,l)
		local pin = pinned(pos,l,kingPos)
		if pin then
			p[l].moves = filterPin(p[l].moves,pin)
		end
	end)
	return p
end
function isCheck(pos,turn,freshmap,eptoken)
	local check
	local available = Map:new(false)
	local oppAT = attackgen(pos,turn+1)
	local kingPos = findKing(pos,turn)
	for i,move in ipairs(oppAT) do
		if move == kingPos then
			print("check")
			if check then
				print("double check")
				escape = kingM(pos,kingPos,oppAT)
				if #escape==0 then
					print("checkmate")
					return true,false
				else
					for _,m in ipairs(escape) do
						print("escape to "..letters[m.x]..m.y)
					end
					available = Map:new(false)
					available[kingPos] = {}
					available[kingPos].id = pos[kingPos]
					available[kingPos].moves = escape
					return true, available
				end
			end
			local P = possible(pos,turn,freshmap,eptoken)
			local kill
			local blockable
			local escape
			do8x8(P,function(pc,l,x,y)
				if pc and not (abs(pc.id)==8) then
					if contains(pc.moves, move.loc) then
						print(letters[l.x]..l.y,"can take on ", letters[move.loc.x]..move.loc.y)
						if not available[l] then
							available[l] = {}
							available[l].id = pc.id
							available[l].moves = {}
						end
						table.insert(available[l].moves,move.loc)
						kill = true
					end
				end
			end)
			local block_check
			if abs(move.id) == 1 or abs(move.id) == 2 then
				block_check = false
			else
				block_check = true
			end
			if block_check then
				local blocks = {}
				local _r = i - 1 --going backwards on the atk-list
				while _r>0 and oppAT[_r].dir == move.dir and oppAT[_r].id == move.id do
					table.insert(blocks,oppAT[_r])
					_r = _r - 1
				end
				if #blocks==0 then
					blockable = false
				else
					do8x8(P,function(pc,l)
						if pc and not ( abs(pc.id)==8 ) then
							for _,b in ipairs(blocks) do
								if contains(pc.moves, b) then
									blockable = true
									print(letters[l.x]..l.y,"can block on ", letters[b.x]..b.y)
									if not available[l] then
										available[l] = {}
										available[l].id = pos[l]
										available[l].moves = {}
									end
									table.insert(available[l].moves, b)
								end
							end
						end
					end)
				end
			end
			escape = kingM(pos,kingPos,oppAT)
			if #escape ==0 then
				escape = false
			else
				for _,m in ipairs(escape) do
					print("escape to "..letters[m.x]..m.y)
				end
				if not available[kingPos] then
					available[kingPos] = {}
					available[kingPos].id = pos[kingPos]
					available[kingPos].moves = {}
				end
				for _,e in ipairs(escape) do
					table.insert(available[kingPos].moves, e)
				end
			end
			if not (escape or blockable or kill) then
				print("checkmate")
				return true,false
			else
				check = true
			end
		end
	end
	if check then
		return true,available
	else
		return false
	end
end
local function compare(a,b)
	local same = true
	do8x8break(a, function (s,l) if not (s==b[l]) then same = false return true end end)
	return same
end
local function drawRepetition(timeline)
	local count = 1
	local i = #timeline
	local turn = timeline[i]
	local c = i-2
	local comp = timeline[c]
	while comp do
		if compare(turn.pos,comp.pos) then
			count= count+1
		end
		c = c - 2
		comp = timeline[c]
	end
	if count > 2 then return true
	else return false end
end
local function endless(T,from,to)
	if T.pos[to] == 0 or not (abs(T.pos[from])==1) then
		return true
	else
		return false
	end
end
function check_draw(timeline,draw50)
	local T = timeline[#timeline-1]
	local newT = timeline[#timeline]
	if endless(T,newT.lastMove[1],newT.lastMove[2]) then
		draw50 = draw50 +1
	else
		draw50 = 0
	end
	if draw50 >= 100 then
		print("Draw by 50-move rule")
	end
	if drawRepetition(timeline) then
		print("Draw by threefold repetition")
	end
	return draw50
end
