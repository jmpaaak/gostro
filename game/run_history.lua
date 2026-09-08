-- game/run_history.lua
-- Balatro-style run history: seed + outcome of finished runs.
-- Headless-safe. No month numbers/names.

local rng = require("game.rng")

local M = {}

M.MAX = 8

local entries = {}

function M.reset()
    entries = {}
end

--- Newest-first copy of recorded runs.
function M.list()
    local out = {}
    for i = 1, #entries do
        out[i] = entries[i]
    end
    return out
end

--- Record a finished run. outcome is "won" or "lost".
function M.record(state, outcome)
    if type(state) ~= "table" then
        error("record needs run state")
    end
    if outcome ~= "won" and outcome ~= "lost" then
        error("outcome must be won or lost")
    end
    local seed = rng.normalize(state.seed)
    if seed == "" then
        seed = rng.generate()
    end
    local entry = {
        seed = seed,
        outcome = outcome,
        ante = state.ante,
        blind = state.blind,
        money = state.money or 0,
    }
    table.insert(entries, 1, entry)
    while #entries > M.MAX do
        entries[#entries] = nil
    end
    return entry
end

return M
