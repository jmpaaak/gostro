local M = {}

local vouchers = require("game.vouchers")
local blind_targets = require("game.blind_targets")
local gwang_inventory = require("game.gwang_inventory")
local run_state = require("game.run_state")

M.FINAL_ANTE = blind_targets.FINAL_ANTE
M.MAX_GWANG = gwang_inventory.MAX_SLOTS

function M.new(seed_str)
    return run_state.new(seed_str)
end

function M.max_gwang(state)
    return gwang_inventory.max_slots(state)
end

function M.blind_target(state)
    return blind_targets.target(state)
end

--- Compatibility delegate; boss selection is owned by game.blind_flow.
function M.select_boss(state, boss_id)
    return require("game.blind_flow").select_boss(state, boss_id)
end

--- Compatibility delegate; loss validation and history are owned by game.blind_flow.
function M.lose(state)
    return require("game.blind_flow").lose(state, 0)
end

--- Compatibility delegate; scored-hand state is owned by game.blind_flow.
function M.add_score(state, amount)
    return require("game.blind_flow").score(state, amount, state.hands_left)
end

function M.clear_blind(state)
    local phase = require("game.blind_flow").clear(state)
    if not phase then error("cannot clear below the blind") end
    return phase
end

--- Compatibility delegate; play-card kind distribution is owned by game.card_deal.
function M.deal_kinds(state, n)
    return require("game.card_deal").deal(state, n)
end

--- Compatibility delegate; skip rules and progression are owned by game.blind_flow.
function M.skip_blind(state, plaque_id)
    return require("game.blind_flow").skip_current(state, plaque_id)
end

function M.buy_gwang(state, card)
    return gwang_inventory.buy(state, card)
end

--- Compatibility delegate; voucher purchase rules are owned by game.vouchers.
function M.buy_voucher(state, id)
    return vouchers.buy(state, id)
end

--- Compatibility delegate; shop progression is owned by game.blind_flow.
function M.leave_shop(state)
    return require("game.blind_flow").leave_shop(state)
end

return M
