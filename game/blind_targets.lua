local boss_blinds = require("game.boss_blinds")

local M = {}

M.FINAL_ANTE = 8

-- Balatro-style ante bases. Small = base, big = 1.5x, boss = 2x.
local ANTE_BASE = {
    [1] = 300,
    [2] = 800,
    [3] = 2000,
    [4] = 5000,
    [5] = 11000,
    [6] = 20000,
    [7] = 35000,
    [M.FINAL_ANTE] = 50000,
}

local BLIND_MULT = {
    small = 1,
    big = 1.5,
    boss = 2,
}

--- Return the unmodified target for an ante and blind kind.
function M.base(ante, kind)
    local base = ANTE_BASE[ante]
    local mult = BLIND_MULT[kind]
    if not base or not mult then
        error("unknown ante or blind")
    end
    return math.floor(base * mult)
end

--- Resolve the base target plus a boss target modifier from run-like state.
function M.target(state, kind)
    kind = kind or state.blind
    local target = M.base(state.ante, kind)
    if kind == "boss" and state.boss and state.boss.effect == "double_target" then
        target = boss_blinds.apply_wall(target)
    end
    return target
end

return M