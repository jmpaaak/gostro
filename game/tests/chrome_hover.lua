-- Pack choices, gwang tooltips, and action buttons respond to hover.

local pack_ui = require("game.ui.pack")
local gwang_slots = require("game.ui.gwang_slots")
local action_buttons = require("game.ui.action_buttons")

local M = {}

function M.run()
    local pending = {
        name = "아르카나 팩",
        choose = 1,
        choices = {
            { id = "the_magician", name = "둔갑 부적", effect = "변환" },
            { id = "the_hanged_man", name = "매달린 사람", effect = "파괴" },
        },
    }
    local view = pack_ui.view(pending)
    pack_ui.set_hover_at(pending, view.choices[1].bounds.x + 2, view.choices[1].bounds.y + 2)
    assert(pending.hover == 1, "pack choice hover is recorded")
    pack_ui.set_hover_at(pending, 0, 0)
    assert(pending.hover == nil, "leaving a pack choice clears hover")

    local gs = gwang_slots.new()
    gwang_slots.equip(gs, { kind = "gwang", identity = "chips" })
    local pos = gwang_slots.slot_positions()
    gwang_slots.set_hover_at(gs, pos[1].x + 2, pos[1].y + 2)
    assert(gs.hover == 1, "filled gwang slot can hover")
    gwang_slots.set_hover_at(gs, pos[2].x + 2, pos[2].y + 2)
    assert(gs.hover == nil, "empty gwang slot has no tooltip")

    local ab = action_buttons.new()
    action_buttons.set_selection(ab, 2)
    action_buttons.set_hover_at(ab, action_buttons.PLAY_X + 2, action_buttons.BUTTON_Y + 2)
    assert(ab.hover == "play")
    action_buttons.set_hover_at(ab, 0, 0)
    assert(ab.hover == nil)

    print("  chrome_hover: OK")
end

return M
