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

local tags = require("game.tags")
local boss_blinds = require("game.boss_blinds")

function M.new()
    return {
        ante = 1,
        blind = "small",
        phase = "play",
        round_score = 0,
        gwang = {},
        tags = {
            owned = {},
            free_rerolls = 0,
            pending_money = 0,
            extra_shop_slots = 0,
            hand_size_bonus = 0,
        },
        boss_id = nil,
        boss = nil,
    }
end

function M.blind_target(state)
    local base = ANTE_BASE[state.ante]
    local mult = BLIND_MULT[state.blind]
    if not base or not mult then
        error("unknown ante or blind")
    end
    local target = math.floor(base * mult)
    if state.blind == "boss" and state.boss and state.boss.effect == "double_target" then
        target = boss_blinds.apply_wall(target)
    end
    return target
end

local function enter_blind(state, blind)
    state.blind = blind
    if blind == "boss" then
        if not state.boss then
            M.select_boss(state)
        end
    else
        state.boss_id = nil
        state.boss = nil
    end
end

--- Choose the boss blind for this ante. Only valid while on a boss blind.
function M.select_boss(state, boss_id)
    if state.blind ~= "boss" then
        error("select_boss only on boss blinds")
    end
    local def = boss_id and boss_blinds.by_id(boss_id) or boss_blinds.random()
    state.boss_id = def.id
    state.boss = {
        id = def.id,
        name = def.name,
        effect = def.effect,
        kind = def.kind,
        amount = def.amount,
    }
    return def
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

--- Skip the current small/big blind and claim a tag reward.
-- Boss blinds cannot be skipped. Stays in play on the next blind.
function M.skip_blind(state, tag_id)
    if state.phase ~= "play" then
        error("skip only during play")
    end
    if state.blind == "boss" then
        error("cannot skip boss blind")
    end
    if state.blind ~= "small" and state.blind ~= "big" then
        error("unknown blind")
    end
    tags.apply(state, tag_id or tags.random().id)
    if state.blind == "small" then
        enter_blind(state, "big")
    else
        enter_blind(state, "boss")
    end
    state.round_score = 0
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
        enter_blind(state, "big")
    elseif state.blind == "big" then
        enter_blind(state, "boss")
    else
        state.ante = state.ante + 1
        enter_blind(state, "small")
    end
    state.phase = "play"
    state.round_score = 0
end

return M
