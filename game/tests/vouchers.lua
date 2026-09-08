-- Tests for Balatro-style shop vouchers (permanent upgrades).
-- Engine-hosted: catalog + run.buy_voucher shop path.

local vouchers = require("game.vouchers")
local run = require("game.run")

local M = {}

local function ids_of(pool)
    local out = {}
    for i, t in ipairs(pool) do
        out[i] = t.id
    end
    return out
end

local function enter_shop(state)
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "shop")
    return state
end

function M.run()
    require("game.tests.voucher_art").run()
    M.test_pool_size()
    M.test_by_id()
    M.test_random()
    M.test_apply_hand_and_discard()
    M.test_apply_shop_and_reroll()
    M.test_apply_interest_and_gwang()
    M.test_apply_once()
    M.test_shop_stocks_one()
    M.test_buy_in_shop()
    M.test_buy_contract_owned_by_vouchers()
    M.test_run_buy_is_compatibility_delegate()
    M.test_cannot_buy_outside_shop()
    M.test_one_per_shop()
    M.test_leave_shop_clears_slot()
    M.test_gwang_slot_raises_max()
    M.test_no_forbidden_words()
    print("  vouchers: OK")
end

function M.test_pool_size()
    assert(type(vouchers.POOL) == "table")
    assert(#vouchers.POOL >= 10, "voucher pool must have 10+ kinds, got " .. tostring(#vouchers.POOL))
    local seen = {}
    local effects = {}
    for _, t in ipairs(vouchers.POOL) do
        assert(type(t.id) == "string" and t.id ~= "", "each voucher needs an id")
        assert(type(t.name) == "string" and t.name ~= "", "each voucher needs a name")
        assert(type(t.effect) == "string" and t.effect ~= "", "each voucher needs an effect")
        assert(not seen[t.id], "duplicate voucher id: " .. t.id)
        seen[t.id] = true
        effects[t.effect] = true
    end
    assert(effects.hand_size, "pool must include hand size +1")
    assert(effects.discard, "pool must include discard +1")
    assert(effects.shop_slots, "pool must include shop slots +1")
    assert(effects.reroll_discount, "pool must include reroll discount")
    assert(effects.interest_cap, "pool must include interest cap up")
    assert(effects.gwang_slots, "pool must include gwang slots +1")
end

function M.test_by_id()
    local v = vouchers.by_id("paint_brush")
    assert(v.id == "paint_brush")
    assert(v.effect == "hand_size")
    local ok = pcall(vouchers.by_id, "not_a_voucher")
    assert(not ok, "unknown voucher must error")
end

function M.test_random()
    local t = vouchers.random(function(a, _) return a end)
    assert(t.id == vouchers.POOL[1].id)
    local t2 = vouchers.random(function(_, b) return b end)
    assert(t2.id == vouchers.POOL[#vouchers.POOL].id)
    local t3 = vouchers.random()
    assert(t3 and t3.id)
end

function M.test_apply_hand_and_discard()
    local state = run.new()
    vouchers.apply(state, "paint_brush")
    assert(state.vouchers.hand_size >= 1)
    vouchers.apply(state, "wasteful")
    assert(state.vouchers.discards >= 1)
    vouchers.apply(state, "grabber")
    assert(state.vouchers.hands >= 1)
end

function M.test_apply_shop_and_reroll()
    local state = run.new()
    vouchers.apply(state, "overstock")
    assert(state.vouchers.shop_slots >= 1)
    vouchers.apply(state, "reroll_surplus")
    assert(state.vouchers.reroll_discount >= 1)
    vouchers.apply(state, "clearance_sale")
    assert(state.vouchers.shop_discount >= 1)
end

function M.test_apply_interest_and_gwang()
    local state = run.new()
    local cap0 = state.vouchers.interest_cap or 5
    vouchers.apply(state, "seed_money")
    assert(state.vouchers.interest_cap > cap0)
    vouchers.apply(state, "antimatter")
    assert(state.vouchers.gwang_slots >= 1)
    vouchers.apply(state, "crystal_ball")
    assert(state.vouchers.consumable_slots >= 1)
    vouchers.apply(state, "hone")
    assert(state.vouchers.edition_rate >= 2)
    vouchers.apply(state, "directors_cut")
    assert(state.vouchers.boss_rerolls >= 1)
    vouchers.apply(state, "money_tree")
    assert(state.vouchers.interest_rate >= 1)
end

function M.test_apply_once()
    local state = run.new()
    vouchers.apply(state, "paint_brush")
    local ok = pcall(vouchers.apply, state, "paint_brush")
    assert(not ok, "each voucher identity once")
    assert(state.vouchers.owned[1] == "paint_brush")
    assert(#state.vouchers.owned == 1)
end

function M.test_shop_stocks_one()
    local state = enter_shop(run.new())
    assert(type(state.vouchers.shop_id) == "string" and state.vouchers.shop_id ~= "")
    local def = vouchers.by_id(state.vouchers.shop_id)
    assert(def.effect)
    assert(state.vouchers.bought_this_shop ~= true)
end

function M.test_buy_in_shop()
    local state = enter_shop(run.new())
    local id = state.vouchers.shop_id
    run.buy_voucher(state, id)
    assert(state.vouchers.owned[1] == id)
    assert(state.vouchers.bought_this_shop == true)
end

function M.test_buy_contract_owned_by_vouchers()
    local state = enter_shop(run.new())
    local id = state.vouchers.shop_id
    local bought = vouchers.buy(state, id)
    assert(bought == state.vouchers)
    assert(bought.owned[1] == id)
    assert(bought.bought_this_shop == true)

    local wrong_phase = run.new()
    wrong_phase.vouchers.shop_id = "paint_brush"
    local phase_ok = pcall(vouchers.buy, wrong_phase, "paint_brush")
    assert(not phase_ok, "voucher purchase requires shop phase")

    local wrong_offer = enter_shop(run.new())
    local offered = wrong_offer.vouchers.shop_id
    local other = offered == "paint_brush" and "overstock" or "paint_brush"
    local offer_ok = pcall(vouchers.buy, wrong_offer, other)
    assert(not offer_ok, "voucher purchase must match the stocked offer")
    assert(#wrong_offer.vouchers.owned == 0, "rejected purchase must not apply a voucher")

    local second_ok = pcall(vouchers.buy, state, id)
    assert(not second_ok, "one voucher purchase is allowed per shop visit")
end

function M.test_run_buy_is_compatibility_delegate()
    local original = vouchers.buy
    local called_state, called_id
    vouchers.buy = function(state, id)
        called_state, called_id = state, id
        return "delegated"
    end
    local state = {}
    local result = run.buy_voucher(state, "paint_brush")
    vouchers.buy = original
    assert(result == "delegated")
    assert(called_state == state and called_id == "paint_brush")
end

function M.test_cannot_buy_outside_shop()
    local state = run.new()
    local ok = pcall(run.buy_voucher, state, "paint_brush")
    assert(not ok, "buy voucher only in the shop")
end

function M.test_one_per_shop()
    local state = enter_shop(run.new())
    local id = state.vouchers.shop_id
    run.buy_voucher(state, id)
    local ok = pcall(run.buy_voucher, state, id)
    assert(not ok, "one voucher per shop")
    local other_ok = pcall(run.buy_voucher, state, "overstock")
    assert(not other_ok, "cannot buy a different voucher after one purchase")
end

function M.test_leave_shop_clears_slot()
    local state = enter_shop(run.new())
    local first = state.vouchers.shop_id
    run.buy_voucher(state, first)
    run.leave_shop(state)
    assert(state.phase == "play")
    assert(state.vouchers.shop_id == nil)
    assert(state.vouchers.bought_this_shop ~= true)
    enter_shop(state)
    assert(type(state.vouchers.shop_id) == "string")
    assert(state.vouchers.shop_id ~= first, "next shop offers a not-yet-owned voucher")
end

function M.test_gwang_slot_raises_max()
    local state = enter_shop(run.new())
    vouchers.apply(state, "antimatter")
    assert(run.max_gwang(state) == run.MAX_GWANG + 1)
    for i = 1, run.MAX_GWANG do
        run.buy_gwang(state, { identity = "chips" .. i })
    end
    run.buy_gwang(state, { identity = "extra" })
    assert(#state.gwang == run.MAX_GWANG + 1)
    local sixth = pcall(run.buy_gwang, state, { identity = "too_many" })
    assert(not sixth, "gwang cap still applies after extra slot")
end

function M.test_no_forbidden_words()
    local blob = table.concat(ids_of(vouchers.POOL), ",")
    for _, t in ipairs(vouchers.POOL) do
        blob = blob .. "," .. t.name .. "," .. tostring(t.effect)
    end
    assert(not blob:find("고수패", 1, true))
    assert(not blob:find("mae", 1, true))
    assert(not blob:find("ppeok", 1, true))
    assert(not blob:find("otti", 1, true))
    assert(not blob:find("gwangyeol", 1, true))
end

return M
