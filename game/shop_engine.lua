-- game/shop_engine.lua
-- Pure, headless shop inventory and transaction rules.
-- All random inventory is sourced exclusively from run_state.rng.shop.

local gwang_catalog = require("game.gwang_catalog")
local wish_cards = require("game.wish_cards")
local talismans = require("game.talismans")

local M = {}

M.BASE_RANDOM_SLOTS = 3
M.BASE_REROLL_COST = 5
M.PACK_PRICE = 4
M.VOUCHER_PRICE = 10

local GWANG_PRICE = {
    common = 4,
    uncommon = 6,
    rare = 8,
    legendary = 10,
}

local function non_negative_integer(value)
    value = tonumber(value) or 0
    if value < 0 then
        return 0
    end
    return math.floor(value)
end

local function modifiers(run_state)
    local plaques = run_state.plaques or run_state.tags or {}
    local voucher = run_state.vouchers or {}
    return plaques, voucher
end

local function discounted_price(run_state, base_price)
    local _, voucher = modifiers(run_state)
    return math.max(1, base_price - non_negative_integer(voucher.shop_discount))
end

local function require_shop_rng(run_state)
    local random = run_state.rng and run_state.rng.shop
    if type(random) ~= "function" then
        error("shop requires run_state.rng.shop")
    end
    return random
end

local function sorted_wish_cards()
    local list = wish_cards.all()
    table.sort(list, function(a, b)
        -- Legacy ids retain the pre-migration index order for seeded shops.
        return (a.legacy_id or a.id) < (b.legacy_id or b.id)
    end)
    return list
end

