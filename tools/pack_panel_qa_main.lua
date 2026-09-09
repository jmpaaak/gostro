local pack = require("game.ui.pack")

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
    pack.draw({
        name = "부적 꾸러미",
        choose = 1,
        choices = {
            { id = "the_magician", name = "둔갑 부적", effect = "변환" },
            { id = "the_hanged_man", name = "매달린 사람", effect = "파괴" },
            { id = "the_chariot", name = "강화 부적", effect = "효과 부여" },
        },
    })
    love.graphics.setCanvas()

    local output = assert(os.getenv("PACK_PANEL_QA_OUTPUT"), "PACK_PANEL_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("PACK_PANEL_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
