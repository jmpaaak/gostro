local end_screen = require("game.ui.end_screen")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

local function sample_state(seed)
    return {
        ante = 6,
        round_score = 128450,
        seed = seed,
        gwang = {
            { kind = "gwang", identity = "chips" },
            { kind = "gwang", identity = "mult" },
            { kind = "gwang", identity = "yaku_mult" },
        },
    }
end

function love.load()
    require("game.qa.offscreen_window").minimizeWindow(960, 540)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local canvas = love.graphics.newCanvas(1920, 540)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.02, 0.025, 0.06, 1)

    end_screen.draw({ state = "won", run_state = sample_state("WIN42") })
    love.graphics.push()
    love.graphics.translate(960, 0)
    end_screen.draw({ state = "lost", run_state = sample_state("LOSS42"), end_screen_hover = true })
    love.graphics.pop()
    love.graphics.setCanvas()

    local output = assert(os.getenv("END_SCREEN_QA_OUTPUT"), "END_SCREEN_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("END_SCREEN_LOVE_QA_OK 1920x540 " .. output)
    love.event.quit(0)
end
