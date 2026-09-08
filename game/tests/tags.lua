-- Compatibility tests for the retired game.tags API and legacy save ids.

local tags = require("game.tags")
local plaques = require("game.plaques")
local run = require("game.run")

local M = {}

function M.run()
    assert(tags == plaques)

    local state = run.new("legacy-tags")
    tags.apply(state, "coupon")
    tags.apply(state, "investment")
    tags.apply(state, "handy")
    tags.apply(state, "economy")
    tags.apply(state, "mega")
    tags.apply(state, "foil")
    tags.apply(state, "hologram")
    tags.apply(state, "polychrome")
    tags.apply(state, "charm")
    tags.apply(state, "uncommon")
    tags.apply(state, "juggle")
    tags.apply(state, "d6")

    assert(state.tags == state.plaques)
    assert(state.tags.free_rerolls == 3)
    assert(state.tags.pending_money == 33)
    assert(state.tags.duplicate_next_gwang == true)
    assert(state.tags.next_gwang_edition == "polychrome")
    assert(state.tags.extra_shop_slots == 1)
    assert(state.tags.uncommon_shop == true)
    assert(state.tags.hand_size_bonus == 1)
    assert(state.tags.owned[1] == "saebaram" and state.tags.owned[12] == "yutnori")

    run.skip_blind(run.new("legacy-skip"), "coupon")
    print("  tags compatibility: OK")
end

return M
