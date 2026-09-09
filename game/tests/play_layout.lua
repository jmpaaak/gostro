-- Shared play-scene chrome geometry and cross-region guarantees.

local layout = require("game.ui.play_layout")

local M = {}

local function overlaps(a, b)
    return a.x < b.x + b.w and b.x < a.x + a.w
        and a.y < b.y + b.h and b.y < a.y + a.h
end

function M.run()
    local gwang = layout.gwang_slots()
    assert(#gwang == 5, "play layout reserves five gwang slots")
    for i, slot in ipairs(gwang) do
        assert(slot.w == 72 and slot.h == 108,
            "gwang slot " .. i .. " uses the play-card ratio")
    end

    local score = layout.scoreboard()
    local consumables = layout.consumable_slots(3)
    local planets = layout.planets()
    local run_hud = layout.round_hud()
    local chrome = { score, planets, run_hud }
    for _, slot in ipairs(consumables) do chrome[#chrome + 1] = slot end

    local gwang_bottom = gwang[1].y + gwang[1].h
    for i, area in ipairs(chrome) do
        assert(area.y > gwang_bottom, "HUD area " .. i .. " sits below the gwang row")
        for j, slot in ipairs(gwang) do
            assert(not overlaps(area, slot),
                "HUD area " .. i .. " does not cross gwang slot " .. j)
        end
    end

    assert(not overlaps(score, planets), "scoreboard does not cross origin cards")
    for i, slot in ipairs(consumables) do
        assert(not overlaps(slot, run_hud),
            "consumable slot " .. i .. " does not cross the run HUD")
    end

    print("  play_layout: OK")
end

return M