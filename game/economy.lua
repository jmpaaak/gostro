-- game/economy.lua
-- Round economy: interest, round reward, leftover-hand bonus.
-- Interest $1 per $5 held, capped (default $5). No money cap.
-- The 곳간 열쇠 인장 raises the interest cap. Headless-safe.

local M = {}

M.INTEREST_PER = 5
M.DEFAULT_CAP = 5
M.HAND_BONUS = 1

M.ROUND_REWARD = {
    small = 3,
    big = 5,
    boss = 8,
}
M.BLIND_REWARD = M.ROUND_REWARD -- legacy API alias

local function money_of(n)
    n = tonumber(n) or 0
    if n < 0 then
        return 0
    end
    return math.floor(n)
end

--- Interest earned on current money. Optional state reads the 인장 cap.
-- $1 per $5, capped at seals.interest_cap (default 5). No money cap.
function M.interest(money, state)
    local held = money_of(money)
    local raw = math.floor(held / M.INTEREST_PER)
    local cap = M.DEFAULT_CAP
    local upgrades = type(state) == "table" and (state.seals or state.vouchers)
    if type(upgrades) == "table" then
        cap = upgrades.interest_cap or cap
    end
    if raw > cap then
        return cap
    end
    return raw
end

--- Round cash reward. opening $3 / main $5 / final $8.
function M.round_reward(round_kind)
    return M.ROUND_REWARD[round_kind] or 0
end

M.blind_reward = M.round_reward

--- $1 per leftover hand. Nil / negative yield $0.
function M.hand_bonus(hands_left)
    local n = tonumber(hands_left) or 0
    if n < 0 then
        return 0
    end
    return math.floor(n) * M.HAND_BONUS
end

--- Round cash-out: interest on held money + round reward + leftover hands.
-- Mutates state.money. No money cap. Returns the payout breakdown.
function M.cash_out(state)
    if type(state) ~= "table" then
        error("cash_out needs run state")
    end
    local held = money_of(state.money)
    local interest = M.interest(held, state)
    local reward = M.round_reward(state.blind)
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
