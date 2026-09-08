-- game/tests/consumables_ui.lua
-- Pure inventory layout and selection contract for held tarot consumables.

local consumables_ui = require("game.ui.consumables")
local run = require("game.run")
local tarots = require("game.tarots")
local vouchers = require("game.vouchers")

local M = {}

local function center(bounds)
    return bounds.x + math.floor(bounds.w / 2), bounds.y + math.floor(bounds.h / 2)
end

function M.run()
    print("  consumables_ui:")

    local state = run.new("CONSUMABLES-UI")
    tarots.gain(state, "the_magician", "shop")
    local view = consumables_ui.view(state)
    assert(view.label == "소모품" and view.capacity == 2)
    assert(#view.slots == 2, "default capacity renders two slots")
    assert(view.slots[1].card.id == "the_magician")
    assert(view.slots[1].name == "마법사")
    assert(view.slots[2].card == nil and view.slots[2].name == "비어 있음")

    local first_x, first_y = center(view.slots[1].bounds)
    local empty_x, empty_y = center(view.slots[2].bounds)
    assert(consumables_ui.hit_test(state, first_x, first_y) == 1)
    assert(consumables_ui.hit_test(state, empty_x, empty_y) == nil,
        "empty slots cannot be selected")
    assert(consumables_ui.select(state, nil, first_x, first_y) == 1)
    assert(consumables_ui.select(state, 1, first_x, first_y) == nil,
        "pressing the selected consumable toggles it off")
    assert(consumables_ui.view(state, 1).slots[1].selected == true)

    vouchers.apply(state, "crystal_ball")
    view = consumables_ui.view(state, 99)
    assert(view.capacity == 3 and #view.slots == 3,
        "Crystal Ball capacity is reflected by the inventory")
    assert(view.selected_slot == nil, "invalid selection is discarded")
    assert(consumables_ui.hit_test(state, 0, 0) == nil)

    print("  consumables_ui: OK")
end

return M
