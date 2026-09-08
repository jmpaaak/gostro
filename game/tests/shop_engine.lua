-- game/tests/shop_engine.lua
-- Headless tests for deterministic shop state and transactions.

local rng = require("game.rng")
local shop_engine = require("game.shop_engine")
local vouchers = require("game.vouchers")

local M = {}

local function run_state(seed, money)
    local plan = rng.plan(seed)
    return {
        money = money or 100,
        rng = { shop = plan.shop },
        tags = { free_rerolls = 0, extra_shop_slots = 0 },
        vouchers = {
            owned = {},
            shop_id = "paint_brush",
            shop_slots = 0,
            reroll_discount = 0,
            shop_discount = 0,
        },
    }
end

local function signature(shop)
    local out = {}
    for i = 1, #shop.random_offers do
        local offer = shop.random_offers[i]
        out[#out + 1] = table.concat({ offer.kind, offer.identity, offer.price }, ":")
    end
    return table.concat(out, "|")
end

function M.test_seeded_generation_uses_only_shop_stream()
    local old_random = math.random
    math.random = function()
        error("shop engine must not use math.random")
    end
    local ok, a = pcall(shop_engine.new, run_state("SAMESEED", 100))
    math.random = old_random
    assert(ok, a)

    local b = shop_engine.new(run_state("SAMESEED", 100))
    assert(signature(a) == signature(b), "same seed must reproduce random offers")
    assert(#a.random_offers == shop_engine.BASE_RANDOM_SLOTS)
    for i = 1, #a.random_offers do
        local offer = a.random_offers[i]
        assert(offer.slot_type == "random")
        assert(offer.identity and offer.price >= 1)
        assert(offer.kind == "gwang" or offer.kind == "planet" or offer.kind == "tarot")
    end
end

function M.test_shop_slot_modifiers_and_fixed_slots()
    local state = run_state("SLOTS", 100)
    state.vouchers.shop_slots = 1
    state.tags.extra_shop_slots = 2
    local shop = shop_engine.new(state)
    assert(#shop.random_offers == shop_engine.BASE_RANDOM_SLOTS + 3)
    assert(#shop.pack_slots == 1 and shop.pack_slots[1].slot_type == "pack")
    assert(#shop.voucher_slots == 1 and shop.voucher_slots[1].identity == "paint_brush")
    assert(#shop.slots == #shop.random_offers + 2)
end

function M.test_reroll_replaces_random_only_and_tracks_cost()
    local state = run_state("REROLL", 50)
    local shop = shop_engine.new(state)
    local old_random = shop.random_offers
    local old_pack = shop.pack_slots[1]
    local old_voucher = shop.voucher_slots[1]

    assert(shop_engine.reroll_cost(shop) == 5)
    local ok, paid = shop_engine.reroll(shop)
    assert(ok and paid == 5)
    assert(state.money == 45)
    assert(shop.reroll_count == 1 and shop_engine.reroll_cost(shop) == 6)
    assert(shop.random_offers ~= old_random, "random offers must be replaced")
    assert(shop.pack_slots[1] == old_pack, "pack slot must survive reroll")
    assert(shop.voucher_slots[1] == old_voucher, "voucher slot must survive reroll")

    ok, paid = shop_engine.reroll(shop)
    assert(ok and paid == 6)
    assert(state.money == 39 and shop_engine.reroll_cost(shop) == 7)
end

function M.test_free_and_discounted_rerolls_are_consumed()
    local state = run_state("MODIFIERS", 20)
    state.tags.free_rerolls = 1
    state.vouchers.reroll_discount = 2
    local shop = shop_engine.new(state)

    assert(shop_engine.reroll_cost(shop) == 0)
    local ok, paid = shop_engine.reroll(shop)
    assert(ok and paid == 0 and state.money == 20)
    assert(state.tags.free_rerolls == 0)
    assert(shop_engine.reroll_cost(shop) == 4, "second reroll is 5 + 1 - 2")

    ok, paid = shop_engine.reroll(shop)
    assert(ok and paid == 4 and state.money == 16)
end

function M.test_failed_reroll_is_atomic()
    local state = run_state("POOR", 4)
    local shop = shop_engine.new(state)
    local before = signature(shop)
    local ok, cost = shop_engine.reroll(shop)
    assert(not ok and cost == 5)
    assert(state.money == 4 and shop.reroll_count == 0)
    assert(signature(shop) == before, "failed reroll must not consume RNG or offers")
end

function M.test_discounted_purchase_preserves_paid_price_for_rollback()
    local state = run_state("BUY", 100)
    state.vouchers.shop_discount = 2
    local shop = shop_engine.new(state)
    local slot = shop.random_offers[1]
    assert(slot.price == math.max(1, slot.base_price - 2))

    local ok, result = shop_engine.purchase(shop, slot)
    assert(ok and result.price == slot.price)
    assert(result.item.price == result.price, "transaction snapshot retains price")
    assert(result.item ~= slot, "transaction result must be a snapshot")
    assert(slot.sold == true and state.money == 100 - result.price)

    local money = state.money
    local again = shop_engine.purchase(shop, slot)
    assert(again == false and state.money == money, "failed purchase is atomic")
end

function M.test_purchase_rejects_unaffordable_without_mutation()
    local state = run_state("NOFUNDS", 0)
    local shop = shop_engine.new(state)
    local slot = shop.random_offers[1]
    local ok, reason = shop_engine.purchase(shop, slot)
    assert(not ok and reason == "insufficient_money")
    assert(not slot.sold and state.money == 0)
end

function M.run()
    M.test_seeded_generation_uses_only_shop_stream()
    M.test_shop_slot_modifiers_and_fixed_slots()
    M.test_reroll_replaces_random_only_and_tracks_cost()
    M.test_free_and_discounted_rerolls_are_consumed()
    M.test_failed_reroll_is_atomic()
    M.test_discounted_purchase_preserves_paid_price_for_rollback()
    M.test_purchase_rejects_unaffordable_without_mutation()
    print("  shop_engine: OK")
end

return M
