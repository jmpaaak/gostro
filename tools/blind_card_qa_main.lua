local blind_select = require("game.ui.blind_select")

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

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)
    local boss_id = os.getenv("BLIND_CARD_QA_BOSS") or "hook"
    blind_select.draw(blind_select.new({
        ante = 1,
        current = "small",
        blinds = {
            { kind = "small", target = 300, playable = true, status = "current" },
            { kind = "big", target = 450, playable = false, status = "upcoming" },
            { kind = "boss", target = 600, playable = false, status = "upcoming", boss = { id = boss_id } },
        },
    }))
    love.graphics.setCanvas()

    local output = assert(os.getenv("BLIND_CARD_QA_OUTPUT"), "BLIND_CARD_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("BLIND_CARD_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end