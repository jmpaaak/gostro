local assets = require("game.asset_loader")

local M = {}

-- Draw the selection highlight effect over a card
function M.draw_select(x, y, w, h, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider("ui.effect_select")
    if not texture then return false end

    local tex_w, tex_h = texture:getDimensions()
    api.set_color(1, 1, 1, 1)
    
    -- We want to scale the 26x38 effect-select to match the requested card's width and height
    -- plus the 1px margin on all sides.
    -- Wait, if it is 26x38, it inherently wraps 24x36 card.
    -- x, y are the card's x,y. We offset by -1.
    local draw_x = x - (tex_w - w) / 2
    local draw_y = y - (tex_h - h) / 2
    
    api.draw(texture, draw_x, draw_y, 0, 1, 1)
    return true
end

-- Draw the score burst centered behind the animated total.
function M.draw_score(cx, cy, scale, alpha, api, texture_provider)
    api = api or {
        set_color = love.graphics.setColor,
        draw = love.graphics.draw,
    }
    texture_provider = texture_provider or assets.texture
    local texture = texture_provider("ui.effect_score")
    if not texture then return false end

    local width, height = texture:getDimensions()
    scale = scale or 1
    alpha = alpha or 1
    api.set_color(1, 1, 1, alpha)
    api.draw(texture, cx - width * scale / 2, cy - height * scale / 2,
        0, scale, scale)
    return true
end

return M
