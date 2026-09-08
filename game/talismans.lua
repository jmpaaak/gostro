-- game/talismans.lua
-- Korean-themed talisman consumables: convert / destroy / enhance / copy play cards.
-- Slots max 2, expanded by crystal_ball voucher. Headless-safe.

local hwatu = require("game.hwatu")
local effects = require("game.ui.card_effects")

local M = {}

M.BASE_SLOTS = 2

M.POOL = {
    { id = "dungap_bu",    name = "둔갑부", effect = "convert" },
    { id = "somyeol_bu",   name = "소멸부", effect = "destroy" },
    { id = "gwangchae_bu", name = "광채부", effect = "enhance" },
    { id = "bunsin_bu",    name = "분신부", effect = "copy" },
}

local BY_ID = {}
for _, t in ipairs(M.POOL) do
    BY_ID[t.id] = t
end
-- Existing saves and integrations may still contain the Western tarot ids.
local LEGACY_IDS = {
    the_magician = "dungap_bu",
    the_hanged_man = "somyeol_bu",
    the_chariot = "gwangchae_bu",
    the_lovers = "bunsin_bu",
}
for old_id, id in pairs(LEGACY_IDS) do
    BY_ID[old_id] = BY_ID[id]
end
M.LEGACY_IDS = LEGACY_IDS

local PLAY_KINDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

function M.by_id(id)
    local t = BY_ID[id]
    if not t then
        error("unknown talisman: " .. tostring(id))
    end
    return t
end

function M.ensure(state)
    if type(state.talismans) ~= "table" then
        if type(state.tarots) == "table" then
            state.talismans = state.tarots
        else
            state.talismans = {}
        end
    end
    -- Canonicalize cards loaded from legacy saves before they reach the UI.
    for _, card in ipairs(state.talismans) do
        local def = type(card) == "table" and BY_ID[card.id] or nil
        if def then
            card.id = def.id
            card.name = def.name
            card.effect = def.effect
        end
    end
    -- Keep the legacy field as the same table so old saves/callers remain valid.
    state.tarots = state.talismans
    return state.talismans
end

function M.max_slots(state)
    local extra = 0
    if state.vouchers then
        extra = state.vouchers.consumable_slots or 0
    end
    return M.BASE_SLOTS + extra
end

--- Gain a talisman into a consumable slot. source is "shop" or "boss".
function M.gain(state, id, source)
    local def = M.by_id(id)
    local slots = M.ensure(state)
    if #slots >= M.max_slots(state) then
        error("max 2 consumable slots")
    end
    if source ~= "shop" and source ~= "boss" then
        error("talismans come from shop or boss reward")
    end
    local card = {
        id = def.id,
        name = def.name,
        effect = def.effect,
        source = source,
    }
    slots[#slots + 1] = card
    return card
end

local function convert_card(card, kind)
    if not PLAY_KINDS[kind] then
        error("unknown play card kind: " .. tostring(kind))
    end
    if kind == "gwang" then
        error("gwang is a joker slot, not a play card")
    end
    card.kind = kind
    card.month = nil
    card.month_name = nil
    return card
end

local function destroy_card(cards, index)
    if index < 1 or index > #cards then
        error("destroy target out of range")
    end
    table.remove(cards, index)
end

local function enhance_card(card, effect)
    if not effects.is_known(effect) then
        error("unknown card effect: " .. tostring(effect))
    end
    effects.apply(card, effect)
    card.month = nil
    card.month_name = nil
    return card
end

local function copy_card(cards, index)
    local src = cards[index]
    if type(src) ~= "table" then
        error("copy target must be a card")
    end
    if src.kind == "gwang" then
        error("gwang is a joker slot, not a play card")
    end
    if not PLAY_KINDS[src.kind] then
        error("unknown play card kind: " .. tostring(src.kind))
    end
    local extra = nil
    if src.effect ~= nil then
        extra = { effect = src.effect }
    end
    local clone = hwatu.card(src.kind, extra)
    cards[#cards + 1] = clone
    return clone
end

--- Use the talisman in slot `slot` on cards[index].
-- Convert needs opts.kind; enhance needs opts.effect (foil/hologram/polychrome).
-- Copy appends an independent play-card clone (kind + edition, no months).
function M.use(state, slot, cards, index, opts)
    local slots = M.ensure(state)
    local held = slots[slot]
    if not held then
        error("empty talisman slot")
    end
    if type(cards) ~= "table" then
        error("cards must be a table")
    end
    if index < 1 or index > #cards then
        error("target out of range")
    end
    local def = M.by_id(held.id)
    if def.effect == "convert" then
        opts = opts or {}
        convert_card(cards[index], opts.kind)
    elseif def.effect == "destroy" then
        destroy_card(cards, index)
    elseif def.effect == "enhance" then
        opts = opts or {}
        enhance_card(cards[index], opts.effect)
    elseif def.effect == "copy" then
        copy_card(cards, index)
    else
        error("unknown talisman effect: " .. tostring(def.effect))
    end
    table.remove(slots, slot)
    return def
end

-- Touch hwatu.card so convert results stay valid play cards.
function M.make_card(kind)
    return hwatu.card(kind)
end

return M
