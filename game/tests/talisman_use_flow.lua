-- game/tests/tarot_use_flow.lua
-- Scene-level modal routing from a held talisman to a mutated round hand.

local consumables_ui = require("game.ui.consumables")
local talisman_target_ui = require("game.ui.talisman_target")
local talismans = require("game.talismans")
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
    print("  talisman_use_flow:")

    local scene = play.new("TALISMAN-USE-FLOW")
    play.select_blind(scene, 1)
    talismans.gain(scene.run_state, "dungap_bu", "shop")

    local inventory = consumables_ui.view(scene.run_state)
    press(scene, inventory.slots[1].bounds)
    assert(scene.selected_consumable == 1 and scene.talisman_target,
        "selecting a held talisman while playing opens its target modal")

    local before_kind = scene.round.hand[1].kind
    local target_view = talisman_target_ui.view(scene.talisman_target, scene.round.hand)
    press(scene, target_view.targets[1].bounds)
    assert(scene.round.hand[1].kind == before_kind and scene.talisman_target,
        "a required-option talisman cannot target early or leak to the hand below")
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

    target_view = talisman_target_ui.view(scene.talisman_target, scene.round.hand)
    press(scene, target_view.options[2].bounds)
    target_view = talisman_target_ui.view(scene.talisman_target, scene.round.hand)
    press(scene, target_view.targets[1].bounds)
    assert(scene.round.hand[1].kind == "cheongdan",
        "completed target request executes the talisman against the engine hand")
    assert(#scene.run_state.talismans == 0,
        "successful use consumes the held talisman")
    assert(scene.talisman_target == nil and scene.selected_consumable == nil,
        "successful use clears both modal and inventory selection")
    assert(#scene.hand.cards == #scene.round.hand
            and scene.hand.cards[1].kind == "cheongdan",
        "mutated engine hand is redealt into the hand UI")
    assert(#scene.hand.selected_order == 0,
        "talisman use clears stale hand-card selection")

    talismans.gain(scene.run_state, "somyeol_bu", "shop")
    inventory = consumables_ui.view(scene.run_state)
    press(scene, inventory.slots[1].bounds)
    local flow = scene.talisman_target
    target_view = talisman_target_ui.view(flow, scene.round.hand)
    press(scene, target_view.cancel_bounds)
    assert(scene.talisman_target == nil and scene.selected_consumable == nil,
        "cancel closes the modal without consuming the talisman")
    assert(#scene.run_state.talismans == 1,
        "cancel preserves the held talisman")

    print("  talisman_use_flow: OK")
end

return M
