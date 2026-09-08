-- Compatibility tests for the legacy game.vouchers module and run API.
local vouchers = require("game.vouchers")
local seals = require("game.seals")
local run = require("game.run")

local M = {}

function M.test_module_is_a_shim()
    assert(vouchers == seals, "legacy module must return game.seals")
    assert(vouchers.by_id("paint_brush").id == "wide_mat")
end

function M.test_legacy_state_and_id_are_accepted()
    local state = {
        phase = "shop",
        vouchers = {
            owned = {},
            shop_id = "paint_brush",
        },
    }
    local result = vouchers.buy(state, "paint_brush")
    assert(result == state.vouchers and result == state.seals)
    assert(result.owned[1] == "wide_mat", "legacy id migrates to the canonical 인장 id")
    assert(result.hand_size == 1)
end

function M.test_run_buy_voucher_remains_a_delegate()
    local original = seals.buy
    local called_state, called_id
    seals.buy = function(state, id)
        called_state, called_id = state, id
        return "delegated"
    end
    local state = {}
    local result = run.buy_voucher(state, "paint_brush")
    seals.buy = original
    assert(result == "delegated")
    assert(called_state == state and called_id == "paint_brush")
end

function M.run()
    M.test_module_is_a_shim()
    M.test_legacy_state_and_id_are_accepted()
    M.test_run_buy_voucher_remains_a_delegate()
    print("  vouchers compatibility: OK")
end

return M
