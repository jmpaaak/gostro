-- Manifest-backed 9-slice panel artwork, isolated from pack overlay layout.

local assets = require("game.asset_loader")

local M = {}

local IDS = {
    wood = "ui.panel_wood",
    metal = "ui.panel_metal",
    glass = "ui.panel_glass",
}

local patch_cache = {}
local CW, CH = 12, 12

local function graphics_api(api)
    if api and api.graphics then
        return api.graphics
    end
    return love.graphics
end

local function build_patches(image, gfx)
    local iw, ih = image:getWidth(), image:getHeight()
    return {
        gfx.newQuad(0, 0, CW, CH, iw, ih),
        gfx.newQuad(CW, 0, iw - CW * 2, CH, iw, ih),
        gfx.newQuad(iw - CW, 0, CW, CH, iw, ih),
        gfx.newQuad(0, CH, CW, ih - CH * 2, iw, ih),
        gfx.newQuad(CW, CH, iw - CW * 2, ih - CH * 2, iw, ih),
        gfx.newQuad(iw - CW, CH, CW, ih - CH * 2, iw, ih),
        gfx.newQuad(0, ih - CH, CW, CH, iw, ih),
        gfx.newQuad(CW, ih - CH, iw - CW * 2, CH, iw, ih),
        gfx.newQuad(iw - CW, ih - CH, CW, CH, iw, ih),
    }
end

local function draw_9slice(gfx, image, quads, x, y, w, h)
    local iw, ih = image:getWidth(), image:getHeight()
    local min_w, min_h = CW * 2, CH * 2
    if w < min_w then w = min_w end
    if h < min_h then h = min_h end

    local mid_w_scale = (w - min_w) / (iw - min_w)
    local mid_h_scale = (h - min_h) / (ih - min_h)

    gfx.draw(image, quads[1], x, y)
    gfx.draw(image, quads[2], x + CW, y, 0, mid_w_scale, 1)
    gfx.draw(image, quads[3], x + w - CW, y)
    gfx.draw(image, quads[4], x, y + CH, 0, 1, mid_h_scale)
    gfx.draw(image, quads[5], x + CW, y + CH, 0, mid_w_scale, mid_h_scale)
    gfx.draw(image, quads[6], x + w - CW, y + CH, 0, 1, mid_h_scale)
    gfx.draw(image, quads[7], x, y + h - CH)
    gfx.draw(image, quads[8], x + CW, y + h - CH, 0, mid_w_scale, 1)
    gfx.draw(image, quads[9], x + w - CW, y + h - CH)
end

function M.draw(kind, rect, api)
    local id = IDS[kind]
    if not id or not rect then return false end

    api = api or {}
    local texture_provider = api.texture or assets.texture
    local image = texture_provider(id)
    if not image then return false end

    local gfx = graphics_api(api)
    if not patch_cache[id] then
        patch_cache[id] = build_patches(image, gfx)
    end

    gfx.setColor(1, 1, 1, 1)
    draw_9slice(gfx, image, patch_cache[id], rect.x, rect.y, rect.w, rect.h)
    return true
end

return M
