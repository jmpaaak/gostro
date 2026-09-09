local run_setup = require("game.ui.run_setup")

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

    local state = run_setup.new("GOSTRO01")
    local rects = run_setup.layout()
    assert(run_setup.activate(state, rects.deck_right.x + 1, rects.deck_right.y + 1) == "deck_changed",
        "QA capture must cycle to the thin deck")
    assert(run_setup.selected_deck(state).id == "thin", "QA capture must show the red thin-deck thumbnail")

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    run_setup.draw(state)
    love.graphics.setCanvas()

    local output = assert(os.getenv("DECK_RED_QA_OUTPUT"), "DECK_RED_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("DECK_RED_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
