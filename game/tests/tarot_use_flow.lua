-- game/tests/tarot_use_flow.lua
-- Scene-level modal routing from a held tarot to a mutated round hand.

local consumables_ui = require("game.ui.consumables")
local tarot_target_ui = require("game.ui.tarot_target")
local tarots = require("game.tarots")
local play = require("game.scenes.play")

local M = {}

local function center(bounds)
    return bounds.x + math.floor(bounds.w / 2),
        bounds.y + math.floor(bounds.h / 2)
end

local function press(scene, bounds)
    local x, y = center(bounds)
    return scene:mousepressed(x, y)
end

function M.run()
    print("  tarot_use_flow:")

    local scene = play.new("TAROT-USE-FLOW")
    play.select_blind(scene, 1)
    tarots.gain(scene.run_state, "the_magician", "shop")

    local inventory = consumables_ui.view(scene.run_state)
    press(scene, inventory.slots[1].bounds)
    assert(scene.selected_consumable == 1 and scene.tarot_target,
        "selecting a held tarot while playing opens its target modal")

    local before_kind = scene.round.hand[1].kind
    local target_view = tarot_target_ui.view(scene.tarot_target, scene.round.hand)
    press(scene, target_view.targets[1].bounds)
    assert(scene.round.hand[1].kind == before_kind and scene.tarot_target,
        "a required-option tarot cannot target early or leak to the hand below")
    assert(#scene.hand.selected_order == 0,
        "modal target presses cannot select an overlapping hand card")

    scene.hand.cards[1].selected = true
    scene.hand.selected_order = { 1 }
    scene:update(0)
    local hands_before = scene.round.hands_left
    local discards_before = scene.round.discards_left
    scene:keypressed("space")
    scene:keypressed("d")
    assert(scene.round.hands_left == hands_before
            and scene.round.discards_left == discards_before,
        "modal blocks play and discard keyboard shortcuts")

    target_view = tarot_target_ui.view(scene.tarot_target, scene.round.hand)
    press(scene, target_view.options[2].bounds)
    target_view = tarot_target_ui.view(scene.tarot_target, scene.round.hand)
    press(scene, target_view.targets[1].bounds)
    assert(scene.round.hand[1].kind == "cheongdan",
        "completed target request executes the tarot against the engine hand")
    assert(#scene.run_state.tarots == 0, "successful use consumes the held tarot")
    assert(scene.tarot_target == nil and scene.selected_consumable == nil,
        "successful use clears both modal and inventory selection")
    assert(#scene.hand.cards == #scene.round.hand
            and scene.hand.cards[1].kind == "cheongdan",
        "mutated engine hand is redealt into the hand UI")
    assert(#scene.hand.selected_order == 0,
        "tarot use clears stale hand-card selection")

    tarots.gain(scene.run_state, "the_hanged_man", "shop")
    inventory = consumables_ui.view(scene.run_state)
    press(scene, inventory.slots[1].bounds)
    local flow = scene.tarot_target
    target_view = tarot_target_ui.view(flow, scene.round.hand)
    press(scene, target_view.cancel_bounds)
    assert(scene.tarot_target == nil and scene.selected_consumable == nil,
        "cancel closes the modal without consuming the tarot")
    assert(#scene.run_state.tarots == 1,
        "cancel preserves the held tarot")

    print("  tarot_use_flow: OK")
end

return M
