-- Tests for game/ui/card.lua
-- Runs in headless mode: tests data/logic only (no love.graphics calls).

local card = require("game.ui.card")

local M = {}

function M.run()
    require("game.tests.card_art").run()

    -- Constants
    assert(card.WIDTH == 72, "card width must be 72")
    assert(card.HEIGHT == 108, "card height must be 108")
    assert(card.LIFT == 16, "selected lift must be 16")

    -- new() creates a card widget with position and kind
    local c = card.new("hongdan", 10, 50)
    assert(c.kind == "hongdan")
    assert(c.x == 10)
    assert(c.y == 50)
    assert(c.selected == false, "card starts unselected")

    -- All valid play card kinds
    for _, kind in ipairs({"hongdan", "cheongdan", "chodan", "godori", "pi"}) do
        local k = card.new(kind, 0, 0)
        assert(k.kind == kind)
    end

    -- gwang is NOT a play card
    local ok = pcall(card.new, "gwang", 0, 0)
    assert(not ok, "gwang is a joker, not a play card")

    -- Unknown kind rejected
    ok = pcall(card.new, "mae", 0, 0)
    assert(not ok, "unknown kinds rejected")

    -- toggle_select flips selected state
    card.toggle_select(c)
    assert(c.selected == true)
    card.toggle_select(c)
    assert(c.selected == false)

    -- draw_y returns y - LIFT when selected, y otherwise
    assert(card.draw_y(c) == 50)
    c.selected = true
    assert(card.draw_y(c) == 50 - card.LIFT)

    -- symbol() returns the correct symbol for each kind
    assert(card.symbol("hongdan") == "▐", "hongdan = red flag")
    assert(card.symbol("cheongdan") == "▌", "cheongdan = blue flag")
    assert(card.symbol("chodan") == "❀", "chodan = orchid")
    assert(card.symbol("godori") == "♦", "godori = animal/bird")
    assert(card.symbol("pi") == "·", "pi = dot")

    -- hit_test checks if a point is inside the card rect
    local h = card.new("pi", 100, 100)
    assert(card.hit_test(h, 100, 100) == true, "top-left corner")
    assert(card.hit_test(h, 171, 207) == true, "bottom-right inside")
    assert(card.hit_test(h, 172, 208) == false, "outside right/bottom")
    assert(card.hit_test(h, 99, 100) == false, "outside left")
    -- hit_test uses draw_y for selected cards
    h.selected = true
    assert(card.hit_test(h, 100, 84) == true, "selected card lifted hitbox")
    assert(card.hit_test(h, 100, 83) == false, "above lifted hitbox")

    -- color table exists for each kind
    for _, kind in ipairs({"hongdan", "cheongdan", "chodan", "godori", "pi"}) do
        local col = card.bg_color(kind)
        assert(type(col) == "table" and #col >= 3, kind .. " needs bg color")
    end

    print("  card_ui OK")
end

return M
