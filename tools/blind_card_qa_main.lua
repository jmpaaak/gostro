local blind_select = require("game.ui.blind_select")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

local batch_jobs = {
    { boss = "hook", output = "blind-round-cards-love-v1.png" },
    { boss = "wall", output = "blind-wall-card-love-v1.png" },
    { boss = "flint", output = "blind-flint-card-love-v1.png" },
    { boss = "mark", output = "blind-mark-card-love-v1.png" },
    { boss = "fish", output = "blind-fish-card-love-v1.png" },
    { boss = "psychic", output = "blind-psychic-card-love-v1.png" },
    { boss = "goad", output = "blind-goad-card-love-v1.png" },
    { boss = "plant", output = "blind-plant-card-love-v1.png" },
}

local function capture_boss(canvas, boss_id, output)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)
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
    write_capture(canvas, output)
    print("BLIND_CARD_LOVE_QA_OK 320x180 " .. output)
end

function love.load()
    require("game.qa.offscreen_window").minimizeWindow(320, 180)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont("assets/fonts/Galmuri11.ttf", 8))

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")

    local single = os.getenv("BLIND_CARD_QA_OUTPUT")
    local outdir = os.getenv("BLIND_CARD_QA_OUTDIR")
    if single then
        capture_boss(canvas, os.getenv("BLIND_CARD_QA_BOSS") or "hook", single)
    else
        assert(outdir, "BLIND_CARD_QA_OUTPUT or BLIND_CARD_QA_OUTDIR is required")
        for _, job in ipairs(batch_jobs) do
            capture_boss(canvas, job.boss, outdir .. "/" .. job.output)
        end
    end
    love.event.quit(0)
end
