-- Tests for game/ui/gwang_slots.lua
-- Headless: tests data/layout logic only (no love.graphics calls).

local gwang_slots = require("game.ui.gwang_slots")

local M = {}

function M.run()
    -- new() creates state with 5 empty slots
    local gs = gwang_slots.new()
    assert(gs ~= nil, "new returns state")
    assert(#gs.slots == 5, "always 5 slot positions")
    for i = 1, 5 do
        assert(gs.slots[i].gwang == nil, "slot " .. i .. " starts empty")
    end

    -- MAX_SLOTS is 5
    assert(gwang_slots.MAX_SLOTS == 5, "max 5 slots")

    -- slot layout: horizontal row at the top of the viewport
    local pos = gwang_slots.slot_positions()
    assert(#pos == 5, "5 position rects")
    -- slots should be arranged left-to-right
    for i = 2, 5 do
        assert(pos[i].x > pos[i - 1].x, "slot " .. i .. " right of " .. (i - 1))
    end
    -- all at same y (top row)
    for i = 2, 5 do
        assert(pos[i].y == pos[1].y, "all slots same y")
    end
    -- y should be near top (within first 20 pixels)
    assert(pos[1].y <= 20, "slots near top of viewport")

    -- equip gwang into slot
    gwang_slots.equip(gs, { kind = "gwang", identity = "chips" })
    assert(gs.slots[1].gwang ~= nil, "first slot filled")
    assert(gs.slots[1].gwang.identity == "chips", "identity preserved")
    assert(gs.slots[2].gwang == nil, "second still empty")

    -- equip fills next available slot
    gwang_slots.equip(gs, { kind = "gwang", identity = "mult" })
    assert(gs.slots[2].gwang ~= nil, "second slot filled")
    assert(gs.slots[2].gwang.identity == "mult")

    -- fill all 5
    gwang_slots.equip(gs, { kind = "gwang", identity = "yaku_mult" })
    gwang_slots.equip(gs, { kind = "gwang", identity = "chips" })
    gwang_slots.equip(gs, { kind = "gwang", identity = "mult" })
    assert(gs.slots[5].gwang ~= nil, "fifth slot filled")

    -- 6th equip rejected
    local ok = gwang_slots.equip(gs, { kind = "gwang", identity = "chips" })
    assert(ok == false, "6th equip rejected")

    -- display_text returns ★ + name + effect for equipped gwang
    local text = gwang_slots.display_text({ kind = "gwang", identity = "chips" })
    assert(text:find("★"), "has star symbol")
    assert(text:find("칩"), "has name")

    local text2 = gwang_slots.display_text({ kind = "gwang", identity = "mult" })
    assert(text2:find("★"), "has star symbol")
    assert(text2:find("배수"), "has name for mult")

    -- display_text for yaku_mult
    local text3 = gwang_slots.display_text({ kind = "gwang", identity = "yaku_mult" })
    assert(text3:find("★"), "has star symbol")

    -- is_empty helper
    assert(gwang_slots.is_empty(gs, 1) == false, "slot 1 not empty")
    local gs2 = gwang_slots.new()
    assert(gwang_slots.is_empty(gs2, 1) == true, "slot 1 empty in new state")
    assert(gwang_slots.is_empty(gs2, 5) == true, "slot 5 empty in new state")

    -- sync_from_run: sync slots from run state gwang list
    local gs3 = gwang_slots.new()
    local run_gwang = {
        { kind = "gwang", identity = "chips" },
        { kind = "gwang", identity = "mult" },
        { kind = "gwang", identity = "yaku_mult" },
    }
    gwang_slots.sync_from_run(gs3, run_gwang)
    assert(gs3.slots[1].gwang.identity == "chips")
    assert(gs3.slots[2].gwang.identity == "mult")
    assert(gs3.slots[3].gwang.identity == "yaku_mult")
    assert(gs3.slots[4].gwang == nil)
    assert(gs3.slots[5].gwang == nil)

    require("game.tests.gwang_art").run()
    print("  gwang_slots_ui OK")
end

return M
