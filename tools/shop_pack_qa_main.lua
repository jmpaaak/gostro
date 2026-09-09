local shop = require("game.ui.shop")

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
    local kind = os.getenv("SHOP_QA_KIND") or "pack"
    local voucher_identity = os.getenv("SHOP_QA_VOUCHER") or "paint_brush"
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
    local planet_identity = os.getenv("SHOP_QA_PLANET") or "planet_hongdan"
    local planet_names = {
        planet_hongdan = "주작 기원패",
        hongdan = "주작 기원패",
        planet_cheongdan = "청룡 기원패",
        cheongdan = "청룡 기원패",
    }
    local item
    if kind == "voucher" then
        item = { kind = "voucher", identity = voucher_identity,
            name = assert(voucher_names[voucher_identity]), price = 10 }
    elseif kind == "planet" then
        item = { kind = "planet", identity = planet_identity,
            name = assert(planet_names[planet_identity]), price = 3 }
    else
        item = { kind = "pack", identity = "arcana_pack", name = "부적 꾸러미", price = 4 }
    end
    shop.draw({
        money = 12,
        cards = {
            item, item, item,
        },
    })
    love.graphics.setCanvas()

    local output = assert(os.getenv("SHOP_PACK_QA_OUTPUT"), "SHOP_PACK_QA_OUTPUT is required")
    write_capture(canvas, output)
    print("SHOP_ART_LOVE_QA_OK " .. kind .. " 320x180 " .. output)
    love.event.quit(0)
end