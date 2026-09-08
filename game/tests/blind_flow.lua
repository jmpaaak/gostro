local blind_flow = require("game.blind_flow")
local run_state = require("game.run_state")
local run_history = require("game.run_history")

local M = {}

local function fails(fn, message)
    local ok = pcall(fn)
    assert(not ok, message)
end

local function beat_and_leave_shop(state)
    blind_flow.score(state, blind_flow.target(state), state.hands_left)
    blind_flow.clear(state)
    blind_flow.leave_shop(state)
end

function M.test_view_exposes_sequential_blinds_and_run_targets()
    local state = run_state.new("blind-flow-sequence")
    local view = blind_flow.view(state, "coupon")

    assert(view.ante == 1 and view.current == "small" and view.phase == "play")
    assert(#view.blinds == 3)
    for i, kind in ipairs({ "small", "big", "boss" }) do
        local card = view.blinds[i]
        local projected = run_state.new("blind-flow-target")
        projected.ante = state.ante
        projected.blind = kind
        assert(card.kind == kind)
        assert(card.target == blind_flow.target(projected), kind .. " target uses run rules")
        assert(card.playable == (kind == "small"), "only current blind is playable")
    end
    assert(view.blinds[1].status == "current")
    assert(view.blinds[2].status == "upcoming")
    assert(view.blinds[3].status == "upcoming")

    blind_flow.skip_current(state, "coupon")
    view = blind_flow.view(state, "investment")
    assert(view.current == "big")
    assert(view.blinds[1].status == "completed")
    assert(view.blinds[2].status == "current" and view.blinds[2].playable)
    assert(view.blinds[3].status == "upcoming" and not view.blinds[3].playable)
end

function M.test_skip_eligibility_requires_current_small_or_big_and_tag()
    local state = run_state.new("blind-flow-skip-view")
    local no_tag = blind_flow.view(state)
    assert(not no_tag.blinds[1].skippable, "skip requires an offered tag")

    local view = blind_flow.view(state, "coupon")
    assert(view.blinds[1].skippable == true)
    assert(view.blinds[1].skip_tag.id == "coupon")
    assert(view.blinds[1].skip_tag.name ~= nil)
    assert(not view.blinds[2].skippable and not view.blinds[3].skippable)

    blind_flow.skip_current(state, "coupon")
    view = blind_flow.view(state, "mega")
    assert(view.blinds[2].skippable == true and view.blinds[2].skip_tag.id == "mega")

    blind_flow.skip_current(state, "mega")
    view = blind_flow.view(state, "coupon")
    assert(state.blind == "boss" and state.boss_id ~= nil)
    assert(not view.blinds[3].skippable, "boss cannot be skipped")

    state.phase = "shop"
    view = blind_flow.view(state, "coupon")
    assert(not view.blinds[3].playable and not view.blinds[3].skippable)
    fails(function() blind_flow.view(state, "not-a-tag") end, "invalid tag is rejected")
end

function M.test_selection_only_accepts_current_blind()
    local state = run_state.new("blind-flow-select")
    fails(function() blind_flow.select(state, "big") end, "cannot jump to big")
    fails(function() blind_flow.select(state, "boss") end, "cannot jump to boss")
    assert(state.blind == "small")

    local selected = blind_flow.select(state, "small")
    assert(selected.kind == "small")
    assert(selected.target == blind_flow.target(state))
    assert(selected.playable == true)

    state.phase = "shop"
    fails(function() blind_flow.select(state, "small") end, "cannot select outside play")
end

function M.test_skip_owns_progression_and_tag_application()
    local state = run_state.new("blind-flow-skip")
    blind_flow.skip(state, "small", "investment")
    assert(state.blind == "big" and state.phase == "play")
    assert(state.tags.pending_money == 15)

    blind_flow.skip(state, "big", "mega")
    assert(state.blind == "boss" and state.phase == "play")
    assert(state.tags.duplicate_next_gwang == true)
    assert(state.boss_id ~= nil, "run transition selected the boss")

    fails(function() blind_flow.skip(state, "boss", "coupon") end, "boss cannot skip")
    fails(function() blind_flow.skip(run_state.new(), "small", nil) end, "skip requires a tag")

    local future = run_state.new()
    fails(function() blind_flow.skip(future, "big", "coupon") end, "cannot skip a future blind")
    assert(future.blind == "small" and #future.tags.owned == 0)

    local outside_play = run_state.new()
    outside_play.phase = "shop"
    fails(function() blind_flow.skip(outside_play, "small", "coupon") end,
        "cannot skip outside play")
    assert(outside_play.blind == "small" and #outside_play.tags.owned == 0,
        "rejected skip does not grant a tag or advance")

end

function M.test_boss_selection_and_target_are_owned_by_blind_flow()
    local state = run_state.new("blind-flow-boss")
    state.blind = "boss"
    state.boss = nil
    state.boss_id = nil

    local definition = blind_flow.select_boss(state, "wall")
    assert(definition.id == "wall")
    assert(state.boss_id == "wall")
    assert(state.boss ~= definition, "run state owns a copy of the catalog definition")
    assert(state.boss.id == definition.id and state.boss.name == definition.name)

    local selected = blind_flow.select(state, "boss")
    assert(selected.boss.id == "wall")
    assert(selected.target == blind_flow.target(state))
    assert(selected.target == 1200, "wall target is resolved by blind_flow.target")

    local view = blind_flow.view(state, "coupon")
    assert(view.blinds[3].boss.id == "wall")
    assert(view.blinds[3].target == 1200)
    assert(not view.blinds[3].skippable)
end

function M.test_enter_owns_boss_setup_and_cleanup()
    local state = run_state.new("blind-flow-enter")

    local entered = blind_flow.enter(state, "boss", "hook")
    assert(state.blind == "boss" and state.boss_id == "hook")
    assert(state.boss.id == "hook" and entered.kind == "boss")

    blind_flow.enter(state, "small")
    assert(state.blind == "small" and state.boss_id == nil and state.boss == nil,
        "entering a non-boss blind clears the previous boss")

    fails(function() blind_flow.enter(state, "unknown") end,
        "blind entry rejects unknown kinds")
    assert(state.blind == "small", "rejected entry does not mutate state")
end

function M.test_completed_progression_is_derived_from_run_state()
    local state = run_state.new("blind-flow-clears")
    beat_and_leave_shop(state)
    assert(blind_flow.view(state, "coupon").current == "big")
    beat_and_leave_shop(state)
    assert(state.blind == "boss" and state.boss_id ~= nil)
    assert(blind_flow.view(state, "coupon").current == "boss")
    beat_and_leave_shop(state)
    local view = blind_flow.view(state, "coupon")
    assert(view.ante == 2 and view.current == "small")
end

function M.test_begin_owns_stake_adjusted_round_transition()
    local run_rules = require("game.run_rules")
    local state = assert(run_rules.apply(run_state.new("blind-flow-begin"), {
        starting_deck_id = "hwatu",
        stake_id = "red",
    }, { unlocked_stakes = { red = true } }))
    state.round_score = 99

    local view = blind_flow.view(state, "coupon")
    assert(view.blinds[1].target == 375,
        "blind flow exposes the stake-adjusted target before selection")

    local selected = blind_flow.begin(state, "small")
    assert(selected.kind == "small" and selected.target == 375,
        "begin returns the canonical adjusted target")
    assert(selected.discards == 2, "begin returns the stake-adjusted discard limit")
    assert(state.phase == "play" and state.round_score == 0,
        "blind flow owns round transition reset state")
end

function M.test_clear_and_shop_exit_own_sequential_progression()
    local run_rules = require("game.run_rules")
    local state = assert(run_rules.apply(run_state.new("blind-flow-progression"), {
        starting_deck_id = "hwatu",
        stake_id = "red",
    }, { unlocked_stakes = { red = true } }))
    blind_flow.score(state, blind_flow.target(state) - 75, state.hands_left)

    assert(blind_flow.clear(state, 2) == nil,
        "clear waits for the stake-adjusted target")
    assert(state.phase == "play", "an uncleared blind stays in play")

    blind_flow.score(state, 75, state.hands_left)
    assert(blind_flow.clear(state, 2) == "shop",
        "clear returns the resulting shop phase")
    assert(state.phase == "shop" and state.hands_left == 2,
        "clear carries the round hand count into cash out")

    local next_blind = blind_flow.leave_shop(state)
    assert(next_blind.ante == 1 and next_blind.kind == "big")
    assert(state.phase == "play" and state.round_score == 0,
        "shop exit prepares the next blind selection")
end

function M.test_shop_exit_owns_every_progression_and_round_reset()
    local state = run_state.new("blind-flow-shop-exit-owner")
    state.phase = "shop"
    state.round_score = 321
    state.hands_left = 1
    state.vouchers.hands = 2
    state.vouchers.shop_id = "overstock"
    state.vouchers.bought_this_shop = true

    local big = blind_flow.leave_shop(state)
    assert(big.ante == 1 and big.kind == "big" and big.phase == "play")
    assert(state.round_score == 0 and state.hands_left == 6,
        "shop exit resets score and applies the permanent extra-hand voucher")
    assert(state.vouchers.shop_id == nil and state.vouchers.bought_this_shop == false,
        "shop exit clears temporary voucher stock")

    state.phase = "shop"
    local boss = blind_flow.leave_shop(state)
    assert(boss.kind == "boss" and state.boss_id ~= nil,
        "big shop exit enters and selects the boss")

    state.phase = "shop"
    local next_ante = blind_flow.leave_shop(state)
    assert(next_ante.ante == 2 and next_ante.kind == "small")
    assert(state.boss_id == nil and state.boss == nil,
        "boss shop exit starts the next ante without stale boss state")

end

function M.test_clear_owns_cash_out_shop_stock_and_final_win()
    local run_history = require("game.run_history")
    local state = run_state.new("blind-flow-clear-owner")
    state.hands_left = 2
    state.round_score = blind_flow.target(state)

    assert(blind_flow.clear(state) == "shop")
    assert(state.money == 9, "clear cashes out blind reward and remaining hands")
    assert(state.vouchers.shop_id ~= nil, "clear stocks the next shop voucher")

    run_history.reset()
    local final = run_state.new("blind-flow-final-win")
    final.ante = 8
    blind_flow.enter(final, "boss", "wall")
    final.round_score = blind_flow.target(final)
    assert(blind_flow.clear(final, 1) == "won")
    assert(final.phase == "won", "final boss clear ends the run without a shop")
    local history = run_history.list()
    assert(#history == 1 and history[1].outcome == "won" and history[1].ante == 8,
        "final clear records one win")

end

function M.test_lose_owns_exhausted_hand_transition()
    run_history.reset()
    local state = run_state.new("blind-flow-loss")
    state.round_score = blind_flow.target(state) - 1
    fails(function() blind_flow.lose(state, 1) end,
        "loss requires the round to exhaust its hands")
    assert(state.phase == "play", "invalid loss does not mutate the run")

    assert(blind_flow.lose(state, 0) == "lost",
        "loss returns the resulting run phase")
    assert(state.phase == "lost" and state.hands_left == 0,
        "loss carries the exhausted hand count into run state")
    local history = run_history.list()
    assert(#history == 1 and history[1].outcome == "lost"
            and history[1].seed == "BLINDFLOWLOSS",
        "loss records the run directly through run history")

    local cleared = run_state.new("blind-flow-not-loss")
    blind_flow.score(cleared, blind_flow.target(cleared), cleared.hands_left)
    fails(function() blind_flow.lose(cleared, 0) end,
        "a completed blind cannot be recorded as a loss")
    assert(cleared.phase == "play", "completed blind remains available to clear")
end

function M.test_score_owns_hand_result_transfer()
    local state = run_state.new("blind-flow-score")
    state.round_score = 25
    state.hands_left = 4
    assert(blind_flow.score(state, 120, 3) == 145,
        "score returns the accumulated round score")
    assert(state.round_score == 145 and state.hands_left == 3,
        "score transfers points and the round engine hand count together")

    state.phase = "shop"
    fails(function() blind_flow.score(state, 10, 2) end,
        "score rejects results outside active play")
    assert(state.round_score == 145 and state.hands_left == 3,
        "a rejected score result does not mutate run state")
end

function M.run()
    M.test_view_exposes_sequential_blinds_and_run_targets()
    M.test_skip_eligibility_requires_current_small_or_big_and_tag()
    M.test_selection_only_accepts_current_blind()
    M.test_skip_owns_progression_and_tag_application()
    M.test_boss_selection_and_target_are_owned_by_blind_flow()
    M.test_enter_owns_boss_setup_and_cleanup()
    M.test_completed_progression_is_derived_from_run_state()
    M.test_begin_owns_stake_adjusted_round_transition()
    M.test_clear_and_shop_exit_own_sequential_progression()
    M.test_shop_exit_owns_every_progression_and_round_reset()
    M.test_clear_owns_cash_out_shop_stock_and_final_win()
    M.test_lose_owns_exhausted_hand_transition()
    M.test_score_owns_hand_result_transfer()
    print("  blind_flow: OK")
end

return M
