require("global")
function visionM(pos, l, dir)
    local square = l
    local id = pos[l]
    local m = {}

    local function go()
        local s = square:move(dir)
        if not s then return end

        -- HOOK: If running in a coroutine, pause and send the coordinate back to LÖVE
        if coroutine.running() then
            coroutine.yield(s, "scanning")
        end

        if pos[s] == 0 then
            table.insert(m, s)
            square = s
            return go()
        elseif opponents(id, pos[s]) then
            -- HOOK: Tag enemies we hit
            if coroutine.running() then
                coroutine.yield(s, "target")
            end
            table.insert(m, s)
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

    -- HOOK: Visualize the forward step
    if s and coroutine.running() then coroutine.yield(s, "scanning") end

    if s and pos[s]==0 then
        table.insert(m,s)
        if fresh then
            s = s:move(forw)
            -- HOOK: Visualize the double step
            if s and coroutine.running() then coroutine.yield(s, "scanning") end

            if s and pos[s]==0 then
                table.insert(m,s)
            end
        end
    end
    for _,dir in pairs(take) do
        local t = l:move(dir)
        -- HOOK: Visualize the diagonal attack scans
        if t and coroutine.running() then coroutine.yield(t, "scanning") end

        if t and not (pos[t]==0) and opponents(id,pos[t]) then
            -- HOOK: Tag the enemy hit
            if coroutine.running() then coroutine.yield(t, "target") end
            table.insert(m,t)
            if abs(pos[t])==7 then m[#m].enpas = true end
        end
    end
    return m
end
function knightM(pos,l)
    local id = pos[l]
    local dir = 9
    local m = {}
    local function jump()
        if dir > 16 then return end
        local s = l:move(dir)

        if s then
            if pos[s] == 0 then
                if coroutine.running() then coroutine.yield(s, "scanning") end
            elseif opponents(id,pos[s]) then
                if coroutine.running() then coroutine.yield(s, "target") end
            else
                if coroutine.running() then coroutine.yield(s, "scanning") end -- Friendly bump
            end
        end

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

        if s then
            if pos[s] == 0 then
                if coroutine.running() then coroutine.yield(s, "scanning") end
            elseif opponents(id,pos[s]) then
                if coroutine.running() then coroutine.yield(s, "target") end
            else
                if coroutine.running() then coroutine.yield(s, "scanning") end -- Friendly bump
            end
        end

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
