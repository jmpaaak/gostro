-- Tests for Balatro-style tarot consumables (convert / destroy).
-- Engine-hosted: slots + use on play cards. No month numbers.

local tarots = require("game.tarots")
local hwatu = require("game.hwatu")
local run = require("game.run")
local vouchers = require("game.vouchers")

local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

local function kinds_of(cards)
    local out = {}
    for i = 1, #cards do
        out[i] = cards[i].kind
    end
    return out
end

function M.run()
    M.test_pool()
    M.test_by_id()
    M.test_max_slots_default()
    M.test_crystal_ball_expands_slots()
    M.test_gain_from_shop()
    M.test_gain_from_boss_reward()
    M.test_slots_full()
    M.test_convert_kind()
    M.test_destroy_card()
    M.test_use_consumes_slot()
    M.test_unknown_rejects()
    M.test_no_month_on_cards()
    print("  tarots: OK")
end

function M.test_pool()
    assert(type(tarots.POOL) == "table")
    assert(#tarots.POOL >= 2, "need convert + destroy tarots")
    local seen = {}
    local effects = {}
    for _, t in ipairs(tarots.POOL) do
        assert(type(t.id) == "string" and t.id ~= "")
        assert(type(t.name) == "string" and t.name ~= "")
        assert(type(t.effect) == "string" and t.effect ~= "")
        assert(not seen[t.id], "duplicate tarot id: " .. t.id)
        seen[t.id] = true
        effects[t.effect] = true
    end
    assert(effects.convert, "pool must include convert")
    assert(effects.destroy, "pool must include destroy")
end

function M.test_by_id()
    local t = tarots.by_id("the_magician")
    assert(t.id == "the_magician")
    assert(t.effect == "convert")
    local d = tarots.by_id("the_hanged_man")
    assert(d.effect == "destroy")
    local ok = pcall(tarots.by_id, "not_a_tarot")
    assert(not ok, "unknown tarot must error")
end

function M.test_max_slots_default()
    local state = run.new()
    assert(tarots.max_slots(state) == 2)
    tarots.ensure(state)
    assert(type(state.tarots) == "table")
    assert(#state.tarots == 0)
end

function M.test_crystal_ball_expands_slots()
    local state = run.new()
    vouchers.apply(state, "crystal_ball")
    assert(tarots.max_slots(state) == 3)
end

function M.test_gain_from_shop()
    local state = run.new()
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "shop")
    local gained = tarots.gain(state, "the_magician", "shop")
    assert(gained.id == "the_magician")
    assert(#state.tarots == 1)
    assert(state.tarots[1].id == "the_magician")
    assert(state.tarots[1].source == "shop")
end

function M.test_gain_from_boss_reward()
    local state = run.new()
    local gained = tarots.gain(state, "the_hanged_man", "boss")
    assert(gained.id == "the_hanged_man")
    assert(#state.tarots == 1)
    assert(state.tarots[1].source == "boss")
end

function M.test_slots_full()
    local state = run.new()
    tarots.gain(state, "the_magician", "shop")
    tarots.gain(state, "the_hanged_man", "shop")
    local ok = pcall(tarots.gain, state, "the_magician", "shop")
    assert(not ok, "max 2 consumable slots")
end

function M.test_convert_kind()
    local state = run.new()
    tarots.gain(state, "the_magician", "shop")
    local cards = {
        hwatu.card("pi"),
        hwatu.card("godori"),
        hwatu.card("pi"),
    }
    local used = tarots.use(state, 1, cards, 1, { kind = "hongdan" })
    assert(used.effect == "convert")
    assert(cards[1].kind == "hongdan")
    assert(cards[2].kind == "godori")
    assert(cards[3].kind == "pi")
    assert(cards[1].month == nil)
    assert(cards[1].month_name == nil)
end

function M.test_destroy_card()
    local state = run.new()
    tarots.gain(state, "the_hanged_man", "boss")
    local cards = {
        hwatu.card("hongdan"),
        hwatu.card("cheongdan"),
        hwatu.card("pi"),
    }
    tarots.use(state, 1, cards, 2)
    local kinds = kinds_of(cards)
    assert(#cards == 2)
    assert(kinds[1] == "hongdan")
    assert(kinds[2] == "pi")
end

function M.test_use_consumes_slot()
    local state = run.new()
    tarots.gain(state, "the_magician", "shop")
    tarots.gain(state, "the_hanged_man", "shop")
    local cards = { hwatu.card("pi") }
    tarots.use(state, 1, cards, 1, { kind = "godori" })
    assert(#state.tarots == 1)
    assert(state.tarots[1].id == "the_hanged_man")
    tarots.use(state, 1, cards, 1)
    assert(#state.tarots == 0)
end

function M.test_unknown_rejects()
    local state = run.new()
    local ok = pcall(tarots.gain, state, "death", "shop")
    assert(not ok)
    tarots.gain(state, "the_magician", "shop")
    local cards = { hwatu.card("pi") }
    ok = pcall(tarots.use, state, 1, cards, 1, { kind = "gwang" })
    assert(not ok, "cannot convert to gwang")
    ok = pcall(tarots.use, state, 1, cards, 1, { kind = "mae" })
    assert(not ok, "no fake poker hands")
end

function M.test_no_month_on_cards()
    local state = run.new()
    tarots.gain(state, "the_magician", "shop")
    local cards = { hwatu.card("pi") }
    tarots.use(state, 1, cards, 1, { kind = "chodan" })
    assert(cards[1].month == nil)
    assert(cards[1].month_name == nil)
    for _, kind in ipairs(PLAY_KINDS) do
        assert(kind ~= "gwang")
    end
end

return M
