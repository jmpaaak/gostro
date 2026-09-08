local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

--- Deal play-card kinds from the run's dedicated cards RNG stream.
function M.deal(state, count)
    count = count or 8
    local random = (state.rng and state.rng.cards) or math.random
    local kinds = {}
    for i = 1, count do
        kinds[i] = PLAY_KINDS[random(1, #PLAY_KINDS)]
    end
    return kinds
end

return M
