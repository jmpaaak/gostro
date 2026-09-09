-- Manifest-backed HUD score icon drawing, isolated from scoreboard layout.

local assets = require("game.asset_loader")

local M = {}

function M.draw_chip(x, y, size, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider("ui.icon_chip")
    if not texture then return false end

    local width, height = texture:getDimensions()
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y, 0, size / width, size / height)
    return true
end

function M.draw_mult(x, y, size, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider("ui.icon_mult")
    if not texture then return false end

    local width, height = texture:getDimensions()
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y, 0, size / width, size / height)
    return true
end

function M.draw_money(x, y, size, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider("ui.icon_money")
    if not texture then return false end

    local width, height = texture:getDimensions()
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y, 0, size / width, size / height)
    return true
end

return M
