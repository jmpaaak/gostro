-- Hover lifts an unsold shop slot and emphasizes its price.

local shop = require("game.ui.shop")

local M = {}

function M.run()
    assert(shop.HOVER_LIFT > 0, "shop slots peek on hover")

    local s = shop.new(100)
    assert(shop.hover_index(s) == nil)
    local pos = shop.card_positions(s)
    assert(shop.slot_draw_y(s, 2) == pos[2].y)

    shop.set_hover(s, 2)
    assert(shop.hover_index(s) == 2)
    assert(shop.slot_draw_y(s, 2) == pos[2].y - shop.HOVER_LIFT, "hovered slot rises")
    assert(shop.slot_draw_y(s, 1) == pos[1].y, "other slots stay put")

    local views = shop.slot_views(s)
    assert(views[2].hovered == true)
    assert(views[2].price_emphasized == true)
    assert(views[1].hovered ~= true)
    assert(views[1].price_emphasized ~= true)

    local gold = shop.price_color(true)
    local idle = shop.price_color(false)
    assert(gold[2] > idle[2] or gold[3] > idle[3], "hovered price is brighter")

    shop.buy_card(s, 2)
    assert(s.buy_flash and s.buy_flash.index == 2, "buying flashes the sold slot")
    shop.update(s, 0.1)
    assert(s.buy_flash.timer < 0.35)
    shop.update(s, 1)
    assert(s.buy_flash == nil, "buy flash expires")
    shop.set_hover(s, 2)
    assert(shop.hover_index(s) == nil, "sold slots cannot hover")
    assert(shop.slot_draw_y(s, 2) == pos[2].y)

    local s2 = shop.new(100)
    local p = shop.card_positions(s2)[3]
    shop.set_hover_at(s2, p.x + 2, p.y + 2)
    assert(shop.hover_index(s2) == 3)
    shop.set_hover_at(s2, 0, 0)
    assert(shop.hover_index(s2) == nil, "leaving a slot clears hover")
    shop.set_hover_at(s2, shop.REROLL_X + 2, shop.REROLL_Y + 2)
    assert(shop.hover_index(s2) == nil, "buttons are not shop-slot hover")

    print("  shop_hover: OK")
end

return M
