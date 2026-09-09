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
    assert(run_setup.activate(state, rects.deck_left.x + 1, rects.deck_left.y + 1) == "deck_changed",
        "QA capture must cycle to the locked gwang jackpot deck")
    assert(run_setup.selected_deck(state).id == "gwang_jackpot",
        "QA capture must show the yellow gwang-jackpot thumbnail")

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    run_setup.draw(state)
    love.graphics.setCanvas()

    local output = assert(os.getenv("DECK_YELLOW_QA_OUTPUT"), "DECK_YELLOW_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("DECK_YELLOW_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
