-- game/tarots.lua
-- Balatro-style tarot consumables: convert / destroy play cards.
-- Slots max 2, expanded by crystal_ball voucher. Headless-safe.

local hwatu = require("game.hwatu")

local M = {}

M.BASE_SLOTS = 2

-- Consumable pool. Convert / destroy this slice; enhance / copy later.
M.POOL = {
    { id = "the_magician",    name = "마법사",   effect = "convert" },
    { id = "the_hanged_man",  name = "매달린자", effect = "destroy" },
}

local BY_ID = {}
for _, t in ipairs(M.POOL) do
    BY_ID[t.id] = t
end

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
        error("unknown tarot: " .. tostring(id))
    end
    return t
end

function M.ensure(state)
    if type(state.tarots) ~= "table" then
        state.tarots = {}
    end
    return state.tarots
end

function M.max_slots(state)
    local extra = 0
    if state.vouchers then
        extra = state.vouchers.consumable_slots or 0
    end
    return M.BASE_SLOTS + extra
end

--- Gain a tarot into a consumable slot. source is "shop" or "boss".
function M.gain(state, id, source)
    local def = M.by_id(id)
    local slots = M.ensure(state)
    if #slots >= M.max_slots(state) then
        error("max 2 consumable slots")
    end
    if source ~= "shop" and source ~= "boss" then
        error("tarots come from shop or boss reward")
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

--- Use the tarot in slot `slot` on cards[index]. Convert needs opts.kind.
function M.use(state, slot, cards, index, opts)
    local slots = M.ensure(state)
    local held = slots[slot]
    if not held then
        error("empty tarot slot")
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
    else
        error("unknown tarot effect: " .. tostring(def.effect))
    end
    table.remove(slots, slot)
    return def
end

-- Touch hwatu.card so convert results stay valid play cards.
function M.make_card(kind)
    return hwatu.card(kind)
end

return M