local function eligible_gwang(run_state)
    local all = gwang_catalog.all()
    local plaques = run_state.plaques or run_state.tags or {}
    if not (plaques.rare_shop or plaques.uncommon_shop) then
        return all
    end

    local uncommon = {}
    for i = 1, #all do
        if all[i].rarity == "uncommon" then
            uncommon[#uncommon + 1] = all[i]
        end
    end
    if #uncommon > 0 then
        return uncommon
    end
    return all
end

local function offer(run_state, kind, definition, base_price)
    return {
        slot_type = "random",
        kind = kind,
        identity = definition.id,
        id = definition.id,
        legacy_id = definition.legacy_id,
        name = definition.name,
        rarity = definition.rarity,
        yaku = definition.yaku,
        effect = definition.effect,
        symbol = definition.symbol,
        base_price = base_price,
        price = discounted_price(run_state, base_price),
        sold = false,
    }
end

local function random_offer(run_state, random)
    local roll = random(1, 100)
    if roll <= 50 then
        local pool = eligible_gwang(run_state)
        local item = pool[random(1, #pool)]
        return offer(run_state, "gwang", item, GWANG_PRICE[item.rarity] or 4)
    elseif roll <= 75 then
        local pool = sorted_wish_cards()
        local item = pool[random(1, #pool)]
        return offer(run_state, "wish_card", item, 3)
    else
        local pool = talismans.POOL
        local item = pool[random(1, #pool)]
        return offer(run_state, "talisman", item, 3)
    end
end

local function random_slot_count(run_state)
    local plaques, voucher = modifiers(run_state)
    return M.BASE_RANDOM_SLOTS
        + non_negative_integer(plaques.extra_shop_slots)
        + non_negative_integer(voucher.shop_slots)
end

local function generate_random_offers(run_state)
    local random = require_shop_rng(run_state)
    local offers = {}
    for i = 1, random_slot_count(run_state) do
        offers[i] = random_offer(run_state, random)
    end
    return offers
end

local function make_pack_slot(run_state)
    return {
        slot_type = "pack",
        kind = "pack",
        identity = "talisman_bundle",
        id = "talisman_bundle",
        name = "부적 꾸러미",
        base_price = M.PACK_PRICE,
        price = discounted_price(run_state, M.PACK_PRICE),
        sold = false,
    }
end

local function make_voucher_slots(run_state)
    local id = run_state.vouchers and run_state.vouchers.shop_id
    if not id then
        return {}
    end
    return {
        {
            slot_type = "voucher",
            kind = "voucher",
            identity = id,
            id = id,
            base_price = M.VOUCHER_PRICE,
            price = discounted_price(run_state, M.VOUCHER_PRICE),
            sold = false,
        },
    }
end

local function rebuild_slots(shop)
    local slots = {}
    for i = 1, #shop.random_offers do
        slots[#slots + 1] = shop.random_offers[i]
    end
    for i = 1, #shop.pack_slots do
        slots[#slots + 1] = shop.pack_slots[i]
    end
    for i = 1, #shop.voucher_slots do
        slots[#slots + 1] = shop.voucher_slots[i]
    end
    shop.slots = slots
    shop.offers = slots
    shop.random_slots = shop.random_offers
end

--- Open one shop visit. Generation consumes only run_state.rng.shop.
function M.new(run_state)
    if type(run_state) ~= "table" then
        error("shop requires run state")
    end
    if type(run_state.money) ~= "number" then
        error("shop requires numeric run_state.money")
    end

    local shop = {
        run_state = run_state,
        reroll_count = 0,
        random_offers = generate_random_offers(run_state),
        pack_slots = { make_pack_slot(run_state) },
        voucher_slots = make_voucher_slots(run_state),
    }
    rebuild_slots(shop)
    return shop
end

M.open = M.new

--- Current reroll price. Free-reroll plaques take precedence over discounts.
function M.reroll_cost(shop)
    local plaques, voucher = modifiers(shop.run_state)
    if non_negative_integer(plaques.free_rerolls) > 0 then
        return 0
    end
    return math.max(0, M.BASE_REROLL_COST + shop.reroll_count
        - non_negative_integer(voucher.reroll_discount))
end

function M.can_reroll(shop)
    return shop.run_state.money >= M.reroll_cost(shop)
end

--- Replace random offers only. A failed reroll changes no state or RNG.
-- Returns success and the amount actually paid.
function M.reroll(shop)
    local run_state = shop.run_state
    local plaques = run_state.plaques or run_state.tags or {}
    local cost = M.reroll_cost(shop)
    if run_state.money < cost then
        return false, cost
    end

    -- Pay and consume the one-shot modifier before generating. No operation
    -- after this point can fail because the pools and RNG were validated at open.
    run_state.money = run_state.money - cost
    if non_negative_integer(plaques.free_rerolls) > 0 then
        plaques.free_rerolls = plaques.free_rerolls - 1
    end
    shop.reroll_count = shop.reroll_count + 1
    shop.random_offers = generate_random_offers(run_state)
    rebuild_slots(shop)
    return true, cost
end

local function resolve_slot(shop, slot_or_index)
    if type(slot_or_index) == "number" then
        return shop.slots[slot_or_index], slot_or_index
    end
    if type(slot_or_index) == "table" then
        for i = 1, #shop.slots do
            if shop.slots[i] == slot_or_index then
                return slot_or_index, i
            end
        end
    end
    return nil, nil
end

local function snapshot(slot)
    local item = {}
    for key, value in pairs(slot) do
        item[key] = value
    end
    return item
end

--- Atomically pay for a slot and mark it sold.
-- The returned transaction snapshots the pre-sale item and paid price so a
-- caller can safely roll back downstream inventory/application failures.
function M.purchase(shop, slot_or_index)
    local slot, index = resolve_slot(shop, slot_or_index)
    if not slot then
        return false, "invalid_slot"
    end
    if slot.sold then
        return false, "sold"
    end
    if shop.run_state.money < slot.price then
        return false, "insufficient_money"
    end

    local item = snapshot(slot)
    local result = {
        item = item,
        price = slot.price,
        slot = slot,
        slot_index = index,
        slot_type = slot.slot_type,
    }
    shop.run_state.money = shop.run_state.money - result.price
    slot.sold = true
    return true, result
end

M.buy = M.purchase

return M
