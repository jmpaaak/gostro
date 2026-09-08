local M = {}

M.MAX_GWANG = 5
M.FINAL_ANTE = 8

local PLAY_CARDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

local tags = require("game.tags")
local vouchers = require("game.vouchers")
local economy = require("game.economy")
local rng = require("game.rng")
local run_history = require("game.run_history")
local blind_targets = require("game.blind_targets")

function M.new(seed_str)
    local plan = rng.plan(seed_str)
    return {
        seed = plan.seed,
        rng = {
            shop = plan.shop,
            cards = plan.cards,
            boss = plan.boss,
        },
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
        vouchers = {
            owned = {},
            hand_size = 0,
            discards = 0,
            hands = 0,
            shop_slots = 0,
            reroll_discount = 0,
            shop_discount = 0,
            interest_cap = 5,
            gwang_slots = 0,
            consumable_slots = 0,
            edition_rate = 1,
            boss_rerolls = 0,
            interest_rate = 0,
        },
        boss_id = nil,
        boss = nil,
        money = 4,
        hands_left = 4,
    }
end

function M.max_gwang(state)
    local extra = 0
    if state.vouchers then
        extra = state.vouchers.gwang_slots or 0
    end
    return M.MAX_GWANG + extra
end

function M.blind_target(state)
    return blind_targets.target(state)
end

local function enter_blind(state, blind)
    return require("game.blind_flow").enter(state, blind)
end

--- Compatibility delegate; boss selection is owned by game.blind_flow.
function M.select_boss(state, boss_id)
    return require("game.blind_flow").select_boss(state, boss_id)
end

--- End the run as a loss and record seed history.
function M.lose(state)
    state.phase = "lost"
    run_history.record(state, "lost")
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
    economy.cash_out(state)
    if state.ante >= M.FINAL_ANTE and state.blind == "boss" then
        state.phase = "won"
        run_history.record(state, "won")
        return
    end
    state.phase = "shop"
    local shop_rng = state.rng and state.rng.shop
    vouchers.stock_shop(state, shop_rng)
end

--- Deal n play-card kinds from the run's cards stream. No months.
function M.deal_kinds(state, n)
    n = n or 8
    local cards = (state.rng and state.rng.cards) or math.random
    local kinds = {}
    for i = 1, n do
        kinds[i] = PLAY_KINDS[cards(1, #PLAY_KINDS)]
    end
    return kinds
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
    if #state.gwang >= M.max_gwang(state) then
        error("max 5 gwang joker slots")
    end
    state.gwang[#state.gwang + 1] = {
        kind = "gwang",
        identity = card.identity,
    }
end

--- Buy the shop's voucher. One purchase per shop visit.
function M.buy_voucher(state, id)
    if state.phase ~= "shop" then
        error("buy voucher only in the shop")
    end
    local v = vouchers.ensure(state)
    if v.bought_this_shop then
        error("one voucher per shop")
    end
    if not v.shop_id then
        error("no voucher in shop")
    end
    if id ~= v.shop_id then
        error("buy the offered voucher")
    end
    vouchers.apply(state, id)
    v.bought_this_shop = true
    return v
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
    local extra = 0
    if state.vouchers then
        extra = state.vouchers.hands or 0
    end
    state.hands_left = 4 + extra
    vouchers.clear_shop(state)
end

return M
