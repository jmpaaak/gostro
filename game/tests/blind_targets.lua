local blind_targets = require("game.blind_targets")
local boss_blinds = require("game.boss_blinds")
local run = require("game.run")

local M = {}

local function fails(fn, message)
    local ok = pcall(fn)
    assert(not ok, message)
end

function M.test_ante_and_blind_target_table()
    assert(blind_targets.base(1, "small") == 300)
    assert(blind_targets.base(1, "big") == 450)
    assert(blind_targets.base(1, "boss") == 600)
    assert(blind_targets.base(2, "small") == 800)
    assert(blind_targets.base(8, "boss") == 100000)

    fails(function() blind_targets.base(9, "small") end,
        "unknown antes are rejected")
    fails(function() blind_targets.base(1, "missing") end,
        "unknown blind kinds are rejected")
end

function M.test_target_applies_only_the_active_boss_rule()
    local state = { ante = 1, blind = "boss" }
    assert(blind_targets.target(state) == 600)

    state.boss = boss_blinds.by_id("wall")
    assert(blind_targets.target(state) == 1200,
        "wall doubles the boss target")

    state.blind = "small"
    assert(blind_targets.target(state) == 300,
        "a retained boss cannot modify a non-boss target")
end

function M.test_run_api_is_a_compatibility_delegate()
    local state = run.new("blind-target-delegate")
    state.ante = 4
    state.blind = "big"
    assert(run.blind_target(state) == blind_targets.target(state))

    state.blind = "boss"
    run.select_boss(state, "wall")
    assert(run.blind_target(state) == blind_targets.target(state))
end

function M.run()
    M.test_ante_and_blind_target_table()
    M.test_target_applies_only_the_active_boss_rule()
    M.test_run_api_is_a_compatibility_delegate()
    print("  blind_targets: OK")
end

return M