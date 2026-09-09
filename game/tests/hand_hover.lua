-- Hover lifts an unselected card; selected lift still wins.

local card = require("game.ui.card")
local hand = require("game.ui.hand")

local M = {}

function M.run()
    assert(card.HOVER_LIFT > 0 and card.HOVER_LIFT < card.LIFT,
        "hover lift is a smaller peek than selection")

    local c = card.new("pi", 100, 200)
    assert(card.draw_y(c) == 200)
    c.hovered = true
    assert(card.draw_y(c) == 200 - card.HOVER_LIFT, "hovered cards rise")
    c.selected = true
    assert(card.draw_y(c) == 200 - card.LIFT, "selection lift beats hover")

    local h = hand.new()
    hand.deal(h, { "pi", "hongdan", "godori" })
    assert(hand.hover_index(h) == nil)
    hand.set_hover(h, 2)
    assert(hand.hover_index(h) == 2)
    assert(h.cards[2].hovered == true)
    assert(h.cards[1].hovered ~= true)

    local idx = hand.hit_test(h, h.cards[3].x + 4, h.cards[3].y + 4)
    assert(idx == 3)
    hand.set_hover_at(h, h.cards[3].x + 4, h.cards[3].y + 4)
    assert(hand.hover_index(h) == 3)
    hand.set_hover_at(h, 0, 0)
    assert(hand.hover_index(h) == nil, "leaving the fan clears hover")

    print("  hand_hover: OK")
end

return M
