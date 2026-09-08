-- game/economy.lua
-- Balatro-style interest: $1 per $5 held, capped (default $5).
-- No money cap. seed_money voucher raises the interest cap.
-- Headless-safe.

local M = {}

M.INTEREST_PER = 5
M.DEFAULT_CAP = 5

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

return M
