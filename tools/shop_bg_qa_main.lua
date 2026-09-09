local scene_bg = require("game.ui.scene_bg")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

function love.load()
    love.window.setMode(320, 180, { fullscreen = false, resizable = false, vsync = 0 })
    love.graphics.setDefaultFilter("nearest", "nearest")

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    assert(scene_bg.draw("shop"), "ui.shop_bg runtime texture must draw")

    love.graphics.setCanvas()
    local output = assert(os.getenv("SHOP_BG_QA_OUTPUT"), "SHOP_BG_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("SHOP_BG_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
