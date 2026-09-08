-- game/vouchers.lua
-- Balatro-style shop vouchers: permanent run upgrades, 1 per shop.
-- Headless-safe. Gwang = jokers; never 고수패.

local M = {}

-- 12 vouchers. Bought once in the shop after clearing a blind.
M.POOL = {
    { id = "paint_brush",     name = "명필의 인장",         effect = "hand_size",         amount = 1 },
    { id = "wasteful",        name = "호탕한 인장",       effect = "discard",           amount = 1 },
    { id = "grabber",         name = "갈퀴 인장",     effect = "hands",             amount = 1 },
    { id = "overstock",       name = "만물상 인장",   effect = "shop_slots",        amount = 1 },
    { id = "reroll_surplus",  name = "에누리 인장",   effect = "reroll_discount",   amount = 1 },
    { id = "clearance_sale",  name = "떨이 인장",       effect = "shop_discount",     amount = 1 },
    { id = "seed_money",      name = "밑천 인장",   effect = "interest_cap",      amount = 5 },
    { id = "antimatter",      name = "허공 인장",     effect = "gwang_slots",       amount = 1 },
    { id = "crystal_ball",    name = "천리안 인장",     effect = "consumable_slots",  amount = 1 },
    { id = "hone",            name = "벼림 인장",       effect = "edition_rate",      amount = 2 },
    { id = "directors_cut",   name = "판갈이 인장",   effect = "boss_rerolls",      amount = 1 },
    { id = "money_tree",      name = "화수분 인장",   effect = "interest_rate",     amount = 1 },
}

local BY_ID = {}
for _, t in ipairs(M.POOL) do
    BY_ID[t.id] = t
end

function M.by_id(id)
    local t = BY_ID[id]
    if not t then
        error("unknown voucher: " .. tostring(id))
    end
    return t
end

--- Pick a random voucher. Optional rng(min, max) matching math.random.
function M.random(rng)
    rng = rng or math.random
    return M.POOL[rng(1, #M.POOL)]
end

function M.ensure(state)
    if type(state.vouchers) ~= "table" then
        state.vouchers = {}
    end
    local v = state.vouchers
    if type(v.owned) ~= "table" then
        v.owned = {}
    end
    v.hand_size = v.hand_size or 0
    v.discards = v.discards or 0
    v.hands = v.hands or 0
    v.shop_slots = v.shop_slots or 0
    v.reroll_discount = v.reroll_discount or 0
    v.shop_discount = v.shop_discount or 0
    v.interest_cap = v.interest_cap or 5
    v.gwang_slots = v.gwang_slots or 0
    v.consumable_slots = v.consumable_slots or 0
    v.edition_rate = v.edition_rate or 1
    v.boss_rerolls = v.boss_rerolls or 0
    v.interest_rate = v.interest_rate or 0
    return v
end

local function owned_set(v)
    local set = {}
    for i = 1, #v.owned do
        set[v.owned[i]] = true
    end
    return set
end

--- Stock one unowned voucher into the shop slot.
function M.stock_shop(state, rng)
    local v = M.ensure(state)
    local owned = owned_set(v)
    local pool = {}
    for i = 1, #M.POOL do
        local def = M.POOL[i]
        if not owned[def.id] then
            pool[#pool + 1] = def
        end
    end
    v.bought_this_shop = false
    if #pool == 0 then
        v.shop_id = nil
        return nil
    end
    rng = rng or math.random
    local pick = pool[rng(1, #pool)]
    v.shop_id = pick.id
    return pick
end

function M.clear_shop(state)
    local v = M.ensure(state)
    v.shop_id = nil
    v.bought_this_shop = false
    return v
end

--- Apply a voucher id onto run state.vouchers. Each identity once.
function M.apply(state, id)
    local def = M.by_id(id)
    local v = M.ensure(state)
    if owned_set(v)[id] then
        error("each voucher identity once")
    end
    v.owned[#v.owned + 1] = id
    if def.effect == "hand_size" then
        v.hand_size = v.hand_size + (def.amount or 1)
    elseif def.effect == "discard" then
        v.discards = v.discards + (def.amount or 1)
    elseif def.effect == "hands" then
        v.hands = v.hands + (def.amount or 1)
    elseif def.effect == "shop_slots" then
        v.shop_slots = v.shop_slots + (def.amount or 1)
    elseif def.effect == "reroll_discount" then
        v.reroll_discount = v.reroll_discount + (def.amount or 1)
    elseif def.effect == "shop_discount" then
        v.shop_discount = v.shop_discount + (def.amount or 1)
    elseif def.effect == "interest_cap" then
        v.interest_cap = v.interest_cap + (def.amount or 5)
    elseif def.effect == "gwang_slots" then
        v.gwang_slots = v.gwang_slots + (def.amount or 1)
    elseif def.effect == "consumable_slots" then
        v.consumable_slots = v.consumable_slots + (def.amount or 1)
    elseif def.effect == "edition_rate" then
        v.edition_rate = v.edition_rate * (def.amount or 2)
    elseif def.effect == "boss_rerolls" then
        v.boss_rerolls = v.boss_rerolls + (def.amount or 1)
    elseif def.effect == "interest_rate" then
        v.interest_rate = v.interest_rate + (def.amount or 1)
    else
        error("unknown voucher effect: " .. tostring(def.effect))
    end
    return v
end

--- Buy the voucher currently stocked for this shop visit.
function M.buy(state, id)
    if state.phase ~= "shop" then
        error("buy voucher only in the shop")
    end
    local v = M.ensure(state)
    if v.bought_this_shop then
        error("one voucher per shop")
    end
    if not v.shop_id then
        error("no voucher in shop")
    end
    if id ~= v.shop_id then
        error("buy the offered voucher")
    end
    M.apply(state, id)
    v.bought_this_shop = true
    return v
end

return M
