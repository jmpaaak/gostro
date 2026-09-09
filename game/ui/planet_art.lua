-- Manifest-backed artwork for wish-card (planet) shop offers.

local assets = require("game.asset_loader")

local M = {}
local IDS = {
    planet_hongdan = "planet.planet_hongdan",
    hongdan = "planet.planet_hongdan",
    planet_cheongdan = "planet.planet_cheongdan",
    cheongdan = "planet.planet_cheongdan",
    planet_chodan = "planet.planet_chodan",
    chodan = "planet.planet_chodan",
    planet_godori = "planet.planet_godori",
    godori = "planet.planet_godori",
    planet_pi = "planet.planet_pi",
    pi = "planet.planet_pi",
}

function M.asset_id(item)
    if not item or item.kind ~= "planet" then return nil end
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
