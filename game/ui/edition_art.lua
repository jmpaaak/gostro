-- Manifest-backed overlay artwork for play-card editions (foil first).

local assets = require("game.asset_loader")

local M = {}

local IDS = {
    foil = "effect.foil",
}

local function overlay_alpha(name, t)
    t = t or 0
    if name == "foil" then
        return 0.55 + 0.35 * math.abs(math.sin(t * 8))
    end
    return 1
end

function M.asset_id(name)
    return IDS[name]
end

function M.draw(name, x, y, w, h, t, api, texture_provider)
    local id = M.asset_id(name)
    if not id then return false end

    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider(id)
    if not texture then return false end

    local tex_w, tex_h = texture:getDimensions()
    local scale_x = (w or tex_w) / tex_w
    local scale_y = (h or tex_h) / tex_h
    api.set_color(1, 1, 1, overlay_alpha(name, t))
    api.draw(texture, x, y, 0, scale_x, scale_y)
    return true
end

return M
