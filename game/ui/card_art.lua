local M = {}

local PATHS = {
    pi = "assets/runtime/cards/pi.png",
}

local cache = {}

function M.path(kind)
    return PATHS[kind]
end

function M.load(kind)
    local path = PATHS[kind]
    if not path or not love or not love.graphics then return nil end
    if not cache[path] then
        local image = love.graphics.newImage(path)
        image:setFilter("nearest", "nearest")
        cache[path] = image
    end
    return cache[path]
end

function M.draw(kind, x, y)
    local image = M.load(kind)
    if not image then return false end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x, y)
    return true
end

return M