-- Manifest-backed New Run carousel arrow drawing, isolated from setup layout.

local assets = require("game.asset_loader")

local M = {}

local function draw_id(id, x, y, w, h, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider(id)
    if not texture then return false end

    local width, height = texture:getDimensions()
    local sx = (w or width) / width
    local sy = (h or height) / height
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y, 0, sx, sy)
    return true
end

function M.draw_left(x, y, w, h, api, texture_provider)
    return draw_id("ui.arrow_left", x, y, w, h, api, texture_provider)
end

function M.draw_right(x, y, w, h, api, texture_provider)
    return draw_id("ui.arrow_right", x, y, w, h, api, texture_provider)
end

return M
