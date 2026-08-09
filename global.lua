-- global.lua

letters = {"a","b","c","d","e","f","g","h"}
names = { [1] = "", [2] = "N", [3] = "B", [4] = "R", [5] = "Q", [8]="K" }

-- 1. THE COORDINATE CACHE (Zero Allocation)
loc = {}
local loc_cache = {}
for i = 1, 8 do loc_cache[i] = {} end

local loc_mt = {
    __index = loc,
    -- Since we only ever return the cached objects, two identical coordinates
    -- point to the exact same memory address. Natively `loc_a == loc_b` works!
    -- But we keep __eq for safety if legacy code expects it.
    __eq = function(one, two)
        return (one.x == two.x) and (one.y == two.y)
    end
}

-- Pre-allocate the 64 squares at engine boot
for x = 1, 8 do
    for y = 1, 8 do
        local l = { x = x, y = y }
        setmetatable(l, loc_mt)
        loc_cache[x][y] = l
    end
end

-- Replaces dynamic {x=, y=} additions
local move_offsets = {
    -- 1 to 8: Directions
    [1] = {0, 1}, [2] = {1, 1}, [3] = {1, 0}, [4] = {1, -1},
    [5] = {0, -1}, [6] = {-1, -1}, [7] = {-1, 0}, [8] = {-1, 1},
    -- 9 to 16: Knight Jumps
    [9] = {1, 2}, [10] = {2, 1}, [11] = {2, -1}, [12] = {1, -2},
    [13] = {-1, -2}, [14] = {-2, -1}, [15] = {-2, 1}, [16] = {-1, 2}
}

function loc:new(x, y)
    if x < 1 or y < 1 or x > 8 or y > 8 then return false end
    return loc_cache[x][y] -- Route to pre-cached memory cell
end

function loc:move(dir)
    local offset = move_offsets[dir]
    if not offset then return false end

    local nx = self.x + offset[1]
    local ny = self.y + offset[2]

    -- Inline the `outside()` check to save a function call
    if nx < 1 or ny < 1 or nx > 8 or ny > 8 then
        return false
    end

    return loc_cache[nx][ny] -- Return cached cell instead of instantiating
end

-- 2. THE MAP RING BUFFER (Zero Allocation)

Map = {}
local MAP_POOL_SIZE = 2048 -- Large enough to hold deep rollback history frames
local map_pool = {}
local map_cursor = 1

local map_mt = {
    __index = function(self, k)
        if type(k) == "table" then return self.storage[k.x][k.y] else return self.storage[k] end
    end,
    __newindex = function(self, k, v)
        if type(k) == "table" then self.storage[k.x][k.y] = v else self.storage[k] = v end
    end
}

-- Pre-allocate all Maps and their nested rows at boot
for p = 1, MAP_POOL_SIZE do
    local m = { storage = {} }
    setmetatable(m, map_mt)
    for i = 1, 8 do
        m.storage[i] = {}
        for j = 1, 8 do
            m.storage[i][j] = 0
        end
    end
    map_pool[p] = m
end

function Map:new(insert)
    -- Grab the next pre-allocated map from the ring buffer
    local m = map_pool[map_cursor]
    map_cursor = (map_cursor % MAP_POOL_SIZE) + 1

    local is_table = (type(insert) == "table")
    for i = 1, 8 do
        for j = 1, 8 do
            if is_table then
                m.storage[i][j] = {}
            else
                m.storage[i][j] = insert
            end
        end
    end
    return m
end

function Map:copy(M)
    -- Grab the next pre-allocated map from the ring buffer
    local m = map_pool[map_cursor]
    map_cursor = (map_cursor % MAP_POOL_SIZE) + 1

    for i = 1, 8 do
        for j = 1, 8 do
            -- M.storage[i][j] is never a table, so safe primitive copy
            m.storage[i][j] = M.storage[i][j]
        end
    end
    return m
end

-- 3. UTILITIES (Untouched)

function hasTurn(id,turn)
    if turn%2==0 and not (id<0) then return false
    elseif not (turn%2==0) and (id<0) then return false end
    return true
end

function scrollTurn(pos,turn,f)
    for x=1,8 do
        for y=1,8 do
            local id = pos[x][y]
            if not (id==0) and hasTurn(id,turn) then
                -- Note: loc:new now returns a cached cell, safe to spam!
                f(id,loc:new(x,y),x,y)
            end
        end
    end
end

function do8x8(pos,f)
    for x=1,8 do
        for y=1,8 do
            f(pos[x][y],loc:new(x,y),x,y)
        end
    end
end

function do8x8break(pos,f)
    for x=1,8 do
        for y=1,8 do
            if f(pos[x][y],loc:new(x,y),x,y) then
                return
            end
        end
    end
end

function abs(x)
    return math.abs(x)
end

function contains(list,item)
    for _,v in pairs(list) do
        if v==item then
            return true
        end
    end
    return false
end
