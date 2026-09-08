local pipeline = require("game.scoring_pipeline")
local hwatu = require("game.hwatu")
local run = require("game.run")

local M = {}

local function cards(...)
    local out = {}
    for i = 1, select("#", ...) do
        local spec = select(i, ...)
        if type(spec) == "string" then
            out[i] = hwatu.card(spec)
        else
            out[i] = hwatu.card(spec.kind, { effect = spec.effect })
        end
    end
    return out
end

local function event_types(events)
    local out = {}
    for i = 1, #events do
        out[i] = events[i].type
    end
    return table.concat(out, ",")
end

function M.run()
    M.test_combines_wish_card_edition_gwang_then_boss_once()
    M.test_commits_gwang_money_and_once_via_evaluate()
    M.test_psychic_rejects_before_stateful_gwang_triggers()
    M.test_non_scoring_boss_is_not_reapplied_during_scoring()
    M.test_plain_hand_has_stable_animation_events()
    print("  scoring_pipeline: OK")
end

function M.test_combines_wish_card_edition_gwang_then_boss_once()
    local state = run.new()
    state.blind = "boss"
    run.select_boss(state, "flint")
    state.hands = { hongdan = { level = 2 } }
    state.gwang = { { kind = "gwang", identity = "mult" } }

    local result = assert(pipeline.score(cards(
        { kind = "hongdan", effect = "foil" },
        "hongdan",
        "hongdan"
    ), state))

    -- hwatu order: base 30x2, wish card -> 45x3, foil -> 95x3,
    -- gwang -> 95x7; then the score boss -> floor halves 47x3.
    assert(result.chips == 47)
    assert(result.mult == 3)
    assert(result.score == 141)
    assert(result.effect_chips == 50, "edition metadata survives boss result")
    assert(result.gwang_triggers[1].id == "mult")
    assert(state.round_score == 0, "the pure pipeline does not add score to the run")

    assert(event_types(result.events) == "hand,wish_card,edition,gwang,boss,score")
    assert(result.events[2].yaku == "hongdan" and result.events[2].level == 2)
    assert(result.events[2].legacy_type == "planet", "legacy animation consumers can migrate safely")
    assert(result.events[4].id == "mult" and result.events[4].slot == 1)
    assert(result.events[5].id == "flint")
    assert(result.events[6].score == 141)
end

function M.test_commits_gwang_money_and_once_via_evaluate()
    local state = run.new()
    state.money = 4
    state.gwang = {
        { kind = "gwang", identity = "compound" },
        { kind = "gwang", identity = "once_x20" },
    }

    local result = assert(pipeline.score(cards("pi"), state))
    assert(state.money == 5, "compound gwang money commits once")
    assert(#state.gwang == 1 and state.gwang[1].identity == "compound",
        "once gwang is removed by the catalog")
    assert(#result.gwang_triggers == 2)
    assert(event_types(result.events) == "hand,gwang,gwang,score")
end

function M.test_psychic_rejects_before_stateful_gwang_triggers()
    local state = run.new()
    state.blind = "boss"
    run.select_boss(state, "psychic")
    state.gwang = { { kind = "gwang", identity = "once_x20" } }

    local result, err = pipeline.score(cards("pi", "pi", "pi", "pi"), state)
    assert(result == nil)
    assert(err == "psychic requires a 5-card hand")
    assert(#state.gwang == 1, "invalid plays cannot consume once gwang")
end

function M.test_non_scoring_boss_is_not_reapplied_during_scoring()
    local state = run.new()
    state.blind = "boss"
    run.select_boss(state, "hook")
    local rng_calls = 0

    local result = assert(pipeline.score(cards("pi"), state, {
        rng = function(a)
            rng_calls = rng_calls + 1
            return a
        end,
    }))

    assert(result.score == 1)
    assert(rng_calls == 0, "hand-management bosses are not scoring hooks")
    assert(event_types(result.events) == "hand,score")
end

function M.test_plain_hand_has_stable_animation_events()
    local state = run.new()
    local result = assert(pipeline.evaluate(cards("pi", "pi"), state))
    assert(result.score == 2)
    assert(result.events[1].type == "hand")
    assert(result.events[1].cards[1].kind == "pi")
    assert(result.events[2].type == "score")
    assert(result.events[2].chips == 2 and result.events[2].mult == 1)
end

return M
