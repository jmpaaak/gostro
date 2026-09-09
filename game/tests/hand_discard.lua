-- Discarded cards slide off to the right before the hand is redealt.

local hand = require("game.ui.hand")
local play = require("game.scenes.play")

local M = {}

function M.run()
    local h = hand.new()
    hand.deal(h, { "pi", "pi", "pi", "pi", "pi", "pi", "pi", "pi" })
    hand.select(h, 1)
    hand.select(h, 8)
    local start_left = h.cards[1].x
    local start_right = h.cards[8].x
    local slide = hand.start_discard_slide(h)
    assert(slide and #slide.cards == 2, "selected cards begin a discard slide")
    assert(slide.cards[1].to_x > slide.cards[1].from_x, "cards slide right")
    assert(slide.cards[2].to_x > slide.cards[2].from_x)
    hand.update(h, hand.SLIDE_DURATION * 0.5)
    assert(h.slide, "slide is in flight")
    assert(h.cards[1].x > start_left, "left discard moves right")
    assert(h.cards[8].x > start_right, "right discard moves right")
    hand.update(h, hand.SLIDE_DURATION)
    assert(h.slide == nil, "slide finishes")

    local scene = play.new("HAND-DISCARD")
    play.select_blind(scene, 1)
    require("game.ui.hand").select(scene.hand, 1)
    require("game.ui.action_buttons").set_selection(scene.buttons, 1)
    local before = #scene.hand.cards
    assert(play.discard_hand(scene))
    assert(scene.hand.slide, "discarding starts a rightward slide")
    assert(#scene.hand.cards == before, "hand is not redealt until the slide ends")
    scene:update(hand.SLIDE_DURATION + 0.01)
    assert(scene.hand.slide == nil, "live discard slide finishes")
    assert(#scene.hand.cards == 8, "hand is redealt after the slide")

    print("  hand_discard: OK")
end

return M
