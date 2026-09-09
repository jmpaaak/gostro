local tag_art = require("game.ui.tag_art")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

local batch_jobs = {
    { identity = "coupon", output = "tag-coupon-love-v1.png" },
    { identity = "investment", output = "tag-investment-love-v1.png" },
    { identity = "handy", output = "tag-handy-love-v1.png" },
    { identity = "economy", output = "tag-economy-love-v1.png" },
    { identity = "mega", output = "tag-mega-love-v1.png" },
    { identity = "foil", output = "tag-foil-love-v1.png" },
    { identity = "hologram", output = "tag-hologram-love-v1.png" },
    { identity = "polychrome", output = "tag-polychrome-love-v1.png" },
    { identity = "charm", output = "tag-charm-love-v1.png" },
    { identity = "uncommon", output = "tag-uncommon-love-v1.png" },
    { identity = "juggle", output = "tag-juggle-love-v1.png" },
    { identity = "d6", output = "tag-d6-love-v1.png" },
}

local function capture_identity(canvas, identity, output)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)

    local item = { kind = "tag", id = identity }
    local x, y = 140, 60
    local w, h = 32, 48

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
    write_capture(canvas, output)
    print("TAG_LOVE_QA_OK " .. identity .. " 320x180 " .. output)
end

function love.load()
    require("game.qa.offscreen_window").minimizeWindow(320, 180)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont("assets/fonts/Galmuri11.ttf", 8))

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")

    local single = os.getenv("TAG_QA_OUTPUT")
    local outdir = os.getenv("TAG_QA_OUTDIR")
    if single then
        capture_identity(canvas, os.getenv("TAG_QA_IDENTITY") or "coupon", single)
    else
        assert(outdir, "TAG_QA_OUTPUT or TAG_QA_OUTDIR is required")
        for _, job in ipairs(batch_jobs) do
            capture_identity(canvas, job.identity, outdir .. "/" .. job.output)
        end
    end
    love.event.quit()
end

function love.draw() end
