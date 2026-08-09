require("global")

function CanvasMap(square)
    local cMap = {}
    local cX,cY = 0,0
    for x=1,8 do
        cMap[x] = {}
        for y=1,8 do
            cMap[x][y] = {x = cX, y = cY}
            cY = cY + square
        end
        cY = 0
        cX = cX + square
    end
    return cMap
end

function BoardMap(square,bX,bY)
    local bMap = {}
    local cX,cY = 0,0
    for x=1,8 do
        bMap[x] = {}
        for y=1,8 do
            bMap[x][y] = {x = cX+bX, y = cY+bY}
            cY = cY + square
        end
        cY = 0
        cX = cX + square
    end
    return bMap
end

function PngMap(square,bX,bY,pngSize,scale)
    local m = {}
    local cX,cY = bX, bY
    for x=1,8 do
        m[x] = {}
        for y=1,8 do
            m[x][y] = {
                x = cX + square/2 - (pngSize/2*scale),
                y = cY + square/2 - (pngSize/2*scale)
            }
            cY = cY + square
        end
        cY = bY
        cX = cX + square
    end
    return m
end

function ArrowMap(bX,bY,square)
    local m = {}
    local cX,cY = bX,bY
    for x=1,8 do
        m[x] = {}
        for y=1,8 do
            m[x][y] = {x = cX+square/2, y = cY+square/2}
            cY = cY+square
        end
        cY = bY
        cX = cX+square
    end
    return m
end

function InputMap(square,cX,cY) -- top left origin
    local m = {}
    local startY = cY
    for x=1,8 do
        m[x] = {}
        for y=1,8 do
            m[x][y] = {
                left = cX,
                right = cX + square,
                up = cY,
                down = cY + square
            }
            cY = cY + square
        end
        cY = startY
        cX = cX + square
    end
    return m
end
