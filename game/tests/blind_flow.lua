local blind_flow = require("game.blind_flow")
local run = require("game.run")

local M = {}

local function fails(fn, message)
    local ok = pcall(fn)
    assert(not ok, message)
end

local function beat_and_leave_shop(state)
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    run.leave_shop(state)
end

function M.test_view_exposes_sequential_blinds_and_run_targets()
    local state = run.new("blind-flow-sequence")
    local view = blind_flow.view(state, "coupon")

    assert(view.ante == 1 and view.current == "small" and view.phase == "play")
    assert(#view.blinds == 3)
    for i, kind in ipairs({ "small", "big", "boss" }) do
        local card = view.blinds[i]
        local projected = run.new("blind-flow-target")
        projected.ante = state.ante
        projected.blind = kind
        assert(card.kind == kind)
        assert(card.target == run.blind_target(projected), kind .. " target uses run rules")
        assert(card.playable == (kind == "small"), "only current blind is playable")
    end
    assert(view.blinds[1].status == "current")
    assert(view.blinds[2].status == "upcoming")
    assert(view.blinds[3].status == "upcoming")

    run.skip_blind(state, "coupon")
    view = blind_flow.view(state, "investment")
    assert(view.current == "big")
    assert(view.blinds[1].status == "completed")
    assert(view.blinds[2].status == "current" and view.blinds[2].playable)
    assert(view.blinds[3].status == "upcoming" and not view.blinds[3].playable)
end

function M.test_skip_eligibility_requires_current_small_or_big_and_tag()
    local state = run.new("blind-flow-skip-view")
    local no_tag = blind_flow.view(state)
    assert(not no_tag.blinds[1].skippable, "skip requires an offered tag")

    local view = blind_flow.view(state, "coupon")
    assert(view.blinds[1].skippable == true)
    assert(view.blinds[1].skip_tag.id == "coupon")
    assert(view.blinds[1].skip_tag.name ~= nil)
    assert(not view.blinds[2].skippable and not view.blinds[3].skippable)

    run.skip_blind(state, "coupon")
    view = blind_flow.view(state, "mega")
    assert(view.blinds[2].skippable == true and view.blinds[2].skip_tag.id == "mega")

    run.skip_blind(state, "mega")
    view = blind_flow.view(state, "coupon")
    assert(state.blind == "boss" and state.boss_id ~= nil)
    assert(not view.blinds[3].skippable, "boss cannot be skipped")

    state.phase = "shop"
    view = blind_flow.view(state, "coupon")
    assert(not view.blinds[3].playable and not view.blinds[3].skippable)
    fails(function() blind_flow.view(state, "not-a-tag") end, "invalid tag is rejected")
end

function M.test_selection_only_accepts_current_blind()
    local state = run.new("blind-flow-select")
    fails(function() blind_flow.select(state, "big") end, "cannot jump to big")
    fails(function() blind_flow.select(state, "boss") end, "cannot jump to boss")
    assert(state.blind == "small")

    local selected = blind_flow.select(state, "small")
    assert(selected.kind == "small")
    assert(selected.target == run.blind_target(state))
    assert(selected.playable == true)

    state.phase = "shop"
    fails(function() blind_flow.select(state, "small") end, "cannot select outside play")
end

function M.test_skip_delegates_progression_and_tag_application_to_run()
    local state = run.new("blind-flow-skip")
    blind_flow.skip(state, "small", "investment")
    assert(state.blind == "big" and state.phase == "play")
    assert(state.tags.pending_money == 15)

    blind_flow.skip(state, "big", "mega")
    assert(state.blind == "boss" and state.phase == "play")
    assert(state.tags.duplicate_next_gwang == true)
    assert(state.boss_id ~= nil, "run transition selected the boss")

    fails(function() blind_flow.skip(state, "boss", "coupon") end, "boss cannot skip")
    fails(function() blind_flow.skip(run.new(), "small", nil) end, "skip requires a tag")

    local future = run.new()
    fails(function() blind_flow.skip(future, "big", "coupon") end, "cannot skip a future blind")
    assert(future.blind == "small" and #future.tags.owned == 0)
end

function M.test_boss_selection_and_target_use_run_api()
    local state = run.new("blind-flow-boss")
    state.blind = "boss"
    state.boss = nil
    state.boss_id = nil

    local selected = blind_flow.select(state, "boss", "wall")
    assert(state.boss_id == "wall")
    assert(selected.boss.id == "wall")
    assert(selected.target == run.blind_target(state))
    assert(selected.target == 1200, "wall target is resolved by run.blind_target")

    local view = blind_flow.view(state, "coupon")
    assert(view.blinds[3].boss.id == "wall")
    assert(view.blinds[3].target == 1200)
    assert(not view.blinds[3].skippable)
end

function M.test_completed_progression_is_derived_from_run_state()
    local state = run.new("blind-flow-clears")
    beat_and_leave_shop(state)
    assert(blind_flow.view(state, "coupon").current == "big")
    beat_and_leave_shop(state)
    assert(state.blind == "boss" and state.boss_id ~= nil)
    assert(blind_flow.view(state, "coupon").current == "boss")
    beat_and_leave_shop(state)
    local view = blind_flow.view(state, "coupon")
    assert(view.ante == 2 and view.current == "small")
end

function M.run()
    M.test_view_exposes_sequential_blinds_and_run_targets()
    M.test_skip_eligibility_requires_current_small_or_big_and_tag()
    M.test_selection_only_accepts_current_blind()
    M.test_skip_delegates_progression_and_tag_application_to_run()
    M.test_boss_selection_and_target_use_run_api()
    M.test_completed_progression_is_derived_from_run_state()
    print("  blind_flow: OK")
end

return M
