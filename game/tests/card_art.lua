local card_art = require("game.ui.card_art")

local M = {}

function M.run()
    assert(card_art.path("pi") == "assets/runtime/cards/pi.png")
    assert(card_art.path("hongdan") == nil, "unconverted cards must keep their fallback")

    local info = love.filesystem.getInfo(card_art.path("pi"))
    assert(info and info.type == "file", "pi runtime art must be bundled")
    local pixels = love.image.newImageData(card_art.path("pi"))
    assert(pixels:getWidth() == 24 and pixels:getHeight() == 36,
        "pi runtime art must match the card cell")

    local old_graphics = love.graphics
    local loads = 0
    local fake_image = {
        setFilter = function(self, min, mag) self.min, self.mag = min, mag end,
        getFilter = function(self) return self.min, self.mag end,
    }
    love.graphics = {
        newImage = function(path)
            assert(path == card_art.path("pi"))
            loads = loads + 1
            return fake_image
        end,
    }
    local image = card_art.load("pi")
    local min, mag = image:getFilter()
    assert(min == "nearest" and mag == "nearest", "pixel art must use nearest filtering")
    assert(card_art.load("pi") == image and loads == 1, "loaded card art must be cached")
    assert(card_art.load("hongdan") == nil)
    love.graphics = old_graphics
    print("  card_art: OK")
end

return M