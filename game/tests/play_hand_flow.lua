-- Gathered cards stay until chips→mult→total finishes, then the fan redeals.

local play = require("game.scenes.play")
local hand_ui = require("game.ui.hand")
local buttons_ui = require("game.ui.action_buttons")
local score_anim = require("game.ui.score_anim")

local M = {}

function M.run()
    local scene = play.new("HAND-FLOW")
    play.select_blind(scene, 1)
    hand_ui.select(scene.hand, 1)
    hand_ui.select(scene.hand, 2)
    buttons_ui.set_selection(scene.buttons, 2)
    local before = {}
    for i, c in ipairs(scene.hand.cards) do
        before[i] = c
    end
    assert(play.play_hand(scene))
    assert(scene.hand.gather, "played cards gather first")
    assert(scene.score_anim.card_popups[1].anchor == before[1],
        "chip popup anchors to the live gathered card widget")
    assert(scene.pending_redeal)
    scene:update(hand_ui.GATHER_DURATION + 0.01)
    assert(scene.hand.gather == nil, "gather finishes")
    assert(scene.pending_redeal, "redeal waits for the score timeline")
    assert(scene.hand.cards[1] == before[1], "fan stays until scoring ends")
    assert(score_anim.is_playing(scene.score_anim))

    local budget = score_anim.CARD_DELAY * 3
        + score_anim.MULT_DURATION
        + score_anim.TOTAL_DURATION
        + 0.05
    scene:update(budget)
    assert(not score_anim.is_playing(scene.score_anim), "score timeline finished")
    assert(scene.pending_redeal == nil, "hand redeals after the timeline")
    assert(scene.hand.cards[1] ~= before[1], "a new fan is dealt")

    print("  play_hand_flow: OK")
end

return M
