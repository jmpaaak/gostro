-- game/tests/shop_ui.lua
-- Headless tests for game/ui/shop.lua

local shop = require("game.ui.shop")

local M = {}

function M.run()
    -- new() returns valid initial state with 3 cards, money, reroll cost
    local s = shop.new(100)
    assert(s.money == 100, "initial money 100, got " .. tostring(s.money))
    assert(#s.cards == 3, "3 cards on display, got " .. #s.cards)
    for i, c in ipairs(s.cards) do
        assert(c.kind == "gwang" or c.kind == "wish_card", "card " .. i .. " is gwang or wish card")
        assert(c.identity ~= nil, "card " .. i .. " has identity")
        assert(c.price > 0, "card " .. i .. " has price > 0")
    end

    -- buy_card: purchase first card, money decreases
    local s2 = shop.new(50)
    local card = s2.cards[1]
    local price = card.price
    local ok, bought = shop.buy_card(s2, 1)
    assert(ok == true, "buy succeeds")
    assert(bought.kind == "gwang" or bought.kind == "wish_card", "bought valid kind")
    assert(s2.money == 50 - price, "money decreased by price")
    assert(s2.cards[1] == nil or s2.cards[1].sold == true, "slot emptied or marked sold")

    -- buy_card: fail when not enough money
    local s3 = shop.new(0)
    local ok3 = shop.buy_card(s3, 1)
    assert(ok3 == false, "buy fails with 0 money")

    -- buy_card: fail for invalid index
    local s4 = shop.new(100)
    local ok4 = shop.buy_card(s4, 0)
    assert(ok4 == false, "buy fails for index 0")
    local ok5 = shop.buy_card(s4, 4)
    assert(ok5 == false, "buy fails for index 4")

    -- buy_card: fail for already-sold slot
    local s5 = shop.new(200)
    shop.buy_card(s5, 2)
    local ok6 = shop.buy_card(s5, 2)
    assert(ok6 == false, "cannot buy already-sold slot")

    -- reroll: replaces unsold cards, costs $5
    local s6 = shop.new(50)
    local old_ids = {}
    for i = 1, 3 do old_ids[i] = s6.cards[i].identity end
    local rok = shop.reroll(s6)
    assert(rok == true, "reroll succeeds with enough money")
    assert(s6.money == 50 - shop.REROLL_COST, "money decreased by reroll cost")
    assert(#s6.cards == 3, "still 3 cards after reroll")

    -- reroll: fail when not enough money
    local s7 = shop.new(2)
    local rok2 = shop.reroll(s7)
    assert(rok2 == false, "reroll fails with insufficient money")
    assert(s7.money == 2, "money unchanged on failed reroll")

    -- can_reroll
    local s8 = shop.new(5)
    assert(shop.can_reroll(s8) == true, "can reroll with exact money")
    s8.money = 4
    assert(shop.can_reroll(s8) == false, "cannot reroll below cost")

    -- hit_test: reroll button
    local btn = shop.hit_test(s8, shop.REROLL_X + 2, shop.REROLL_Y + 2)
    assert(btn == "reroll", "hit reroll button, got " .. tostring(btn))

    -- hit_test: next round button
    btn = shop.hit_test(s8, shop.NEXT_X + 2, shop.NEXT_Y + 2)
    assert(btn == "next", "hit next button, got " .. tostring(btn))

    -- hit_test: card slots
    for i = 1, 3 do
        local pos = shop.card_positions()
        local p = pos[i]
        btn = shop.hit_test(s8, p.x + 2, p.y + 2)
        assert(btn == i, "hit card " .. i .. ", got " .. tostring(btn))
    end

    -- hit_test: miss
    btn = shop.hit_test(s8, 0, 0)
    assert(btn == nil, "miss returns nil")

    -- Engine-owned shops expose every random, pack, and voucher slot.
    local engine_shop = {
        run_state = { money = 17 },
        random_offers = {
            { slot_type = "random", kind = "gwang", identity = "one", price = 4 },
            { slot_type = "random", kind = "wish_card", identity = "two", price = 3 },
            { slot_type = "random", kind = "talisman", identity = "three", price = 3 },
            { slot_type = "random", kind = "gwang", identity = "extra", price = 4 },
        },
        pack_slots = {
            { slot_type = "pack", kind = "pack", identity = "talisman_bundle", name = "부적 꾸러미", price = 4 },
        },
        voucher_slots = {
            { slot_type = "voucher", kind = "voucher", identity = "paint_brush", price = 10 },
        },
    }
    engine_shop.slots = {
        engine_shop.random_offers[1], engine_shop.random_offers[2],
        engine_shop.random_offers[3], engine_shop.random_offers[4],
        engine_shop.pack_slots[1], engine_shop.voucher_slots[1],
    }
    local engine_positions = shop.card_positions(engine_shop)
    assert(#engine_positions == 6, "all engine slots have positions")
    for i = 1, 6 do
        local p = engine_positions[i]
        assert(shop.hit_test(engine_shop, p.x + 1, p.y + 1) == i,
            "engine slot " .. i .. " is hit-testable")
    end
    local views = shop.slot_views(engine_shop)
    assert(#views == 6, "all engine slots have view data")
    assert(views[5].slot_type == "pack" and views[5].label == "부적 꾸러미",
        "pack slot is represented")
    assert(views[6].slot_type == "voucher" and views[6].label ~= "?",
        "voucher slot is represented")
    assert(views[2].label == "기원패", "wish-card fallback uses the Korean category name")

    local legacy_view = shop.slot_views({ cards = {
        { kind = "planet", identity = "planet_hongdan", price = 3 },
    } })
    assert(legacy_view[1].label == "기원패", "legacy offers never expose the old category name")

    -- money_text accepts both legacy UI state and engine-owned run money.
    local txt = shop.money_text(s8)
    assert(txt:find("%$"), "money text contains $")
    assert(shop.money_text(engine_shop) == "$17", "engine money is displayed")

    print("  shop_ui: OK")
end

return M
