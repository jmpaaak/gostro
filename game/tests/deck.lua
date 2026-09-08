-- Tests for the hwatu deck viewer: kinds / counts / effects.
-- Engine-hosted. No month numbers. Gwang is a joker, not a deck card.

local deck = require("game.deck")
local tarots = require("game.tarots")
local run = require("game.run")

local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

function M.run()
    M.test_starter_play_cards_only()
    M.test_starter_counts()
    M.test_view_kinds_and_effects()
    M.test_view_reports_editions()
    M.test_rejects_gwang_and_months()
    M.test_enhance_grants_edition()
    M.test_enhance_rejects_unknown_and_gwang()
    M.test_destroy_thins_deck()
    M.test_tarot_enhance_and_destroy()
    print("  deck: OK")
end

function M.test_starter_play_cards_only()
    local d = deck.new()
    assert(type(d.cards) == "table")
    assert(#d.cards > 0, "starter deck is not empty")
    for i = 1, #d.cards do
        local c = d.cards[i]
        assert(c.kind ~= "gwang", "gwang is a joker slot, not a play card")
        assert(c.month == nil, "play cards have no month numbers")
        assert(c.month_name == nil, "play cards have no month names")
        local known = false
        for _, k in ipairs(PLAY_KINDS) do
            if c.kind == k then known = true end
        end
        assert(known, "unknown play card kind: " .. tostring(c.kind))
    end
end

function M.test_starter_counts()
    local d = deck.new()
    local counts = deck.counts(d)
    local total = 0
    for _, k in ipairs(PLAY_KINDS) do
        assert(type(counts[k]) == "number")
        assert(counts[k] > 0, "starter includes " .. k)
        total = total + counts[k]
    end
    assert(counts.gwang == nil or counts.gwang == 0)
    assert(total == #d.cards)
    assert(total == deck.total(d))
end

function M.test_view_kinds_and_effects()
    local d = deck.new()
    local v = deck.view(d)
    assert(v.total == #d.cards)
    for _, k in ipairs(PLAY_KINDS) do
        assert(v.by_kind[k] == deck.counts(d)[k])
    end
    -- Starter has no editions.
    assert(v.by_effect.none == v.total)
    assert((v.by_effect.foil or 0) == 0)
    assert((v.by_effect.hologram or 0) == 0)
    assert((v.by_effect.polychrome or 0) == 0)
end

function M.test_view_reports_editions()
    local d = deck.new()
    d.cards[1].effect = "foil"
    d.cards[2].effect = "hologram"
    d.cards[3].effect = "polychrome"
    local v = deck.view(d)
    assert(v.by_effect.foil == 1)
    assert(v.by_effect.hologram == 1)
    assert(v.by_effect.polychrome == 1)
    assert(v.by_effect.none == v.total - 3)
    -- Kind counts still cover the whole deck.
    local kind_sum = 0
    for _, k in ipairs(PLAY_KINDS) do
        kind_sum = kind_sum + v.by_kind[k]
    end
    assert(kind_sum == v.total)
end

function M.test_rejects_gwang_and_months()
    local d = deck.new()
    local ok = pcall(function()
        d.cards[#d.cards + 1] = { kind = "gwang" }
        deck.view(d)
    end)
    assert(not ok, "deck viewer rejects gwang")

    d = deck.new()
    ok = pcall(function()
        d.cards[1].month = 1
        deck.view(d)
    end)
    assert(not ok, "deck viewer rejects month numbers")
end

function M.test_enhance_grants_edition()
    local d = deck.new()
    local before = deck.total(d)
    local kind = d.cards[1].kind
    local card = deck.enhance(d, 1, "foil")
    assert(card.effect == "foil")
    assert(d.cards[1].effect == "foil")
    assert(d.cards[1].kind == kind)
    assert(d.cards[1].month == nil)
    assert(d.cards[1].month_name == nil)
    assert(deck.total(d) == before)
    local v = deck.view(d)
    assert(v.by_effect.foil == 1)
    assert(v.by_effect.none == before - 1)
end

function M.test_enhance_rejects_unknown_and_gwang()
    local d = deck.new()
    local ok = pcall(deck.enhance, d, 1, "gold")
    assert(not ok, "unknown edition must error")
    ok = pcall(deck.enhance, d, 1, "gwang")
    assert(not ok, "gwang is not an edition")
    assert(d.cards[1].effect == nil)
    ok = pcall(deck.enhance, d, 0, "foil")
    assert(not ok, "enhance index out of range")
end

function M.test_destroy_thins_deck()
    local d = deck.new()
    local before = deck.total(d)
    local counts = deck.counts(d)
    local kind = d.cards[1].kind
    deck.destroy(d, 1)
    assert(deck.total(d) == before - 1)
    local after = deck.counts(d)
    assert(after[kind] == counts[kind] - 1)
    local v = deck.view(d)
    assert(v.total == before - 1)
    local ok = pcall(deck.destroy, d, 0)
    assert(not ok, "destroy index out of range")
    ok = pcall(deck.destroy, d, before + 1)
    assert(not ok, "destroy past end")
end

function M.test_tarot_enhance_and_destroy()
    local d = deck.new()
    local before = deck.total(d)
    local state = run.new()
    tarots.gain(state, "the_chariot", "shop")
    tarots.use(state, 1, d.cards, 1, { effect = "hologram" })
    assert(d.cards[1].effect == "hologram")
    assert(deck.view(d).by_effect.hologram == 1)
    tarots.gain(state, "the_hanged_man", "boss")
    tarots.use(state, 1, d.cards, 1)
    assert(deck.total(d) == before - 1)
    assert(deck.view(d).by_effect.hologram == 0)
    assert(deck.view(d).total == before - 1)
end

return M
