local tag_art = require("game.ui.tag_art")
local terms = require("game.terms")

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

    local identity = os.getenv("TAG_QA_IDENTITY") or "coupon"
    local item = { kind = "tag", id = identity }

    local x, y = 140, 60
    local w, h = 32, 48

    -- Draw background box
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    love.graphics.setColor(1, 1, 1, 1)

    local drawn = tag_art.draw(item, x, y, w, h, 1)
    if not drawn then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("No Art", x + 2, y + 20)
    end

    love.graphics.print("Tag: " .. identity, 140, 120)
    love.graphics.setCanvas()

    local out = os.getenv("TAG_QA_OUTPUT")
    if out then write_capture(canvas, out) end
    love.event.quit()
end

function love.draw() end
