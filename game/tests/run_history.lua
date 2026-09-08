-- Tests for Balatro-style run history (INBOX 22, remaining slice).
-- Engine-hosted. Headless-safe. No month numbers/names.

local history = require("game.run_history")
local run = require("game.run")
local rng = require("game.rng")

local M = {}

function M.run()
    M.test_empty_list()
    M.test_record_won_keeps_seed()
    M.test_record_lost()
    M.test_newest_first()
    M.test_cap()
    M.test_normalizes_seed()
    M.test_no_months()
    M.test_clear_blind_win_records()
    M.test_lose_records()
    print("  run_history: OK")
end

function M.test_empty_list()
    history.reset()
    local list = history.list()
    assert(type(list) == "table")
    assert(#list == 0)
end

function M.test_record_won_keeps_seed()
    history.reset()
    local state = run.new("histseed")
    state.ante = 8
    state.blind = "boss"
    state.money = 42
    local entry = history.record(state, "won")
    assert(entry.seed == "HISTSEED")
    assert(entry.outcome == "won")
    assert(entry.ante == 8)
    assert(entry.blind == "boss")
    assert(entry.go == 8 and entry.round == "boss")
    assert(entry.go_label == "8고" and entry.round_label == "대장판")
    assert(entry.money == 42)
    local list = history.list()
    assert(#list == 1)
    assert(list[1].seed == "HISTSEED")
end

function M.test_record_lost()
    history.reset()
    local state = run.new("LOSTSEED")
    state.ante = 3
    state.blind = "big"
    state.money = 7
    local entry = history.record(state, "lost")
    assert(entry.outcome == "lost")
    assert(entry.ante == 3)
    assert(entry.blind == "big")
    assert(entry.go_label == "3고" and entry.round_label == "큰판")
    assert(history.list()[1].outcome == "lost")
end

function M.test_newest_first()
    history.reset()
    history.record(run.new("AAAA0001"), "lost")
    history.record(run.new("BBBB0002"), "won")
    local list = history.list()
    assert(#list == 2)
    assert(list[1].seed == "BBBB0002")
    assert(list[2].seed == "AAAA0001")
end

function M.test_cap()
    history.reset()
    for i = 1, history.MAX + 5 do
        history.record(run.new(string.format("S%07d", i)), "lost")
    end
    local list = history.list()
    assert(#list == history.MAX, "history caps at MAX, got " .. tostring(#list))
    -- newest kept; oldest dropped
    assert(list[1].seed == string.format("S%07d", history.MAX + 5))
end

function M.test_normalizes_seed()
    history.reset()
    local state = run.new("run-hist-1")
    history.record(state, "won")
    assert(history.list()[1].seed == rng.normalize("run-hist-1"))
    assert(history.list()[1].seed == "RUNHIST1")
end

function M.test_no_months()
    history.reset()
    local entry = history.record(run.new("PLAIN001"), "won")
    local blob = table.concat({
        tostring(entry.seed),
        tostring(entry.outcome),
        tostring(entry.ante),
        tostring(entry.blind),
        tostring(entry.money),
    }, ",")
    assert(not blob:lower():find("month", 1, true))
    assert(not blob:find("mae", 1, true))
    assert(not blob:find("ppeok", 1, true))
    assert(not blob:find("otti", 1, true))
    assert(entry.month == nil)
end

function M.test_clear_blind_win_records()
    history.reset()
    local state = run.new("WINSEED1")
    state.ante = 8
    state.blind = "boss"
    state.phase = "play"
    state.round_score = 0
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "won")
    local list = history.list()
    assert(#list == 1, "winning ante 8 boss records history")
    assert(list[1].seed == "WINSEED1")
    assert(list[1].outcome == "won")
    assert(list[1].ante == 8)
    assert(list[1].blind == "boss")
end

function M.test_lose_records()
    history.reset()
    local state = run.new("FAILSEED")
    state.ante = 2
    state.blind = "small"
    run.lose(state)
    assert(state.phase == "lost")
    local list = history.list()
    assert(#list == 1)
    assert(list[1].seed == "FAILSEED")
    assert(list[1].outcome == "lost")
    assert(list[1].ante == 2)
    assert(list[1].blind == "small")
end

return M
