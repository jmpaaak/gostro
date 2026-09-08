local terms = require("game.terms")
local run = require("game.run")
local economy = require("game.economy")

local M = {}

function M.run()
    assert(terms.round_name("small") == "첫판")
    assert(terms.round_name("big") == "큰판")
    assert(terms.round_name("boss") == "대장판")
    assert(terms.round_name("small", "en") == "Opening Round")
    assert(terms.round_name("big", "en") == "Main Round")
    assert(terms.round_name("boss", "en") == "Final Round")
    assert(terms.go_label(1) == "1고")
    assert(terms.go_label(8) == "8고")
    assert(terms.go_label(3, "en") == "Go 3")

    local round_flow = require("game.round_flow")
    assert(require("game.blind_flow") == round_flow,
        "legacy blind_flow module aliases the round flow")
    assert(require("game.blind_targets") == require("game.round_targets"),
        "legacy blind_targets module aliases round targets")
    assert(require("game.boss_blinds") == require("game.boss_rounds"),
        "legacy boss_blinds module aliases boss rounds")
    assert(require("game.ui.blind_select") == require("game.ui.round_select"),
        "legacy blind_select UI aliases round_select")

    assert(run.FINAL_GO == 8 and run.FINAL_ANTE == run.FINAL_GO)
    local api_state = run.new("ROUNDAPI")
    assert(run.round_target(api_state) == run.blind_target(api_state),
        "round target API preserves the blind-target alias")
    assert(economy.round_reward("small") == economy.blind_reward("small"))
    assert(economy.ROUND_REWARD == economy.BLIND_REWARD,
        "round rewards preserve the legacy constant alias")

    local state = require("game.run_state").new("round-terms")
    assert(state.ante == 1 and state.blind == "small",
        "legacy save fields remain the persisted progression contract")
    local view = round_flow.view(state)
    assert(view.go == 1 and view.current_round == "small")
    assert(view.ante == view.go and view.current == view.current_round)
    assert(view.rounds == view.blinds and #view.rounds == 3,
        "new round projection and legacy blind projection share data")

    assert(run.clear_round ~= nil and run.clear_blind ~= nil)
    assert(run.skip_round ~= nil and run.skip_blind ~= nil)

    print("  round_terms: OK")
end

return M
