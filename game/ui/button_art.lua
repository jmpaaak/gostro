local assets = require("game.asset_loader")

local M = {}

local IDS = {
    primary   = "ui.btn_primary",
    secondary = "ui.btn_secondary",
    danger    = "ui.btn_danger",
    disabled  = "ui.btn_disabled",
}

local patch_cache = {}

-- 9-slice layout for 100x30 button
-- Corner width: 8, Corner height: 8
local CW, CH = 8, 8

local function build_patches(image)
    local iw, ih = image:getWidth(), image:getHeight()
    local quads = {}
    
    -- top-left, top-center, top-right
    quads[1] = love.graphics.newQuad(0, 0, CW, CH, iw, ih)
    quads[2] = love.graphics.newQuad(CW, 0, iw - CW*2, CH, iw, ih)
    quads[3] = love.graphics.newQuad(iw - CW, 0, CW, CH, iw, ih)
    
    -- mid-left, mid-center, mid-right
    quads[4] = love.graphics.newQuad(0, CH, CW, ih - CH*2, iw, ih)
    quads[5] = love.graphics.newQuad(CW, CH, iw - CW*2, ih - CH*2, iw, ih)
    quads[6] = love.graphics.newQuad(iw - CW, CH, CW, ih - CH*2, iw, ih)
    
    -- bottom-left, bottom-center, bottom-right
    quads[7] = love.graphics.newQuad(0, ih - CH, CW, CH, iw, ih)
    quads[8] = love.graphics.newQuad(CW, ih - CH, iw - CW*2, CH, iw, ih)
    quads[9] = love.graphics.newQuad(iw - CW, ih - CH, CW, CH, iw, ih)
    
    return quads
end

local function draw_9slice(image, quads, x, y, w, h)
    local iw, ih = image:getWidth(), image:getHeight()
    
    -- If requested size is too small, just draw scaled fallback (or clamp)
    local min_w, min_h = CW * 2, CH * 2
    if w < min_w then w = min_w end
    if h < min_h then h = min_h end

    local mid_w_scale = (w - min_w) / (iw - min_w)
    local mid_h_scale = (h - min_h) / (ih - min_h)

    -- Top row
    love.graphics.draw(image, quads[1], x, y)
    love.graphics.draw(image, quads[2], x + CW, y, 0, mid_w_scale, 1)
    love.graphics.draw(image, quads[3], x + w - CW, y)

    -- Mid row
    love.graphics.draw(image, quads[4], x, y + CH, 0, 1, mid_h_scale)
    love.graphics.draw(image, quads[5], x + CW, y + CH, 0, mid_w_scale, mid_h_scale)
    love.graphics.draw(image, quads[6], x + w - CW, y + CH, 0, 1, mid_h_scale)

    -- Bottom row
    love.graphics.draw(image, quads[7], x, y + h - CH)
    love.graphics.draw(image, quads[8], x + CW, y + h - CH, 0, mid_w_scale, 1)
    love.graphics.draw(image, quads[9], x + w - CW, y + h - CH)
end

function M.draw(kind, rect)
    local id = IDS[kind]
    if not id then return false end
    
    local image = assets.texture(id)
    if not image then return false end
    
    if not patch_cache[id] then
        patch_cache[id] = build_patches(image)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    draw_9slice(image, patch_cache[id], rect.x, rect.y, rect.w, rect.h)
    return true
end

return M
