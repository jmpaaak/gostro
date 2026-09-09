local effect_art = require("game.ui.effect_art")
local scene_bg = require("game.ui.scene_bg")

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
    scene_bg.draw("play")
    assert(effect_art.draw_loss(0, 0), "ui.effect_loss runtime texture must draw")
    love.graphics.setCanvas()

    local output = assert(os.getenv("LOSS_EFFECT_QA_OUTPUT"), "LOSS_EFFECT_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("LOSS_EFFECT_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
