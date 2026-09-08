local M = {}

local seals = require("game.seals")
local round_targets = require("game.round_targets")
local gwang_inventory = require("game.gwang_inventory")
local run_state = require("game.run_state")

M.FINAL_GO = round_targets.FINAL_GO
M.FINAL_ANTE = M.FINAL_GO
M.MAX_GWANG = gwang_inventory.MAX_SLOTS

function M.new(seed_str)
    return run_state.new(seed_str)
end

function M.max_gwang(state)
    return gwang_inventory.max_slots(state)
end

function M.round_target(state)
    return round_targets.target(state)
end

M.blind_target = M.round_target

--- Compatibility delegate; boss selection is owned by game.round_flow.
function M.select_boss(state, boss_id)
    return require("game.round_flow").select_boss(state, boss_id)
end

--- Compatibility delegate; loss validation and history are owned by game.round_flow.
function M.lose(state)
    return require("game.round_flow").lose(state, 0)
end

--- Compatibility delegate; scored-hand state is owned by game.round_flow.
function M.add_score(state, amount)
    return require("game.round_flow").score(state, amount, state.hands_left)
end

function M.clear_round(state)
    local phase = require("game.round_flow").clear(state)
    if not phase then error("cannot clear below the blind") end
    return phase
end

M.clear_blind = M.clear_round

--- Compatibility delegate; play-card kind distribution is owned by game.card_deal.
function M.deal_kinds(state, n)
    return require("game.card_deal").deal(state, n)
end

--- Skip rules and progression are owned by game.round_flow.
function M.skip_round(state, plaque_id)
    return require("game.round_flow").skip_current(state, plaque_id)
end

M.skip_blind = M.skip_round

function M.buy_gwang(state, card)
    return gwang_inventory.buy(state, card)
end

--- 인장 purchase rules are owned by game.seals.
function M.buy_seal(state, id)
    return seals.buy(state, id)
end

--- Compatibility delegate for legacy callers.
function M.buy_voucher(state, id)
    return seals.buy(state, id)
end

--- Compatibility delegate; shop progression is owned by game.round_flow.
function M.leave_shop(state)
    return require("game.round_flow").leave_shop(state)
end

return M
