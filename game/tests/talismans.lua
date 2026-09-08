-- Tests for Balatro-style tarot consumables (convert / destroy / enhance / copy).
-- Engine-hosted: slots + use on play cards. No month numbers.

local talismans = require("game.talismans")
local hwatu = require("game.hwatu")
local run = require("game.run")
local seals = require("game.seals")

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
    M.test_charm_pouch_expands_slots()
    M.test_gain_from_shop()
    M.test_gain_from_boss_reward()
    M.test_slots_full()
    M.test_convert_kind()
    M.test_destroy_card()
    M.test_use_consumes_slot()
    M.test_unknown_rejects()
    M.test_no_month_on_cards()
    M.test_enhance_grants_effect()
    M.test_enhance_rejects_unknown()
    M.test_copy_card()
    M.test_copy_preserves_effect()
    M.test_copy_rejects_gwang()
    print("  talismans: OK")
end

function M.test_pool()
    assert(type(talismans.POOL) == "table")
    assert(#talismans.POOL >= 2, "need convert + destroy talismans")
    local seen = {}
    local effects = {}
    for _, t in ipairs(talismans.POOL) do
        assert(type(t.id) == "string" and t.id ~= "")
        assert(type(t.name) == "string" and t.name ~= "")
        assert(type(t.effect) == "string" and t.effect ~= "")
        assert(not seen[t.id], "duplicate tarot id: " .. t.id)
        seen[t.id] = true
        effects[t.effect] = true
    end
    assert(effects.convert, "pool must include convert")
    assert(effects.destroy, "pool must include destroy")
    assert(effects.enhance, "pool must include enhance")
    assert(effects.copy, "pool must include copy")
end

function M.test_by_id()
    local t = talismans.by_id("dungap_bu")
    assert(t.id == "dungap_bu")
    assert(t.effect == "convert")
    local d = talismans.by_id("somyeol_bu")
    assert(d.effect == "destroy")
    local c = talismans.by_id("bunsin_bu")
    assert(c.effect == "copy")
    local ok = pcall(talismans.by_id, "not_a_tarot")
    assert(not ok, "unknown tarot must error")
end

function M.test_max_slots_default()
    local state = run.new()
    assert(talismans.max_slots(state) == 2)
    talismans.ensure(state)
    assert(type(state.talismans) == "table")
    assert(#state.talismans == 0)
end

function M.test_charm_pouch_expands_slots()
    local state = run.new()
    seals.apply(state, "charm_pouch")
    assert(talismans.max_slots(state) == 3)
    state.vouchers = nil
    assert(talismans.max_slots(state) == 3,
        "canonical seal state expands slots without the legacy alias")
end

function M.test_gain_from_shop()
    local state = run.new()
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "shop")
    local gained = talismans.gain(state, "dungap_bu", "shop")
    assert(gained.id == "dungap_bu")
    assert(#state.talismans == 1)
    assert(state.talismans[1].id == "dungap_bu")
    assert(state.talismans[1].source == "shop")
end

function M.test_gain_from_boss_reward()
    local state = run.new()
    local gained = talismans.gain(state, "somyeol_bu", "boss")
    assert(gained.id == "somyeol_bu")
    assert(#state.talismans == 1)
    assert(state.talismans[1].source == "boss")
end

function M.test_slots_full()
    local state = run.new()
    talismans.gain(state, "dungap_bu", "shop")
    talismans.gain(state, "somyeol_bu", "shop")
    local ok = pcall(talismans.gain, state, "dungap_bu", "shop")
    assert(not ok, "max 2 consumable slots")
end

function M.test_convert_kind()
    local state = run.new()
    talismans.gain(state, "dungap_bu", "shop")
    local cards = {
        hwatu.card("pi"),
        hwatu.card("godori"),
        hwatu.card("pi"),
    }
    local used = talismans.use(state, 1, cards, 1, { kind = "hongdan" })
    assert(used.effect == "convert")
    assert(cards[1].kind == "hongdan")
    assert(cards[2].kind == "godori")
    assert(cards[3].kind == "pi")
    assert(cards[1].month == nil)
    assert(cards[1].month_name == nil)
end

function M.test_destroy_card()
    local state = run.new()
    talismans.gain(state, "somyeol_bu", "boss")
    local cards = {
        hwatu.card("hongdan"),
        hwatu.card("cheongdan"),
        hwatu.card("pi"),
    }
    talismans.use(state, 1, cards, 2)
    local kinds = kinds_of(cards)
    assert(#cards == 2)
    assert(kinds[1] == "hongdan")
    assert(kinds[2] == "pi")
end

function M.test_use_consumes_slot()
    local state = run.new()
    talismans.gain(state, "dungap_bu", "shop")
    talismans.gain(state, "somyeol_bu", "shop")
    local cards = { hwatu.card("pi") }
    talismans.use(state, 1, cards, 1, { kind = "godori" })
    assert(#state.talismans == 1)
    assert(state.talismans[1].id == "somyeol_bu")
    talismans.use(state, 1, cards, 1)
    assert(#state.talismans == 0)
end

function M.test_unknown_rejects()
    local state = run.new()
    local ok = pcall(talismans.gain, state, "death", "shop")
    assert(not ok)
    talismans.gain(state, "dungap_bu", "shop")
    local cards = { hwatu.card("pi") }
    ok = pcall(talismans.use, state, 1, cards, 1, { kind = "gwang" })
    assert(not ok, "cannot convert to gwang")
    ok = pcall(talismans.use, state, 1, cards, 1, { kind = "mae" })
    assert(not ok, "no fake poker hands")
end

function M.test_no_month_on_cards()
    local state = run.new()
    talismans.gain(state, "dungap_bu", "shop")
    local cards = { hwatu.card("pi") }
    talismans.use(state, 1, cards, 1, { kind = "chodan" })
    assert(cards[1].month == nil)
    assert(cards[1].month_name == nil)
    for _, kind in ipairs(PLAY_KINDS) do
        assert(kind ~= "gwang")
    end
end

function M.test_enhance_grants_effect()
    local state = run.new()
    talismans.gain(state, "gwangchae_bu", "shop")
    local cards = {
        hwatu.card("pi"),
        hwatu.card("godori"),
    }
    local used = talismans.use(state, 1, cards, 1, { effect = "foil" })
    assert(used.effect == "enhance")
    assert(cards[1].kind == "pi")
    assert(cards[1].effect == "foil")
    assert(cards[2].effect == nil)
    assert(cards[1].month == nil)
    assert(#state.talismans == 0)
end

function M.test_enhance_rejects_unknown()
    local state = run.new()
    talismans.gain(state, "gwangchae_bu", "shop")
    local cards = { hwatu.card("hongdan") }
    local ok = pcall(talismans.use, state, 1, cards, 1, { effect = "gold" })
    assert(not ok, "unknown edition must error")
    ok = pcall(talismans.use, state, 1, cards, 1, { effect = "gwang" })
    assert(not ok, "gwang is not an edition")
    assert(cards[1].effect == nil)
    assert(#state.talismans == 1, "failed use must not consume the slot")
end

function M.test_copy_card()
    local state = run.new()
    talismans.gain(state, "bunsin_bu", "shop")
    local cards = {
        hwatu.card("godori"),
        hwatu.card("pi"),
    }
    local used = talismans.use(state, 1, cards, 1)
    assert(used.effect == "copy")
    assert(#cards == 3)
    assert(cards[1].kind == "godori")
    assert(cards[2].kind == "pi")
    assert(cards[3].kind == "godori")
    assert(cards[3] ~= cards[1], "copy must be a new table")
    assert(cards[3].month == nil)
    assert(cards[3].month_name == nil)
    assert(#state.talismans == 0)
end

function M.test_copy_preserves_effect()
    local state = run.new()
    talismans.gain(state, "bunsin_bu", "boss")
    local cards = {
        hwatu.card("hongdan", { effect = "hologram" }),
        hwatu.card("cheongdan"),
    }
    talismans.use(state, 1, cards, 1)
    assert(#cards == 3)
    assert(cards[3].kind == "hongdan")
    assert(cards[3].effect == "hologram")
    cards[3].effect = "foil"
    assert(cards[1].effect == "hologram", "copy must not alias the original")
end

function M.test_copy_rejects_gwang()
    local state = run.new()
    talismans.gain(state, "bunsin_bu", "shop")
    local cards = { { kind = "gwang" } }
    local ok = pcall(talismans.use, state, 1, cards, 1)
    assert(not ok, "cannot copy gwang joker as a play card")
    assert(#cards == 1)
    assert(#state.talismans == 1, "failed copy must not consume the slot")
end

return M
