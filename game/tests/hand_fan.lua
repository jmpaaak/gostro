-- Hand cards fan by angle; playing gathers the selection toward center.

local hand = require("game.ui.hand")
local play = require("game.scenes.play")

local M = {}

function M.run()
    local h = hand.new()
    hand.deal(h, { "pi", "pi", "pi", "pi", "pi", "pi", "pi", "pi" })
    assert(h.cards[1].angle < 0, "left cards tilt left")
    assert(h.cards[8].angle > 0, "right cards tilt right")
    local mid_left, mid_right = h.cards[4].angle, h.cards[5].angle
    assert(mid_left < 0 and mid_right > 0, "center pair straddles 0")
    assert(math.abs(hand.fan_angle(1, 8) - h.cards[1].angle) < 1e-6)

    hand.select(h, 1)
    hand.select(h, 4)
    hand.select(h, 8)
    local gather = hand.start_gather(h)
    assert(gather and #gather.cards == 3)
    local first = gather.cards[1]
    assert(first.to_y < first.from_y, "played cards rise toward the table center")
    assert(first.to_angle == 0)
    local start_x = h.cards[1].x
    hand.update(h, hand.GATHER_DURATION * 0.5)
    assert(h.gather, "gather is in flight")
    assert(h.cards[1].x ~= start_x or h.cards[1].y ~= first.from_y)
    hand.update(h, hand.GATHER_DURATION)
    assert(h.gather == nil, "gather finishes")
    assert(h.cards[1].angle == 0)

    local scene = play.new("HAND-FAN")
    play.select_blind(scene, 1)
    require("game.ui.hand").select(scene.hand, 1)
    require("game.ui.action_buttons").set_selection(scene.buttons, 1)
    assert(play.play_hand(scene))
    assert(scene.hand.gather, "playing a hand gathers the selection")

    print("  hand_fan: OK")
end

return M
