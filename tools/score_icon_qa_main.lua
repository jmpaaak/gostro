local scoreboard = require("game.ui.scoreboard")

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
    local state = scoreboard.new()
    scoreboard.set_target(state, 300)
    scoreboard.set_hand_result(state, 42, 3)
    scoreboard.draw(state)
    love.graphics.setCanvas()

    local output = assert(os.getenv("SCORE_ICON_QA_OUTPUT"), "SCORE_ICON_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("SCORE_ICON_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
