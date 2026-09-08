-- game/tests/score_anim_ui.lua
-- Tests for score animation module (engine-only, no love.graphics).

local score_anim = require("game.ui.score_anim")

local M = {}

function M.run()
    M.test_new()
    M.test_start_basic()
    M.test_phase_card_popups()
    M.test_phase_mult()
    M.test_phase_total()
    M.test_gwang_glow()
    M.test_idle_after_finish()
    print("  score_anim_ui: OK")
end

function M.test_new()
    local sa = score_anim.new()
    assert(sa.phase == "idle", "initial phase must be idle")
    assert(#sa.card_popups == 0)
    assert(#sa.gwang_glows == 0)
end

function M.test_start_basic()
    local sa = score_anim.new()
    -- cards: each {kind, chips}
    local cards = {
        { kind = "hongdan", chips = 10 },
        { kind = "pi",      chips = 1 },
        { kind = "godori",  chips = 20 },
    }
    score_anim.start(sa, {
        cards = cards,
        base_chips = 31,
        base_mult = 1,
        bonus_chips = 30,
        bonus_mult = 4,
        final_chips = 61,
        final_mult = 5,
        total = 305,
        gwang_triggers = { { slot = 1, identity = "chips" } },
    })
    assert(sa.phase == "cards", "phase must be cards after start")
    assert(#sa.card_popups == 3, "must have 3 card popups")
    assert(sa.card_popups[1].chips == 10)
    assert(sa.card_popups[2].chips == 1)
    assert(sa.card_popups[3].chips == 20)
    assert(#sa.gwang_glows == 1)
    assert(sa.gwang_glows[1].slot == 1)
end

function M.test_phase_card_popups()
    local sa = score_anim.new()
    score_anim.start(sa, {
        cards = {
            { kind = "hongdan", chips = 10 },
            { kind = "pi",      chips = 1 },
        },
        base_chips = 11, base_mult = 1,
        bonus_chips = 0, bonus_mult = 0,
        final_chips = 11, final_mult = 1,
        total = 11,
        gwang_triggers = {},
    })
    assert(sa.phase == "cards")
    -- Tick through all card popup delays
    local per_card = score_anim.CARD_DELAY
    score_anim.update(sa, per_card + 0.01) -- first card done
    assert(sa.card_index == 2, "should advance to card 2")
    score_anim.update(sa, per_card + 0.01) -- second card done
    -- After all cards, should move to mult phase
    assert(sa.phase == "mult", "should transition to mult phase after all cards, got: " .. sa.phase)
end

function M.test_phase_mult()
    local sa = score_anim.new()
    score_anim.start(sa, {
        cards = {{ kind = "pi", chips = 1 }},
        base_chips = 1, base_mult = 1,
        bonus_chips = 30, bonus_mult = 4,
        final_chips = 31, final_mult = 5,
        total = 155,
        gwang_triggers = {},
    })
    -- Skip through cards phase
    score_anim.update(sa, score_anim.CARD_DELAY + 0.01)
    assert(sa.phase == "mult")
    -- Tick through mult phase
    score_anim.update(sa, score_anim.MULT_DURATION + 0.01)
    assert(sa.phase == "total", "should transition to total after mult, got: " .. sa.phase)
end

function M.test_phase_total()
    local sa = score_anim.new()
    score_anim.start(sa, {
        cards = {{ kind = "pi", chips = 1 }},
        base_chips = 1, base_mult = 1,
        bonus_chips = 0, bonus_mult = 0,
        final_chips = 1, final_mult = 1,
        total = 1,
        gwang_triggers = {},
    })
    -- Skip cards and mult
    score_anim.update(sa, score_anim.CARD_DELAY + 0.01)
    score_anim.update(sa, score_anim.MULT_DURATION + 0.01)
    assert(sa.phase == "total")
    -- Tick through total countup
    score_anim.update(sa, score_anim.TOTAL_DURATION + 0.01)
    assert(sa.phase == "done", "should be done after total, got: " .. sa.phase)
end

function M.test_gwang_glow()
    local sa = score_anim.new()
    score_anim.start(sa, {
        cards = {{ kind = "hongdan", chips = 10 }},
        base_chips = 10, base_mult = 1,
        bonus_chips = 30, bonus_mult = 4,
        final_chips = 40, final_mult = 5,
        total = 200,
        gwang_triggers = {
            { slot = 1, identity = "chips" },
            { slot = 3, identity = "mult" },
        },
    })
    assert(#sa.gwang_glows == 2)
    assert(sa.gwang_glows[1].slot == 1)
    assert(sa.gwang_glows[1].identity == "chips")
    assert(sa.gwang_glows[2].slot == 3)
    assert(sa.gwang_glows[2].identity == "mult")
    -- Glow timer should be positive
    assert(sa.gwang_glows[1].timer > 0)
    -- After enough time, glow should fade
    local total_time = score_anim.CARD_DELAY + score_anim.MULT_DURATION + score_anim.TOTAL_DURATION + 1
    score_anim.update(sa, total_time)
    -- Glows should have timed out
    for _, g in ipairs(sa.gwang_glows) do
        assert(g.timer <= 0, "glow should have expired")
    end
end

function M.test_idle_after_finish()
    local sa = score_anim.new()
    score_anim.start(sa, {
        cards = {{ kind = "pi", chips = 1 }},
        base_chips = 1, base_mult = 1,
        bonus_chips = 0, bonus_mult = 0,
        final_chips = 1, final_mult = 1,
        total = 1,
        gwang_triggers = {},
    })
    -- Run through all phases
    local total_time = score_anim.CARD_DELAY + score_anim.MULT_DURATION + score_anim.TOTAL_DURATION + 1
    score_anim.update(sa, total_time)
    assert(sa.phase == "done")
    -- Dismiss returns to idle
    score_anim.dismiss(sa)
    assert(sa.phase == "idle")
end

return M
