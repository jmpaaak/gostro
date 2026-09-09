-- Manifest-backed artwork for talisman (tarot) shop offers.

local assets = require("game.asset_loader")

local M = {}
local IDS = {
    the_magician = "tarot.the_magician",
    the_hanged_man = "tarot.the_hanged_man",
}

function M.asset_id(item)
    if not item or item.kind ~= "tarot" then return nil end
    return IDS[item.identity or item.id]
end

function M.draw(item, x, y, width, height, alpha)
    local id = M.asset_id(item)
    if not id then return false end
    local image = assets.texture(id)
    if not image then return false end

    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(image, x, y, 0,
        width / image:getWidth(), height / image:getHeight())
    return true
end

return M
