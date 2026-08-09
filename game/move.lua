-- game/move.lua
require("global")

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
    setmetatable(sp, loc_mt) -- Inherit loc metatable for safe == comparisons
    sp_pool[i] = sp
end

local function get_sp(l)
    local sp = sp_pool[sp_cursor]
    sp_cursor = (sp_cursor % SP_POOL_SIZE) + 1
    sp.x = l.x; sp.y = l.y
    sp.enpas = nil; sp.castles = nil -- clear ghost data
    return sp
end

-- MOVE GENERATORS
function visionM(pos,l,dir)
    local id = pos[l]
    local m = get_list()
    local idx = 1
    local s = l:move(dir)

    while s do
        if pos[s]==0 then
            m[idx] = s; idx = idx + 1
            s = s:move(dir)
        elseif opponents(id,pos[s]) then
            m[idx] = s; idx = idx + 1
            break
        else
            break
        end
    end
    return m
end

function pawnM(pos,l,fresh)
    local id = pos[l]
    local m = get_list()
    local idx = 1
    local forw, take
    if id < 0 then
        forw = 5; take = {4,6}
    else
        forw = 1; take = {2,8}
    end

    local s = l:move(forw)
    if s and pos[s]==0 then
        m[idx] = s; idx = idx + 1
        if fresh then
            s = s:move(forw)
            if s and pos[s]==0 then
                m[idx] = s; idx = idx + 1
            end
        end
    end

    for _,dir in ipairs(take) do
        local t = l:move(dir)
        if t and not (pos[t]==0) and opponents(id,pos[t]) then
            if abs(pos[t])==7 then
                local sp = get_sp(t)
                sp.enpas = true
                m[idx] = sp
            else
                m[idx] = t
            end
            idx = idx + 1
        end
    end
    return m
end

function knightM(pos,l)
    local id = pos[l]
    local m = get_list()
    local idx = 1
    for dir = 9, 16 do
        local s = l:move(dir)
        if s and ( pos[s]==0 or opponents(id,pos[s]) ) then
            m[idx] = s; idx = idx + 1
        end
    end
    return m
end

function kingM(pos,l,at)
    local id = pos[l]
    local m = get_list()
    local idx = 1
    for dir = 1, 8 do
        local s = l:move(dir)
        if s and ( pos[s]==0 or opponents(id,pos[s]) ) then
            if not contains(at, s) then
                m[idx] = s; idx = idx + 1
            end
        end
    end
    return m
end
