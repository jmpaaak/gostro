local shop = require("game.ui.shop")

local function write_capture(canvas, path)
    local encoded = canvas:newImageData():encode("png")
    local file = assert(io.open(path, "wb"))
    file:write(encoded:getString())
    file:close()
end

local voucher_names = {
    paint_brush = "명필의 인장",
    wasteful = "호탕한 인장",
    grabber = "갈퀴 인장",
    overstock = "만물상 인장",
    reroll_surplus = "에누리 인장",
    clearance_sale = "떨이 인장",
    seed_money = "밑천 인장",
    antimatter = "허공 인장",
    crystal_ball = "천리안 인장",
    hone = "벼림 인장",
    directors_cut = "판갈이 인장",
    money_tree = "금맥 인장",
}

local planet_names = {
    planet_hongdan = "주작 기원패",
    hongdan = "주작 기원패",
    planet_cheongdan = "청룡 기원패",
    cheongdan = "청룡 기원패",
    planet_chodan = "백호 기원패",
    chodan = "백호 기원패",
    planet_godori = "현무 기원패",
    godori = "현무 기원패",
    planet_pi = "황룡 기원패",
    pi = "황룡 기원패",
}

local tarot_names = {
    the_magician = "둔갑 부적",
    the_hanged_man = "소멸 부적",
    the_chariot = "강화 부적",
    the_lovers = "쌍둥이 부적",
}

local batch_jobs = {
    { kind = "pack", output = "shop-pack-love-v1.png" },
    { kind = "voucher", voucher = "paint_brush", output = "shop-voucher-love-v1.png" },
    { kind = "voucher", voucher = "wasteful", output = "shop-voucher-wasteful-love-v1.png" },
    { kind = "voucher", voucher = "grabber", output = "shop-voucher-grabber-love-v1.png" },
    { kind = "voucher", voucher = "overstock", output = "shop-voucher-overstock-love-v1.png" },
    { kind = "voucher", voucher = "reroll_surplus", output = "shop-voucher-reroll-surplus-love-v1.png" },
    { kind = "voucher", voucher = "clearance_sale", output = "shop-voucher-clearance-sale-love-v1.png" },
    { kind = "voucher", voucher = "seed_money", output = "shop-voucher-seed-money-love-v1.png" },
    { kind = "voucher", voucher = "antimatter", output = "shop-voucher-antimatter-love-v1.png" },
    { kind = "voucher", voucher = "crystal_ball", output = "shop-voucher-crystal-ball-love-v1.png" },
    { kind = "voucher", voucher = "hone", output = "shop-voucher-hone-love-v1.png" },
    { kind = "voucher", voucher = "directors_cut", output = "shop-voucher-directors-cut-love-v1.png" },
    { kind = "voucher", voucher = "money_tree", output = "shop-voucher-money-tree-love-v1.png" },
    { kind = "planet", planet = "planet_hongdan", output = "shop-planet-hongdan-love-v1.png" },
    { kind = "planet", planet = "planet_cheongdan", output = "shop-planet-cheongdan-love-v1.png" },
    { kind = "planet", planet = "planet_chodan", output = "shop-planet-chodan-love-v1.png" },
    { kind = "planet", planet = "planet_godori", output = "shop-planet-godori-love-v1.png" },
    { kind = "planet", planet = "planet_pi", output = "shop-planet-pi-love-v1.png" },
    { kind = "tarot", tarot = "the_magician", output = "shop-tarot-the-magician-love-v1.png" },
    { kind = "tarot", tarot = "the_hanged_man", output = "shop-tarot-the-hanged-man-love-v1.png" },
    { kind = "tarot", tarot = "the_chariot", output = "shop-tarot-the-chariot-love-v1.png" },
    { kind = "tarot", tarot = "the_lovers", output = "shop-tarot-the-lovers-love-v1.png" },
}

local function item_for(job)
    if job.kind == "voucher" then
        local identity = job.voucher or "paint_brush"
        return {
            kind = "voucher",
            identity = identity,
            name = assert(voucher_names[identity]),
            price = 10,
        }
    elseif job.kind == "planet" then
        local identity = job.planet or "planet_hongdan"
        return {
            kind = "planet",
            identity = identity,
            name = assert(planet_names[identity]),
            price = 3,
        }
    elseif job.kind == "tarot" then
        local identity = job.tarot or "the_magician"
        return {
            kind = "tarot",
            identity = identity,
            name = assert(tarot_names[identity]),
            price = 3,
        }
    end
    return { kind = "pack", identity = "arcana_pack", name = "부적 꾸러미", price = 4 }
end

local function capture_job(canvas, job, output)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.025, 0.035, 0.08, 1)
    local item = item_for(job)
    shop.draw({
        money = 12,
        cards = { item, item, item },
    })
    love.graphics.setCanvas()
    write_capture(canvas, output)
    print("SHOP_ART_LOVE_QA_OK " .. job.kind .. " 320x180 " .. output)
end

function love.load()
    require("game.qa.offscreen_window").minimizeWindow(320, 180)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont("assets/fonts/Galmuri11.ttf", 8))

    local canvas = love.graphics.newCanvas(320, 180)
    canvas:setFilter("nearest", "nearest")

    local single = os.getenv("SHOP_PACK_QA_OUTPUT")
    local outdir = os.getenv("SHOP_PACK_QA_OUTDIR")
    if single then
        capture_job(canvas, {
            kind = os.getenv("SHOP_QA_KIND") or "pack",
            voucher = os.getenv("SHOP_QA_VOUCHER") or "paint_brush",
            planet = os.getenv("SHOP_QA_PLANET") or "planet_hongdan",
            tarot = os.getenv("SHOP_QA_TAROT") or "the_magician",
        }, single)
    else
        assert(outdir, "SHOP_PACK_QA_OUTPUT or SHOP_PACK_QA_OUTDIR is required")
        for _, job in ipairs(batch_jobs) do
            capture_job(canvas, job, outdir .. "/" .. job.output)
        end
    end
    love.event.quit(0)
end
