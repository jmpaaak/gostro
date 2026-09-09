-- Manifest-backed New Run deck thumbnail drawing, isolated from setup layout.

local assets = require("game.asset_loader")

local M = {}

function M.draw_blue(x, y, size, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider("ui.deck_blue")
    if not texture then return false end

    local width = texture:getDimensions()
    size = size or width
    local scale = size / width
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y, 0, scale, scale)
    return true
end

return M
