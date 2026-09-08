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
    M.test_blind_reward()
    M.test_hand_bonus()
    M.test_cash_out_components()
    M.test_cash_out_interest_uses_held_money()
    M.test_clear_blind_pays_out()
    M.test_clear_blind_win_still_pays()
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

function M.test_blind_reward()
    assert(economy.blind_reward("small") == 3)
    assert(economy.blind_reward("big") == 5)
    assert(economy.blind_reward("boss") == 8)
    assert(economy.blind_reward(nil) == 0)
    assert(economy.blind_reward("unknown") == 0)
end

function M.test_hand_bonus()
    -- $1 per leftover hand. Nil / negative yield $0.
    assert(economy.hand_bonus(0) == 0)
    assert(economy.hand_bonus(1) == 1)
    assert(economy.hand_bonus(4) == 4)
    assert(economy.hand_bonus(nil) == 0)
    assert(economy.hand_bonus(-2) == 0)
end

function M.test_cash_out_components()
    local state = run.new()
    state.money = 10
    state.hands_left = 3
    state.blind = "small"
    local p = economy.cash_out(state)
    -- $10 held -> $2 interest; small $3; leftover hands $3
    assert(p.reward == 3)
    assert(p.hands == 3)
    assert(p.interest == 2)
    assert(p.total == 8)
    assert(state.money == 18)
end

function M.test_cash_out_interest_uses_held_money()
    -- Interest is on money held before adding the blind / hand payout.
    local state = run.new()
    state.money = 4
    state.hands_left = 0
    state.blind = "small"
    local p = economy.cash_out(state)
    assert(p.interest == 0)
    assert(p.reward == 3)
    assert(p.hands == 0)
    assert(state.money == 7)

    state = run.new()
    state.money = 25
    state.hands_left = 0
    state.blind = "boss"
    p = economy.cash_out(state)
    assert(p.interest == 5)
    assert(p.reward == 8)
    assert(state.money == 38)
end

function M.test_clear_blind_pays_out()
    local state = run.new()
    state.money = 4
    state.hands_left = 2
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    -- small $3 + leftover hands $2 + interest $0 = $5, held $4 -> $9
    assert(state.phase == "shop")
    assert(state.money == 9)
end

function M.test_clear_blind_win_still_pays()
    local state = run.new()
    state.ante = 8
    state.blind = "boss"
    state.money = 0
    state.hands_left = 1
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "won")
    -- boss $8 + leftover hand $1 + interest $0
    assert(state.money == 9)
end

return M
