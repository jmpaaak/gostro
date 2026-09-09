-- Manifest-backed artwork for tag (plaque) offers.

local assets = require("game.asset_loader")

local M = {}
local IDS = {
    coupon = "tag.coupon",
    investment = "tag.investment",
    handy = "tag.handy",
    economy = "tag.economy",
    mega = "tag.mega",
    foil = "tag.foil",
    hologram = "tag.hologram",
    polychrome = "tag.polychrome",
    charm = "tag.charm",
    uncommon = "tag.uncommon",
    juggle = "tag.juggle",
    d6 = "tag.d6",
}

function M.asset_id(item)
    if not item or item.kind ~= "tag" then return nil end
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
