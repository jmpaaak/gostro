-- Tests for the hwatu deck viewer: kinds / counts / effects.
-- Engine-hosted. No month numbers. Gwang is a joker, not a deck card.

local deck = require("game.deck")

local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

function M.run()
    M.test_starter_play_cards_only()
    M.test_starter_counts()
    M.test_view_kinds_and_effects()
    M.test_view_reports_editions()
    M.test_rejects_gwang_and_months()
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

return M
