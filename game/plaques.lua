-- game/plaques.lua
-- Korean-themed rewards granted for skipping the current round.
-- Legacy tag ids and state fields remain aliases for saved runs and old callers.

local M = {}

-- Keep this order stable: seeded selections depend on catalog indices.
M.POOL = {
    { id = "saebaram",   name = "새바람 패찰", effect = "free_reroll",          amount = 1 },
    { id = "mokdon",     name = "목돈 패찰",   effect = "money",                amount = 15 },
    { id = "pumasi",     name = "품앗이 패찰", effect = "money",                amount = 8 },
    { id = "salimkkun",  name = "살림꾼 패찰", effect = "money",                amount = 10 },
    { id = "ssangdungi", name = "쌍둥이 패찰", effect = "duplicate_next_gwang" },
    { id = "eunbit",     name = "은빛 패찰",   effect = "next_gwang_finish",    finish = "silver" },
    { id = "noeulbit",   name = "노을빛 패찰", effect = "next_gwang_finish",    finish = "sunset" },
    { id = "obangsaek",  name = "오방색 패찰", effect = "next_gwang_finish",    finish = "obang" },
    { id = "jangteo",    name = "장터 패찰",   effect = "extra_shop_slots",     amount = 1 },
    { id = "jingwipum",  name = "진귀품 패찰", effect = "rare_shop" },
    { id = "neoreunson", name = "너른손 패찰", effect = "hand_size",            amount = 1 },
    { id = "yutnori",    name = "윷놀이 패찰", effect = "free_reroll",          amount = 2 },
}

local LEGACY_IDS = {
    coupon = "saebaram",
    investment = "mokdon",
    handy = "pumasi",
    economy = "salimkkun",
    mega = "ssangdungi",
    foil = "eunbit",
    hologram = "noeulbit",
    polychrome = "obangsaek",
    charm = "jangteo",
    uncommon = "jingwipum",
    juggle = "neoreunson",
    d6 = "yutnori",
}

local LEGACY_FINISHES = {
    silver = "foil",
    sunset = "hologram",
    obang = "polychrome",
}

local BY_ID = {}
for _, definition in ipairs(M.POOL) do
    BY_ID[definition.id] = definition
end

--- Return the canonical id for a current or legacy plaque id.
function M.canonical_id(id)
    return LEGACY_IDS[id] or id
end

function M.by_id(id)
    local definition = BY_ID[M.canonical_id(id)]
    if not definition then
        error("unknown plaque: " .. tostring(id))
    end
    return definition
end

--- Pick a plaque by stable pool index. Optional rng(min, max) matches math.random.
function M.random(rng)
    rng = rng or math.random
    return M.POOL[rng(1, #M.POOL)]
end

local function normalize_owned(owned)
    for i, id in ipairs(owned) do
        owned[i] = M.canonical_id(id)
    end
end

--- Ensure canonical and legacy run-state fields share one reward table.
function M.ensure(state)
    local rewards = type(state.plaques) == "table" and state.plaques
        or (type(state.tags) == "table" and state.tags or {})
    state.plaques = rewards
    state.tags = rewards
    if type(rewards.owned) ~= "table" then rewards.owned = {} end
    normalize_owned(rewards.owned)
    rewards.free_rerolls = rewards.free_rerolls or 0
    rewards.pending_money = rewards.pending_money or 0
    rewards.extra_shop_slots = rewards.extra_shop_slots or 0
    rewards.hand_size_bonus = rewards.hand_size_bonus or 0
    if rewards.uncommon_shop and rewards.rare_shop == nil then rewards.rare_shop = true end
    if rewards.rare_shop and rewards.uncommon_shop == nil then rewards.uncommon_shop = true end
    return rewards
end

--- Apply a current or legacy plaque id to run state.
function M.apply(state, id)
    local definition = M.by_id(id)
    local rewards = M.ensure(state)
    rewards.owned[#rewards.owned + 1] = definition.id
    if definition.effect == "free_reroll" then
        rewards.free_rerolls = rewards.free_rerolls + (definition.amount or 1)
    elseif definition.effect == "money" then
        rewards.pending_money = rewards.pending_money + (definition.amount or 0)
    elseif definition.effect == "duplicate_next_gwang" then
        rewards.duplicate_next_gwang = true
    elseif definition.effect == "next_gwang_finish" then
        rewards.next_gwang_finish = definition.finish
        rewards.next_gwang_edition = LEGACY_FINISHES[definition.finish]
    elseif definition.effect == "extra_shop_slots" then
        rewards.extra_shop_slots = rewards.extra_shop_slots + (definition.amount or 1)
    elseif definition.effect == "rare_shop" then
        rewards.rare_shop = true
        rewards.uncommon_shop = true
    elseif definition.effect == "hand_size" then
        rewards.hand_size_bonus = rewards.hand_size_bonus + (definition.amount or 1)
    else
        error("unknown plaque effect: " .. tostring(definition.effect))
    end
    return rewards
end

return M
