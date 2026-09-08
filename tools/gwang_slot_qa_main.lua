local gwang_slots = require("game.ui.gwang_slots")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

function love.load()
    love.window.setMode(320, 180, { fullscreen = false, resizable = false, vsync = 0 })
    love.graphics.setDefaultFilter("nearest", "nearest")
    local slots = gwang_slots.new()
    local identity = os.getenv("GWANG_QA_IDENTITY") or "chips"
    for _ = 1, gwang_slots.MAX_SLOTS do
        assert(gwang_slots.equip(slots, { identity = identity }))
    end

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)
    gwang_slots.draw(slots)
    love.graphics.setCanvas()

    local output = assert(os.getenv("GWANG_SLOT_QA_OUTPUT"), "GWANG_SLOT_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("GWANG_SLOT_LOVE_QA_OK 320x180 " .. output)
    love.event.quit(0)
end
