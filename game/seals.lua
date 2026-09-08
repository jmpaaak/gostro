-- game/seals.lua
-- Korean-themed 인장: permanent run upgrades, one purchase per shop.
-- Headless-safe. Legacy voucher fields and ids are migrated in ensure().

local M = {}

-- Keep this order stable: seeded shop selection depends on pool indices.
M.POOL = {
    { id = "wide_mat",              name = "너른 멍석",   effect = "hand_size",         amount = 1 },
    { id = "emptying_jar",          name = "비움 항아리", effect = "discard",           amount = 1 },
    { id = "artisan_hand",          name = "장인의 손",   effect = "hands",             amount = 1 },
    { id = "market_bundle",         name = "장터 보따리", effect = "shop_slots",        amount = 1 },
    { id = "bargaining_knot",       name = "흥정 매듭",   effect = "reroll_discount",   amount = 1 },
    { id = "market_favor",          name = "장터 인심",   effect = "shop_discount",     amount = 1 },
    { id = "granary_key",           name = "곳간 열쇠",   effect = "interest_cap",      amount = 5 },
    { id = "golden_wrapping_cloth", name = "금빛 보자기", effect = "gwang_slots",       amount = 1 },
    { id = "charm_pouch",           name = "부적 주머니", effect = "consumable_slots",  amount = 1 },
    { id = "jade_polish",           name = "옥돌 갈이",   effect = "edition_rate",      amount = 2 },
    { id = "general_command",       name = "장군의 호령", effect = "boss_rerolls",      amount = 1 },
    { id = "coin_tree",             name = "엽전나무",    effect = "interest_rate",     amount = 1 },
}

-- Existing saves and callers may keep these ids. New state stores canonical ids.
local LEGACY_ALIASES = {
    paint_brush = "wide_mat",
    wasteful = "emptying_jar",
    grabber = "artisan_hand",
    overstock = "market_bundle",
    reroll_surplus = "bargaining_knot",
    clearance_sale = "market_favor",
    seed_money = "granary_key",
    antimatter = "golden_wrapping_cloth",
    crystal_ball = "charm_pouch",
    hone = "jade_polish",
    directors_cut = "general_command",
    money_tree = "coin_tree",
}

local BY_ID = {}
for _, def in ipairs(M.POOL) do
    BY_ID[def.id] = def
end
for legacy_id, canonical_id in pairs(LEGACY_ALIASES) do
    BY_ID[legacy_id] = BY_ID[canonical_id]
end

function M.canonical_id(id)
    return LEGACY_ALIASES[id] or id
end

function M.by_id(id)
    local def = BY_ID[id]
    if not def then
        error("unknown seal: " .. tostring(id))
    end
    return def
end

