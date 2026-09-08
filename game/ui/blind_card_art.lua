-- Manifest-backed first/big round card backgrounds.
-- Boss artwork stays in the independently tracked boss-blind category.

local assets = require("game.asset_loader")

local M = {}
local IDS = { small = "ui.blind_small", big = "ui.blind_big" }

function M.asset_id(kind)
    return IDS[kind]
end

function M.draw(kind, x, y, width, height, alpha)
    local id = M.asset_id(kind)
    if not id then return false end
    local image = assets.texture(id)
    if not image then return false end

    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(image, x, y, 0,
        width / image:getWidth(), height / image:getHeight())
    return true
end

return M