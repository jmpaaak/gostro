-- game/economy.lua
-- Balatro-style round economy: interest, blind reward, leftover-hand bonus.
-- Interest $1 per $5 held, capped (default $5). No money cap.
-- seed_money voucher raises the interest cap. Headless-safe.

local M = {}

M.INTEREST_PER = 5
M.DEFAULT_CAP = 5
M.HAND_BONUS = 1

M.BLIND_REWARD = {
    small = 3,
    big = 5,
    boss = 8,
}

local function money_of(n)
    n = tonumber(n) or 0
    if n < 0 then
        return 0
    end
    return math.floor(n)
end

--- Interest earned on current money. Optional state reads voucher cap.
-- $1 per $5, capped at vouchers.interest_cap (default 5). No money cap.
function M.interest(money, state)
    local held = money_of(money)
    local raw = math.floor(held / M.INTEREST_PER)
    local cap = M.DEFAULT_CAP
    if type(state) == "table" and type(state.vouchers) == "table" then
        cap = state.vouchers.interest_cap or cap
    end
    if raw > cap then
        return cap
    end
    return raw
end

--- Blind cash reward. small $3 / big $5 / boss $8.
function M.blind_reward(blind)
    return M.BLIND_REWARD[blind] or 0
end

--- $1 per leftover hand. Nil / negative yield $0.
function M.hand_bonus(hands_left)
    local n = tonumber(hands_left) or 0
    if n < 0 then
        return 0
    end
    return math.floor(n) * M.HAND_BONUS
end

--- Round cash-out: interest on held money + blind reward + leftover hands.
-- Mutates state.money. No money cap. Returns the payout breakdown.
function M.cash_out(state)
    if type(state) ~= "table" then
        error("cash_out needs run state")
    end
    local held = money_of(state.money)
    local interest = M.interest(held, state)
    local reward = M.blind_reward(state.blind)
    local hands = M.hand_bonus(state.hands_left)
    local total = interest + reward + hands
    state.money = held + total
    return {
        interest = interest,
        reward = reward,
        hands = hands,
        total = total,
    }
end

return M
