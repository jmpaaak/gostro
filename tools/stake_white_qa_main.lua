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
    assert(run_setup.selected_stake(state).id == "white",
        "QA capture must show the white stake chip")

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    run_setup.draw(state)
    love.graphics.setCanvas()

    local output = assert(os.getenv("STAKE_WHITE_QA_OUTPUT"), "STAKE_WHITE_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("STAKE_WHITE_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
