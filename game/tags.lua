-- game/tags.lua
-- Balatro-style skip tags: reward for skipping small/big blinds.
-- Headless-safe. Gwang = jokers; never 고수패.

local M = {}

-- 12 skip tags. Coupon = free shop reroll, investment = extra money,
-- mega = duplicate the next gwang joker bought.
M.POOL = {
    { id = "coupon",      name = "쿠폰",     effect = "free_reroll",          amount = 1 },
    { id = "investment",  name = "투자",     effect = "money",                amount = 15 },
    { id = "handy",       name = "Handy",    effect = "money",                amount = 8 },
    { id = "economy",     name = "이코노미", effect = "money",                amount = 10 },
    { id = "mega",        name = "메가",     effect = "duplicate_next_gwang" },
    { id = "foil",        name = "포일",     effect = "next_gwang_edition",   edition = "foil" },
    { id = "hologram",    name = "홀로그램", effect = "next_gwang_edition",   edition = "hologram" },
    { id = "polychrome",  name = "폴리크롬", effect = "next_gwang_edition",   edition = "polychrome" },
    { id = "charm",       name = "참",       effect = "extra_shop_slots",     amount = 1 },
    { id = "uncommon",    name = "언커먼",   effect = "uncommon_shop" },
    { id = "juggle",      name = "저글",     effect = "hand_size",            amount = 1 },
    { id = "d6",          name = "D6",       effect = "free_reroll",          amount = 2 },
}

local BY_ID = {}
for _, t in ipairs(M.POOL) do
    BY_ID[t.id] = t
end

function M.by_id(id)
    local t = BY_ID[id]
    if not t then
        error("unknown tag: " .. tostring(id))
    end
    return t
end

--- Pick a random tag. Optional rng(min, max) matching math.random.
function M.random(rng)
    rng = rng or math.random
    return M.POOL[rng(1, #M.POOL)]
end

local function ensure(state)
    if type(state.tags) ~= "table" then
        state.tags = {}
    end
    local t = state.tags
    if type(t.owned) ~= "table" then
        t.owned = {}
    end
    t.free_rerolls = t.free_rerolls or 0
    t.pending_money = t.pending_money or 0
    t.extra_shop_slots = t.extra_shop_slots or 0
    t.hand_size_bonus = t.hand_size_bonus or 0
    return t
end

--- Apply a tag id onto run state.tags.
function M.apply(state, id)
    local def = M.by_id(id)
    local t = ensure(state)
    t.owned[#t.owned + 1] = id
    if def.effect == "free_reroll" then
        t.free_rerolls = t.free_rerolls + (def.amount or 1)
    elseif def.effect == "money" then
        t.pending_money = t.pending_money + (def.amount or 0)
    elseif def.effect == "duplicate_next_gwang" then
        t.duplicate_next_gwang = true
    elseif def.effect == "next_gwang_edition" then
        t.next_gwang_edition = def.edition
    elseif def.effect == "extra_shop_slots" then
        t.extra_shop_slots = t.extra_shop_slots + (def.amount or 1)
    elseif def.effect == "uncommon_shop" then
        t.uncommon_shop = true
    elseif def.effect == "hand_size" then
        t.hand_size_bonus = t.hand_size_bonus + (def.amount or 1)
    else
        error("unknown tag effect: " .. tostring(def.effect))
    end
    return t
end

return M
