local M = {}

M.MAX_GWANG = 5
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
    [8] = 50000,
}

local BLIND_MULT = {
    small = 1,
    big = 1.5,
    boss = 2,
}

local PLAY_CARDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

function M.new()
    return {
        ante = 1,
        blind = "small",
        phase = "play",
        round_score = 0,
        gwang = {},
    }
end

function M.blind_target(state)
    local base = ANTE_BASE[state.ante]
    local mult = BLIND_MULT[state.blind]
    if not base or not mult then
        error("unknown ante or blind")
    end
    return math.floor(base * mult)
end

function M.add_score(state, amount)
    if state.phase ~= "play" then
        error("score only during play")
    end
    state.round_score = state.round_score + amount
end

function M.clear_blind(state)
    if state.phase ~= "play" then
        error("clear only during play")
    end
    if state.round_score < M.blind_target(state) then
        error("cannot clear below the blind")
    end
    if state.ante >= M.FINAL_ANTE and state.blind == "boss" then
        state.phase = "won"
        return
    end
    state.phase = "shop"
end

function M.buy_gwang(state, card)
    if state.phase ~= "shop" then
        error("buy gwang only in the shop")
    end
    if type(card) ~= "table" then
        error("gwang must be a table")
    end
    if card.kind ~= nil and card.kind ~= "gwang" then
        error("gwang slots reject play cards")
    end
    if PLAY_CARDS[card.kind] then
        error("gwang slots reject play cards")
    end
    if card.identity == nil or card.identity == "" then
        error("each gwang has one identity")
    end
    if #state.gwang >= M.MAX_GWANG then
        error("max 5 gwang joker slots")
    end
    state.gwang[#state.gwang + 1] = {
        kind = "gwang",
        identity = card.identity,
    }
end

function M.leave_shop(state)
    if state.phase ~= "shop" then
        error("leave shop only from shop")
    end
    if state.blind == "small" then
        state.blind = "big"
    elseif state.blind == "big" then
        state.blind = "boss"
    else
        state.ante = state.ante + 1
        state.blind = "small"
    end
    state.phase = "play"
    state.round_score = 0
end

return M
