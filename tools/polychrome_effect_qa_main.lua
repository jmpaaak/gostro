local card = require("game.ui.card")
local card_art = require("game.ui.card_art")
local edition_art = require("game.ui.edition_art")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

function love.load()
    love.window.setMode(320, 180, { fullscreen = false, resizable = false, vsync = 0 })
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont("assets/fonts/Galmuri11.ttf", 8))

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)

    -- Bare play card, then the same card with the polychrome overlay, then a
    -- slightly overlapped neighbour so top marks stay identifiable.
    local left = { kind = "pi", x = 88, y = 62, selected = false }
    local poly = { kind = "pi", x = 148, y = 62, selected = false, effect = "polychrome", effect_t = 0.2 }
    local overlap = { kind = "hongdan", x = 162, y = 62, selected = false }

    assert(card_art.draw(left.kind, left.x, left.y), "bare play card must draw")
    assert(card_art.draw(poly.kind, poly.x, poly.y), "polychrome play card must draw")
    assert(edition_art.draw("polychrome", poly.x, poly.y, card.WIDTH, card.HEIGHT, poly.effect_t),
        "effect.polychrome runtime texture must draw")
    assert(card_art.draw(overlap.kind, overlap.x, overlap.y), "overlapped neighbour must draw")

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("영롱", 148, 108)
    love.graphics.setCanvas()

    local output = assert(os.getenv("POLYCHROME_EFFECT_QA_OUTPUT"), "POLYCHROME_EFFECT_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("POLYCHROME_EFFECT_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
