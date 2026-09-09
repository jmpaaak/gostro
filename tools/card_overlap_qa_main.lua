local qa = require("game.qa.card_overlap")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

function love.load()
    require("game.tests.card_overlap_qa").run()
    local spec = qa.spec()
    require("game.qa.offscreen_window").minimizeWindow(spec.canvas_width, spec.canvas_height)
    love.graphics.setDefaultFilter("nearest", "nearest")
    local sheet = love.graphics.newImage("assets/runtime/cards/play-card-contact-sheet-v1.png")
    local canvas = love.graphics.newCanvas(spec.canvas_width, spec.canvas_height)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.055, 0.075, 0.07, 1)
    qa.draw(love.graphics, sheet)
    love.graphics.setCanvas()
    local output = assert(os.getenv("CARD_OVERLAP_QA_OUTPUT"), "CARD_OVERLAP_QA_OUTPUT is required")
    write_capture(canvas, output)
    print(("CARD_OVERLAP_LOVE_QA_OK %dx%d %s"):format(
        spec.canvas_width, spec.canvas_height, output
    ))
    love.event.quit(0)
end