-- game/tests/play_integration.lua
-- Integration tests for play scene state machine.
-- Headless: no love.graphics required.

local M = {}

function M.run()
    local play = require("game.scenes.play")
    local run  = require("game.run")
    local hwatu = require("game.hwatu")

    -- (1) new scene starts in blind_select state
    local scene = play.new()
    assert(scene.state == "blind_select", "initial state must be blind_select")
    assert(scene.run_state ~= nil, "must have run_state")
    assert(scene.run_state.ante == 1, "ante starts at 1")

    -- (2) select_blind transitions to playing
    play.select_blind(scene, 1) -- small blind
    assert(scene.state == "playing", "after blind select -> playing")
    assert(scene.run_state.blind == "small", "blind must be small")
    assert(scene.hand ~= nil, "must have hand UI state")
    assert(scene.scoreboard ~= nil, "must have scoreboard")
    assert(scene.buttons ~= nil, "must have action buttons")

    -- (3) play_hand evaluates cards and adds score via engine
    -- Deal some cards and play them
    assert(#scene.hand.cards == 8, "must deal 8 cards")
    -- Select first card and play
    local hand_ui = require("game.ui.hand")
    local buttons_ui = require("game.ui.action_buttons")
    hand_ui.select(scene.hand, 1)
    hand_ui.select(scene.hand, 2)
    hand_ui.select(scene.hand, 3)
    buttons_ui.set_selection(scene.buttons, #scene.hand.selected_order)
    local ok = play.play_hand(scene)
    assert(ok, "play_hand must succeed with selection")
    assert(scene.run_state.round_score > 0, "score must increase after play")

    -- (4) play enough to clear blind, then auto-transition to shop
    -- Force score high enough to clear
    local target = run.blind_target(scene.run_state)
    while scene.run_state.round_score < target do
        run.add_score(scene.run_state, target)
    end
    play.check_clear(scene)
    assert(scene.state == "shop", "score >= target -> shop")
    assert(scene.shop ~= nil, "must have shop UI state")

    -- (5) leave_shop transitions to blind_select for next blind
    play.leave_shop(scene)
    assert(scene.state == "blind_select", "after shop -> blind_select")
    assert(scene.run_state.blind == "big", "next blind is big")
    assert(scene.blind_select.current == "big", "blind UI follows the engine's next blind")
    assert(scene.blind_select.blinds[2].available == true
        and scene.blind_select.blinds[1].available == false
        and scene.blind_select.blinds[3].available == false,
        "blind UI cannot replay small or jump ahead to boss")
    assert(scene.run_state.phase == "play", "run phase is play")

    -- (6) discard_hand works
    play.select_blind(scene, 2) -- big blind
    assert(scene.state == "playing")
    hand_ui.select(scene.hand, 1)
    buttons_ui.set_selection(scene.buttons, #scene.hand.selected_order)
    local discard_ok = play.discard_hand(scene)
    assert(discard_ok, "discard must succeed with selection")

    -- (7) full ante cycle: small->big->boss->next ante
    local scene2 = play.new()
    for _, blind_idx in ipairs({1, 2, 3}) do
        assert(scene2.state == "blind_select")
        play.select_blind(scene2, blind_idx)
        assert(scene2.state == "playing")
        -- Force clear
        local t = run.blind_target(scene2.run_state)
        run.add_score(scene2.run_state, t)
        play.check_clear(scene2)
        assert(scene2.state == "shop")
        play.leave_shop(scene2)
    end
    assert(scene2.run_state.ante == 2, "after 3 blinds -> ante 2")
    assert(scene2.run_state.blind == "small", "back to small")

    -- (8) gwang slots sync from run state
    assert(scene2.gwang_slots ~= nil, "must have gwang_slots UI")

    print("  play_integration: OK")
end

return M
