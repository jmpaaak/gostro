-- Bought shop cards fly from the stall to their destination slot.

local shop = require("game.ui.shop")
local shop_fly = require("game.ui.shop_fly")
local gwang_slots = require("game.ui.gwang_slots")
local play = require("game.scenes.play")

local M = {}

function M.run()
    local s = shop.new(100)
    local dest = { x = 400, y = 12, w = 72, h = 96 }
    local fly = shop_fly.start(s, 1, dest)
    assert(fly, "buying a stall starts a fly")
    assert(fly.timer == 0)
    local start_x, start_y = fly.x, fly.y
    shop_fly.update(s, shop_fly.DURATION * 0.5)
    assert(s.fly, "fly is in flight")
    assert(s.fly.x ~= start_x or s.fly.y ~= start_y, "card moves toward the slot")
    assert(s.fly.scale < 1, "card shrinks as it docks")
    shop_fly.update(s, shop_fly.DURATION)
    assert(s.fly == nil, "fly finishes")

    local gs = gwang_slots.new()
    local gwang_dest = shop_fly.destination("gwang", { gwang = { { identity = "chips" } } }, gs)
    local slots = gwang_slots.slot_positions()
    assert(gwang_dest.x == slots[1].x and gwang_dest.y == slots[1].y,
        "first gwang docks in slot 1")

    local tarot_dest = shop_fly.destination("tarot", { tarots = {} })
    assert(tarot_dest.x >= 480, "tarots fly toward the right-hand consumable row")

    local scene = play.new("SHOP-FLY")
    play.select_blind(scene, 1)
    local target = require("game.run").blind_target(scene.run_state)
    require("game.run").add_score(scene.run_state, target)
    play.check_clear(scene)
    assert(scene.state == "shop")
    local offer = scene.shop.random_offers[1]
    offer.kind, offer.identity, offer.price, offer.sold = "gwang", "chips", 0, false
    assert(play.buy_shop_card(scene, 1))
    assert(scene.shop.fly, "live gwang purchase starts a fly to the slot")

    print("  shop_fly: OK")
end

return M
