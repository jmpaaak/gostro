local assets = require("game.asset_loader")

local M = {}

local IDS = {
    pi = "play-card.pi",
    hongdan = "play-card.hongdan",
    cheongdan = "play-card.cheongdan",
    chodan = "play-card.chodan",
    godori = "play-card.godori",
}

function M.path(kind)
    local id = IDS[kind]
    return id and assets.runtime_path(id) or nil
end

function M.load(kind)
    local id = IDS[kind]
    if not id or not love or not love.graphics then return nil end
    return assets.texture(id)
end

function M.draw(kind, x, y)
    local image = M.load(kind)
    if not image then return false end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x, y)
    return true
end

return M