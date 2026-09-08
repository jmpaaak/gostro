local boss_rounds = require("game.boss_rounds")

local M = {}

M.FINAL_GO = 8
M.FINAL_ANTE = M.FINAL_GO -- legacy compatibility

-- Go bases. Opening = base, main = 1.5x, final = 2x.
local GO_BASE = {
    [1] = 300,
    [2] = 800,
    [3] = 2000,
    [4] = 5000,
    [5] = 11000,
    [6] = 20000,
    [7] = 35000,
    [M.FINAL_GO] = 50000,
}

local ROUND_MULT = {
    small = 1,
    big = 1.5,
    boss = 2,
}

--- Return the unmodified target for a go and round kind.
function M.base(go, kind)
    local base = GO_BASE[go]
    local mult = ROUND_MULT[kind]
    if not base or not mult then
        error("unknown go or round")
    end
    return math.floor(base * mult)
end

--- Resolve the base target plus a boss target modifier from run-like state.
function M.target(state, kind)
    kind = kind or state.blind
    local target = M.base(state.ante, kind)
    if kind == "boss" and state.boss and state.boss.effect == "double_target" then
        target = boss_rounds.apply_wall(target)
    end
    return target
end

return M