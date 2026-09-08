-- game/deck.lua
-- Play-card deck: starter composition + viewer (kinds / counts / editions).
-- Gwang is a joker slot, not a deck card. No month numbers.

local hwatu = require("game.hwatu")

local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

-- 5 of each named kind + 20 pi. Thin-deck later via tarot destroy.
local STARTER = {
    hongdan = 5,
    cheongdan = 5,
    chodan = 5,
    godori = 5,
    pi = 20,
}

local function assert_play_card(card)
    if type(card) ~= "table" then
        error("deck card must be a table")
    end
    if card.kind == "gwang" then
        error("gwang is a joker slot, not a play card")
    end
    if card.month ~= nil or card.month_name ~= nil then
        error("play cards have no month numbers or names")
    end
    local extra = nil
    if card.effect ~= nil then
        extra = { effect = card.effect }
    end
    hwatu.card(card.kind, extra)
end

function M.new()
    local cards = {}
    for i = 1, #PLAY_KINDS do
        local kind = PLAY_KINDS[i]
        for _ = 1, STARTER[kind] do
            cards[#cards + 1] = hwatu.card(kind)
        end
    end
    return { cards = cards }
end

function M.total(d)
    return #d.cards
end

function M.counts(d)
    local counts = {
        hongdan = 0,
        cheongdan = 0,
        chodan = 0,
        godori = 0,
        pi = 0,
    }
    for i = 1, #d.cards do
        local card = d.cards[i]
        assert_play_card(card)
        counts[card.kind] = counts[card.kind] + 1
    end
    return counts
end

function M.view(d)
    local by_kind = M.counts(d)
    local by_effect = {
        none = 0,
        foil = 0,
        hologram = 0,
        polychrome = 0,
    }
    for i = 1, #d.cards do
        local effect = d.cards[i].effect
        if effect == nil then
            by_effect.none = by_effect.none + 1
        elseif by_effect[effect] == nil then
            error("unknown card effect: " .. tostring(effect))
        else
            by_effect[effect] = by_effect[effect] + 1
        end
    end
    return {
        total = #d.cards,
        by_kind = by_kind,
        by_effect = by_effect,
    }
end

return M
