local gwang_slots = require("game.ui.gwang_slots")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

local batch_jobs = {
    { identity = "chips", output = "gwang-chips-slots-love-v1.png" },
    { identity = "mult", output = "gwang-mult-slots-love-v1.png" },
    { identity = "always_mult_small", output = "gwang-always-mult-small-slots-love-v1.png" },
    { identity = "always_chips_small", output = "gwang-always-chips-small-slots-love-v1.png" },
    { identity = "always_chips_mid", output = "gwang-always-chips-mid-slots-love-v1.png" },
    { identity = "always_mult_mid", output = "gwang-always-mult-mid-slots-love-v1.png" },
    { identity = "hongdan_x2", output = "gwang-hongdan-x2-slots-love-v1.png" },
    { identity = "cheongdan_x2", output = "gwang-cheongdan-x2-slots-love-v1.png" },
    { identity = "chodan_x2", output = "gwang-chodan-x2-slots-love-v1.png" },
    { identity = "godori_x2", output = "gwang-godori-x2-slots-love-v1.png" },
    { identity = "pi_chips_kind", output = "gwang-pi-chips-kind-slots-love-v1.png" },
    { identity = "godori_chips", output = "gwang-godori-chips-slots-love-v1.png" },
    { identity = "hongdan_chips", output = "gwang-hongdan-chips-slots-love-v1.png" },
    { identity = "cheongdan_chips", output = "gwang-cheongdan-chips-slots-love-v1.png" },
    { identity = "chodan_chips", output = "gwang-chodan-chips-slots-love-v1.png" },
    { identity = "pi_yaku_mult", output = "gwang-pi-yaku-mult-slots-love-v1.png" },
    { identity = "thin_deck_x3", output = "gwang-thin-deck-x3-slots-love-v1.png" },
    { identity = "tiny_deck_chips", output = "gwang-tiny-deck-chips-slots-love-v1.png" },
    { identity = "lean_deck_mult", output = "gwang-lean-deck-mult-slots-love-v1.png" },
    { identity = "rich_mult", output = "gwang-rich-mult-slots-love-v1.png" },
    { identity = "loaded_chips", output = "gwang-loaded-chips-slots-love-v1.png" },
    { identity = "wealthy_x2", output = "gwang-wealthy-x2-slots-love-v1.png" },
    { identity = "boss_x2", output = "gwang-boss-x2-slots-love-v1.png" },
    { identity = "boss_chips", output = "gwang-boss-chips-slots-love-v1.png" },
    { identity = "small_chips", output = "gwang-small-chips-slots-love-v1.png" },
    { identity = "big_mult", output = "gwang-big-mult-slots-love-v1.png" },
    { identity = "once_x20", output = "gwang-once-x20-slots-love-v1.png" },
    { identity = "once_chips", output = "gwang-once-chips-slots-love-v1.png" },
    { identity = "compound", output = "gwang-compound-slots-love-v1.png" },
}

local function capture_identity(canvas, identity, output)
    local slots = gwang_slots.new()
    for _ = 1, gwang_slots.MAX_SLOTS do
        assert(gwang_slots.equip(slots, { identity = identity }))
    end
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)
    gwang_slots.draw(slots)
    love.graphics.setCanvas()
    write_capture(canvas, output)
    print("GWANG_SLOT_LOVE_QA_OK 320x180 " .. output)
end

function love.load()
    require("game.qa.offscreen_window").minimizeWindow(320, 180)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")

    local single = os.getenv("GWANG_SLOT_QA_OUTPUT")
    local outdir = os.getenv("GWANG_SLOT_QA_OUTDIR")
    if single then
        capture_identity(canvas, os.getenv("GWANG_QA_IDENTITY") or "chips", single)
    else
        assert(outdir, "GWANG_SLOT_QA_OUTPUT or GWANG_SLOT_QA_OUTDIR is required")
        for _, job in ipairs(batch_jobs) do
            capture_identity(canvas, job.identity, outdir .. "/" .. job.output)
        end
    end
    love.event.quit(0)
end
