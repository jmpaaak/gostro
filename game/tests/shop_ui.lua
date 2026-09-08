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
        assert(c.kind == "gwang", "card " .. i .. " is gwang")
        assert(c.identity ~= nil, "card " .. i .. " has identity")
        assert(c.price > 0, "card " .. i .. " has price > 0")
    end

    -- buy_card: purchase first card, money decreases
    local s2 = shop.new(50)
    local card = s2.cards[1]
    local price = card.price
    local ok, bought = shop.buy_card(s2, 1)
    assert(ok == true, "buy succeeds")
    assert(bought.kind == "gwang", "bought gwang")
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

    -- money_text
    local txt = shop.money_text(s8)
    assert(txt:find("%$"), "money text contains $")

    print("  shop_ui: OK")
end

return M
