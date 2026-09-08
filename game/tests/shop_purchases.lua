local shop_purchases = require("game.shop_purchases")
local shop_engine = require("game.shop_engine")
local run = require("game.run")

local function mock_run()
    local state = run.new()
    state.phase = "shop"
    state.money = 20
    state.rng.shop = function(min, max) return min end -- predictable
    -- setup voucher in shop
    if not state.vouchers then state.vouchers = {} end
    state.vouchers.shop_id = "grabber"
    return state
end

local function run_tests()
    print("  shop_purchases:")
    
    local state = mock_run()
    local shop = shop_engine.new(state)
    
    -- Test buying a voucher
    -- Find the voucher slot
    local voucher_idx = nil
    for i, slot in ipairs(shop.slots) do
        if slot.kind == "voucher" then
            voucher_idx = i
            break
        end
    end
    assert(voucher_idx, "shop has a voucher slot")
    
    local ok = shop_purchases.buy(shop, voucher_idx)
    assert(ok, "voucher purchase succeeds")
    assert(state.vouchers.bought_this_shop == true, "voucher state updated")
    assert(state.money == 10, "money deducted (20 - 10)")
    assert(shop.slots[voucher_idx].sold == true, "slot marked sold")
    
    -- Test buying already sold slot
    local ok2 = shop_purchases.buy(shop, voucher_idx)
    assert(not ok2, "cannot buy sold slot")
    
    -- Test rollback on double voucher apply (simulate failure)
    -- manually reset sold to try to buy again, which should fail application
    shop.slots[voucher_idx].sold = false
    local start_money = state.money
    local ok3 = shop_purchases.buy(shop, voucher_idx)
    assert(not ok3, "application failure returns false")
    assert(state.money == start_money, "money rolled back")
    assert(shop.slots[voucher_idx].sold == false, "slot sold rolled back")

    -- Buying a pack opens a deterministic choice without auto-granting a tarot.
    local pack_idx = nil
    for i, slot in ipairs(shop.slots) do
        if slot.kind == "pack" then
            pack_idx = i
            break
        end
    end
    assert(pack_idx, "shop has a pack slot")
    local ok4 = shop_purchases.buy(shop, pack_idx)
    assert(ok4, "pack purchase succeeds")
    assert(state.money == start_money - shop_engine.PACK_PRICE, "pack price deducted")
    assert(shop.slots[pack_idx].sold == true, "pack slot marked sold")
    assert(state.pending_pack and state.pending_pack.id == "arcana_pack", "pack opens")
    assert(#state.pending_pack.choices == 3, "arcana pack offers three choices")
    assert(#(state.tarots or {}) == 0, "opening does not auto-grant a tarot")

    -- An already-open pack makes a later pack transaction roll back atomically.
    local second_shop = shop_engine.new(state)
    local second_pack_idx
    for i, slot in ipairs(second_shop.slots) do
        if slot.kind == "pack" then second_pack_idx = i end
    end
    local money_before_second_pack = state.money
    local ok5 = shop_purchases.buy(second_shop, second_pack_idx)
    assert(not ok5, "cannot open a second pack")
    assert(state.money == money_before_second_pack, "failed pack purchase refunds money")
    assert(second_shop.slots[second_pack_idx].sold == false, "failed pack purchase restores slot")

    -- Canonical and legacy wish-card offers both level the existing saved hand state.
    local wish_state = mock_run()
    local wish_shop = {
        run_state = wish_state,
        slots = {
            { kind = "wish_card", identity = "wish_card_hongdan", yaku = "hongdan", price = 3, sold = false },
            { kind = "planet", identity = "planet_cheongdan", price = 3, sold = false },
        },
    }
    assert(shop_purchases.buy(wish_shop, 1), "wish-card purchase succeeds")
    assert(wish_state.hands.hongdan.level == 2, "canonical offer levels hongdan")
    assert(shop_purchases.buy(wish_shop, 2), "legacy wish-card purchase succeeds")
    assert(wish_state.hands.cheongdan.level == 2, "legacy id levels cheongdan")

    print("  shop_purchases: OK")
end

return { run = run_tests }
