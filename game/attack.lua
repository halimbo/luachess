-- game/attack.lua

-- LOCAL ZERO-ALLOC POOLS
local LIST_POOL_SIZE = 8192
local list_pool = {}
local list_cursor = 1
for i=1, LIST_POOL_SIZE do list_pool[i] = {} end

local function get_list()
    local l = list_pool[list_cursor]
    list_cursor = (list_cursor % LIST_POOL_SIZE) + 1
    for i=1, #l do l[i] = nil end
    return l
end

local SP_POOL_SIZE = 8192
local sp_pool = {}
local sp_cursor = 1
local loc_mt = getmetatable(loc:new(1,1))
for i=1, SP_POOL_SIZE do
    local sp = {}
    setmetatable(sp, loc_mt)
    sp_pool[i] = sp
end

local function get_sp(l, dir)
    local sp = sp_pool[sp_cursor]
    sp_cursor = (sp_cursor % SP_POOL_SIZE) + 1
    sp.x = l.x; sp.y = l.y
    sp.dir = dir
    return sp
end

-- ATTACK GENERATORS
function visionAT(pos,l,dir)
    local a = get_list()
    local idx = 1
    local s = l:move(dir)

    while s do
        a[idx] = s; idx = idx + 1
        if pos[s] ~= 0 then break end
        s = s:move(dir)
    end
    return a
end

function pawnAT(pos,l)
    local id = pos[l]
    local a = get_list()
    local idx = 1
    local take = (id < 0) and {4,6} or {2,8}

    for _,dir in ipairs(take) do
        local s = l:move(dir)
        if s then
            a[idx] = get_sp(s, dir)
            idx = idx + 1
        end
    end
    return a
end

function knightAT(pos,l)
    local a = get_list()
    local idx = 1
    for dir = 9, 16 do
        local s = l:move(dir)
        if s then
            a[idx] = get_sp(s, dir)
            idx = idx + 1
        end
    end
    return a
end

function kingAT(pos,l)
    local a = get_list()
    local idx = 1
    for dir = 1, 8 do
        local s = l:move(dir)
        if s then
            a[idx] = get_sp(s, dir)
            idx = idx + 1
        end
    end
    return a
end
