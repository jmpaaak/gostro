-- Tests for game/ui/hand.lua
-- Runs in headless mode: tests data/logic only (no love.graphics calls).

local hand = require("game.ui.hand")
local card = require("game.ui.card")

local M = {}

function M.run()
    -- new() creates empty hand state
    local h = hand.new()
    assert(#h.cards == 0, "starts empty")
    assert(#h.selected_order == 0, "no selection order")

    -- deal 8 cards
    local kinds = {"hongdan", "cheongdan", "chodan", "godori", "pi",
                   "hongdan", "cheongdan", "pi"}
    hand.deal(h, kinds)
    assert(#h.cards == 8, "8 cards dealt")

    -- cards are positioned horizontally with overlap
    for i = 1, 8 do
        assert(h.cards[i].kind == kinds[i])
        assert(h.cards[i].x ~= nil, "x assigned")
        assert(h.cards[i].y ~= nil, "y assigned")
    end
    -- overlap: second card x > first card x, but not by full card width
    local gap = h.cards[2].x - h.cards[1].x
    assert(gap > 0, "cards go left to right")
    assert(gap < card.WIDTH, "cards overlap (Balatro style)")
    assert(h.cards[1].angle < 0 and h.cards[8].angle > 0, "fan tilts out from center")

    -- select first card
    local ok = hand.select(h, 1)
    assert(ok == true, "selection succeeds")
    assert(h.cards[1].selected == true, "card 1 selected")
    assert(#h.selected_order == 1)
    assert(h.selected_order[1] == 1, "order tracks index")

    -- select up to 5
    hand.select(h, 3)
    hand.select(h, 5)
    hand.select(h, 7)
    hand.select(h, 8)
    assert(#h.selected_order == 5, "5 selected")

    -- 6th selection rejected (max 5)
    ok = hand.select(h, 2)
    assert(ok == false, "6th selection rejected")
    assert(h.cards[2].selected == false, "card 2 still unselected")
    assert(#h.selected_order == 5)

    -- deselect restores slot
    hand.deselect(h, 3)
    assert(h.cards[3].selected == false)
    assert(#h.selected_order == 4)

    -- now can select again
    ok = hand.select(h, 2)
    assert(ok == true, "slot freed, can select again")
    assert(#h.selected_order == 5)

    -- toggle: selected card gets deselected
    hand.toggle(h, 2)
    assert(h.cards[2].selected == false)
    assert(#h.selected_order == 4)

    -- toggle: unselected card gets selected
    hand.toggle(h, 6)
    assert(h.cards[6].selected == true)
    assert(#h.selected_order == 5)

    -- selection_index returns the 1-based order
    -- rebuild known state
    h = hand.new()
    hand.deal(h, {"pi", "pi", "pi", "pi", "pi", "pi", "pi", "pi"})
    hand.select(h, 3)
    hand.select(h, 1)
    hand.select(h, 5)
    assert(hand.selection_index(h, 3) == 1, "card 3 selected first")
    assert(hand.selection_index(h, 1) == 2, "card 1 selected second")
    assert(hand.selection_index(h, 5) == 3, "card 5 selected third")
    assert(hand.selection_index(h, 2) == nil, "card 2 not selected")

    -- get_selected returns cards in selection order
    local sel = hand.get_selected(h)
    assert(#sel == 3)
    assert(sel[1] == h.cards[3])
    assert(sel[2] == h.cards[1])
    assert(sel[3] == h.cards[5])

    -- Card objects preserve persistent gameplay metadata when dealt.
    local source = {
        { kind = "hongdan", effect = "foil", uid = "card-1" },
        { kind = "pi", effect = "polychrome", uid = "card-2" },
    }
    local rich = hand.new()
    hand.deal(rich, source)
    assert(rich.cards[1].effect == "foil", "deal preserves card edition")
    assert(rich.cards[1].uid == "card-1", "deal preserves card identity")
    assert(rich.cards[2].effect == "polychrome", "each card keeps its own metadata")
    assert(rich.cards[1] ~= source[1], "UI deal does not mutate the deck card")
    assert(source[1].x == nil and source[1].selected == nil, "source card remains domain-only")

    -- MAX_SELECT is 5
    assert(hand.MAX_SELECT == 5)

    -- 8 cards of 72px with 42px step: fan = 7*42+72 = 366, fits in 960
    local fan = (8 - 1) * 42 + card.WIDTH
    assert(fan <= 960, "8-card fan must fit the 960px viewport")
    assert(h.cards[1].y + card.HEIGHT <= 540, "cards stay inside 540px viewport")
    assert(h.cards[1].y > 300, "cards near bottom of 540px viewport")

    print("  hand_ui OK")
end

return M