function M.random(rng)
    rng = rng or math.random
    return M.POOL[rng(1, #M.POOL)]
end

local function migrate_owned(owned)
    local migrated, seen = {}, {}
    for i = 1, #owned do
        local id = M.canonical_id(owned[i])
        if BY_ID[id] and not seen[id] then
            migrated[#migrated + 1] = id
            seen[id] = true
        elseif not BY_ID[id] and not seen[id] then
            -- Preserve unknown future ids rather than destroying save data.
            migrated[#migrated + 1] = id
            seen[id] = true
        end
    end
    return migrated
end

function M.ensure(state)
    assert(type(state) == "table", "seal state requires a run state")
    local legacy = type(state.vouchers) == "table" and state.vouchers or nil
    local seals = type(state.seals) == "table" and state.seals
        or legacy
        or {}
    if legacy and legacy ~= seals then
        for key, value in pairs(legacy) do
            if key ~= "owned" and seals[key] == nil then
                seals[key] = value
            end
        end
        local combined = {}
        for i = 1, #(type(seals.owned) == "table" and seals.owned or {}) do
            combined[#combined + 1] = seals.owned[i]
        end
        for i = 1, #(type(legacy.owned) == "table" and legacy.owned or {}) do
            combined[#combined + 1] = legacy.owned[i]
        end
        seals.owned = combined
    end
    state.seals = seals
    state.vouchers = seals -- legacy save/runtime alias

    seals.owned = migrate_owned(type(seals.owned) == "table" and seals.owned or {})
    if seals.shop_id ~= nil then
        seals.shop_id = M.canonical_id(seals.shop_id)
    end
    seals.hand_size = seals.hand_size or 0
    seals.discards = seals.discards or 0
    seals.hands = seals.hands or 0
    seals.shop_slots = seals.shop_slots or 0
    seals.reroll_discount = seals.reroll_discount or 0
    seals.shop_discount = seals.shop_discount or 0
    seals.interest_cap = seals.interest_cap or 5
    seals.gwang_slots = seals.gwang_slots or 0
    seals.consumable_slots = seals.consumable_slots or 0
    seals.edition_rate = seals.edition_rate or 1
    seals.boss_rerolls = seals.boss_rerolls or 0
    seals.interest_rate = seals.interest_rate or 0
    return seals
end

local function owned_set(seals)
    local set = {}
    for i = 1, #seals.owned do
        set[M.canonical_id(seals.owned[i])] = true
    end
    return set
end

function M.stock_shop(state, rng)
    local seals = M.ensure(state)
    local owned = owned_set(seals)
    local pool = {}
    for i = 1, #M.POOL do
        local def = M.POOL[i]
        if not owned[def.id] then
            pool[#pool + 1] = def
        end
    end
    seals.bought_this_shop = false
    if #pool == 0 then
        seals.shop_id = nil
        return nil
    end
    rng = rng or math.random
    local pick = pool[rng(1, #pool)]
    seals.shop_id = pick.id
    return pick
end

function M.clear_shop(state)
    local seals = M.ensure(state)
    seals.shop_id = nil
    seals.bought_this_shop = false
    return seals
end

function M.apply(state, id)
    local def = M.by_id(id)
    local canonical_id = def.id
    local seals = M.ensure(state)
    if owned_set(seals)[canonical_id] then
        error("each seal identity once")
    end
    seals.owned[#seals.owned + 1] = canonical_id
    if def.effect == "hand_size" then
        seals.hand_size = seals.hand_size + (def.amount or 1)
    elseif def.effect == "discard" then
        seals.discards = seals.discards + (def.amount or 1)
    elseif def.effect == "hands" then
        seals.hands = seals.hands + (def.amount or 1)
    elseif def.effect == "shop_slots" then
        seals.shop_slots = seals.shop_slots + (def.amount or 1)
    elseif def.effect == "reroll_discount" then
        seals.reroll_discount = seals.reroll_discount + (def.amount or 1)
    elseif def.effect == "shop_discount" then
        seals.shop_discount = seals.shop_discount + (def.amount or 1)
    elseif def.effect == "interest_cap" then
        seals.interest_cap = seals.interest_cap + (def.amount or 5)
    elseif def.effect == "gwang_slots" then
        seals.gwang_slots = seals.gwang_slots + (def.amount or 1)
    elseif def.effect == "consumable_slots" then
        seals.consumable_slots = seals.consumable_slots + (def.amount or 1)
    elseif def.effect == "edition_rate" then
        seals.edition_rate = seals.edition_rate * (def.amount or 2)
    elseif def.effect == "boss_rerolls" then
        seals.boss_rerolls = seals.boss_rerolls + (def.amount or 1)
    elseif def.effect == "interest_rate" then
        seals.interest_rate = seals.interest_rate + (def.amount or 1)
    else
        error("unknown seal effect: " .. tostring(def.effect))
    end
    return seals
end

function M.buy(state, id)
    if state.phase ~= "shop" then
        error("buy seal only in the shop")
    end
    local seals = M.ensure(state)
    if seals.bought_this_shop then
        error("one seal per shop")
    end
    if not seals.shop_id then
        error("no seal in shop")
    end
    if M.canonical_id(id) ~= seals.shop_id then
        error("buy the offered seal")
    end
    M.apply(state, id)
    seals.bought_this_shop = true
    return seals
end

return M
