local M = {}

local FONT_PATH = "assets/fonts/Galmuri11.ttf"
local DEFAULT_SIZE = 33
local cache = {}

local function graphics_or_default(graphics)
    graphics = graphics or (love and love.graphics)
    assert(graphics and graphics.newFont, "LÖVE graphics is required to load fonts")
    return graphics
end

function M.get(size, graphics)
    size = size or DEFAULT_SIZE
    assert(type(size) == "number" and size > 0 and size % DEFAULT_SIZE == 0,
        "Galmuri11 font size must be a positive multiple of 11")

    if not cache[size] then
        cache[size] = graphics_or_default(graphics).newFont(FONT_PATH, size)
    end
    return cache[size]
end

function M.install(graphics)
    graphics = graphics_or_default(graphics)
    local font = M.get(DEFAULT_SIZE, graphics)
    graphics.setFont(font)
    return font
end

function M.reset()
    cache = {}
end

return M