local run_setup = require("game.ui.run_setup")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

function love.load()
    require("game.qa.offscreen_window").minimizeWindow(320, 180)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont("assets/fonts/Galmuri11.ttf", 8))

    local state = run_setup.new("GOSTRO01")
    local rects = run_setup.layout()
    assert(run_setup.activate(state, rects.stake_left.x + 1, rects.stake_left.y + 1) == "stake_changed",
        "QA capture must cycle to the locked green stake chip")
    assert(run_setup.selected_stake(state).id == "green",
        "QA capture must show the green stake chip")

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    run_setup.draw(state)
    love.graphics.setCanvas()

    local output = assert(os.getenv("STAKE_GREEN_QA_OUTPUT"), "STAKE_GREEN_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("STAKE_GREEN_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
