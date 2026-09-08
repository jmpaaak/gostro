local run_state = require("game.run_state")
local run = require("game.run")
local run_rules = require("game.run_rules")

local M = {}

function M.run()
    local first = run_state.new("state-seed")
    local second = run_state.new("state-seed")

    assert(first.seed == "STATESEED" and second.seed == first.seed,
        "run state normalizes the seed")
    assert(first.ante == 1 and first.blind == "small" and first.phase == "play")
    assert(first.money == 4 and first.hands_left == 4 and first.round_score == 0)
    assert(#first.gwang == 0 and #first.plaques.owned == 0 and #first.vouchers.owned == 0)
    assert(first.plaques == first.tags, "legacy tag state aliases canonical plaques")
    assert(first.rng.cards(1, 100000) == second.rng.cards(1, 100000),
        "run state installs deterministic independent gameplay streams")

    first.plaques.owned[1] = "saebaram"
    first.vouchers.owned[1] = "overstock"
    assert(#second.plaques.owned == 0 and #second.vouchers.owned == 0,
        "each run owns independent nested state")

    local original_new = run_state.new
    run_state.new = function(seed)
        return { delegated_seed = seed }
    end
    local delegated = run.new("delegate-seed")
    run_state.new = original_new
    assert(delegated.delegated_seed == "delegate-seed",
        "game.run.new remains a compatibility delegate")

    local original_run_new = run.new
    run.new = function()
        error("run_rules.create must not construct state through game.run")
    end
    local created = assert(run_rules.create({
        starting_deck_id = "hwatu", stake_id = "white", seeded = true, seed = "direct-state",
    }))
    run.new = original_run_new
    assert(created.seed == "DIRECTSTATE" and created.starting_deck_id == "hwatu",
        "run rules creates and configures an independent base state")

    print("  run_state: OK")
end

return M
