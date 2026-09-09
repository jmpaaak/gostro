local tarot_target = require("game.ui.tarot_target")

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
    love.graphics.clear(0.04, 0.05, 0.08, 1)

    local flow = {
        slot = 1,
        tarot_id = "the_magician",
        tarot_name = "둔갑 부적",
        effect = "convert",
        option = "cheongdan",
        target_index = 3,
        cancelled = false,
    }
    local cards = {
        { kind = "hongdan" },
        { kind = "godori" },
        { kind = "pi" },
    }
    tarot_target.draw(flow, cards)

    love.graphics.setCanvas()
    local output = assert(os.getenv("GLASS_PANEL_QA_OUTPUT"), "GLASS_PANEL_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("GLASS_PANEL_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
