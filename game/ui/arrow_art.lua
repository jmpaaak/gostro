local assets = require("game.asset_loader")

local M = {}

local function draw(id, x, y, w, h, api, fetch)
    local texture = (fetch or assets.texture)(id)
    if not texture then
        return false
    end
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y)
    return true
end

function M.draw_left(x, y, w, h, api, fetch)
    return draw("ui.arrow_left", x, y, w, h, api, fetch)
end

function M.draw_right(x, y, w, h, api, fetch)
    return draw("ui.arrow_right", x, y, w, h, api, fetch)
end

return M
