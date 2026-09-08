local gwang_inventory = require("game.gwang_inventory")
local run = require("game.run")

local M = {}

function M.run()
    local state = {
        phase = "shop",
        gwang = {},
        vouchers = { gwang_slots = 1 },
    }

    assert(gwang_inventory.MAX_SLOTS == 5)
    assert(gwang_inventory.max_slots(state) == 6)
    assert(gwang_inventory.max_slots({ gwang = {} }) == 5)

    local not_shop = pcall(gwang_inventory.buy, {
        phase = "play", gwang = {},
    }, { identity = "chips" })
    assert(not not_shop, "buying is restricted to the shop")

    local play_card = pcall(gwang_inventory.buy, state, {
        kind = "pi", identity = "chips",
    })
    assert(not play_card and #state.gwang == 0,
        "play cards are rejected without changing inventory")

    local bought = gwang_inventory.buy(state, {
        kind = "gwang", identity = "chips", ignored = true,
    })
    assert(bought == state.gwang[1], "buy returns the inserted slot card")
    assert(bought.kind == "gwang" and bought.identity == "chips")
    assert(bought.ignored == nil, "only gwang slot identity crosses the boundary")

    for i = 2, 6 do
        gwang_inventory.buy(state, { identity = "slot-" .. i })
    end
    local over_cap = pcall(gwang_inventory.buy, state, { identity = "too-many" })
    assert(not over_cap and #state.gwang == 6,
        "voucher-adjusted capacity is enforced without partial insertion")

    local original_max = gwang_inventory.max_slots
    local original_buy = gwang_inventory.buy
    gwang_inventory.max_slots = function(delegated_state)
        assert(delegated_state == state)
        return 9
    end
    gwang_inventory.buy = function(delegated_state, card)
        assert(delegated_state == state and card.identity == "delegate")
        return "inserted"
    end
    assert(run.max_gwang(state) == 9)
    assert(run.buy_gwang(state, { identity = "delegate" }) == "inserted")
    gwang_inventory.max_slots = original_max
    gwang_inventory.buy = original_buy
    assert(run.MAX_GWANG == gwang_inventory.MAX_SLOTS,
        "legacy slot constant remains compatible")

    print("  gwang_inventory: OK")
end

return M