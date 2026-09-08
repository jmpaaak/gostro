-- game/deck.lua
-- Play-card deck: starter composition + viewer + talisman enhance/destroy + sort.
-- Gwang is a joker slot, not a deck card. No month numbers.

local hwatu = require("game.hwatu")
local effects = require("game.ui.card_effects")

local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

-- 5 of each named kind + 20 pi. Thin-deck later via talisman destroy.
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

local function card_at(d, index)
    if type(d) ~= "table" or type(d.cards) ~= "table" then
        error("deck must have cards")
    end
    local card = d.cards[index]
    if type(card) ~= "table" then
        error("deck card index out of range")
    end
    assert_play_card(card)
    return card
end

function M.enhance(d, index, effect)
    local card = card_at(d, index)
    if not effects.is_known(effect) then
        error("unknown card effect: " .. tostring(effect))
    end
    effects.apply(card, effect)
    card.month = nil
    card.month_name = nil
    return card
end

function M.destroy(d, index)
    card_at(d, index)
    table.remove(d.cards, index)
end

local KIND_RANK = {
    hongdan = 1,
    cheongdan = 2,
    chodan = 3,
    godori = 4,
    pi = 5,
}

local EFFECT_RANK = {
    none = 1,
    foil = 2,
    hologram = 3,
    polychrome = 4,
}

function M.sort(d, key)
    if key ~= "kind" and key ~= "effect" then
        error("deck sort key must be kind or effect")
    end
    if type(d) ~= "table" or type(d.cards) ~= "table" then
        error("deck must have cards")
    end
    for i = 1, #d.cards do
        assert_play_card(d.cards[i])
        local effect = d.cards[i].effect
        if effect ~= nil and EFFECT_RANK[effect] == nil then
            error("unknown card effect: " .. tostring(effect))
        end
    end
    table.sort(d.cards, function(a, b)
        if key == "kind" then
            local ra, rb = KIND_RANK[a.kind], KIND_RANK[b.kind]
            if ra ~= rb then
                return ra < rb
            end
            local ea = EFFECT_RANK[a.effect or "none"]
            local eb = EFFECT_RANK[b.effect or "none"]
            return ea < eb
        end
        local ea = EFFECT_RANK[a.effect or "none"]
        local eb = EFFECT_RANK[b.effect or "none"]
        if ea ~= eb then
            return ea < eb
        end
        return KIND_RANK[a.kind] < KIND_RANK[b.kind]
    end)
end

return M
