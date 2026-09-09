-- Manifest-backed full-canvas scene backgrounds, isolated from scene glue.

local assets = require("game.asset_loader")

local M = {}

local IDS = {
    play = "ui.play_bg",
}

local FALLBACK = {
    play = { 0.025, 0.035, 0.08, 1 },
}

local function graphics_api(api)
    if api and api.graphics then
        return api.graphics
    end
    return love and love.graphics
end

function M.draw(kind, api)
    local id = IDS[kind]
    if not id then return false end

    api = api or {}
    local gfx = graphics_api(api)
    if not gfx then return false end

    local texture_provider = api.texture or assets.texture
    local image = texture_provider(id)
    local color = FALLBACK[kind]
    if color and gfx.clear then
        gfx.clear(color[1], color[2], color[3], color[4])
    end
    if not image then return false end

    if gfx.setColor then gfx.setColor(1, 1, 1, 1) end
    gfx.draw(image, 0, 0)
    return true
end

return M
