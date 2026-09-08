-- Manifest-backed artwork for permanent seal (voucher) offers.

local assets = require("game.asset_loader")

local M = {}
local IDS = {
    paint_brush = "voucher.paint_brush",
    wasteful = "voucher.wasteful",
    grabber = "voucher.grabber",
    overstock = "voucher.overstock",
    reroll_surplus = "voucher.reroll_surplus",
    clearance_sale = "voucher.clearance_sale",
    seed_money = "voucher.seed_money",
}

function M.asset_id(item)
    if not item or item.kind ~= "voucher" then return nil end
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