-- Tests for Balatro-style round economy: interest on money.
-- Engine-hosted. No money cap. Interest cap raised by seed_money voucher.

local economy = require("game.economy")
local run = require("game.run")
local vouchers = require("game.vouchers")

local M = {}

function M.run()
    M.test_interest_per_five()
    M.test_interest_cap_default()
    M.test_interest_floor()
    M.test_no_money_cap()
    M.test_seed_money_raises_cap()
    print("  economy: OK")
end

function M.test_interest_per_five()
    -- $5 -> $1, $10 -> $2, $24 -> $4
    assert(economy.interest(5) == 1)
    assert(economy.interest(10) == 2)
    assert(economy.interest(24) == 4)
    assert(economy.interest(4) == 0)
    assert(economy.interest(0) == 0)
end

function M.test_interest_cap_default()
    -- Default cap $5 even with $100 ($20 would be uncapped)
    assert(economy.interest(100) == 5)
    assert(economy.interest(25) == 5)
    assert(economy.interest(30) == 5)
end

function M.test_interest_floor()
    assert(economy.interest(-10) == 0)
    assert(economy.interest(nil) == 0)
end

function M.test_no_money_cap()
    -- Money itself is uncapped; only interest is capped.
    local state = run.new()
    state.money = 9999
    assert(state.money == 9999)
    assert(economy.interest(state.money) == 5)
end

function M.test_seed_money_raises_cap()
    local state = run.new()
    vouchers.apply(state, "seed_money")
    -- $50 would be $10 uncapped; default cap 5, seed_money +5 -> cap 10
    assert(economy.interest(50, state) == 10)
    -- $100 would be $20; still capped at 10
    assert(economy.interest(100, state) == 10)
    -- Below the new cap still $1 per $5
    assert(economy.interest(20, state) == 4)
end

return M
