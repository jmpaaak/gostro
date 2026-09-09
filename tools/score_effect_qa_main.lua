local score_anim = require("game.ui.score_anim")

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

    local animation = score_anim.new()
    score_anim.start(animation, {
        cards = {{ kind = "hongdan", chips = 40 }},
        base_chips = 40, base_mult = 1,
        bonus_chips = 0, bonus_mult = 4,
        final_chips = 40, final_mult = 5,
        total = 200, gwang_triggers = {},
    })
    animation.phase = "total"
    animation.displayed_total = 200
    animation.total_timer = score_anim.TOTAL_DURATION

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)
    score_anim.draw(animation)
    love.graphics.setCanvas()

    local output = assert(os.getenv("SCORE_EFFECT_QA_OUTPUT"), "SCORE_EFFECT_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("SCORE_EFFECT_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
