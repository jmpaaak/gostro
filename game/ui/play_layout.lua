-- Shared geometry for persistent play-scene chrome on the 960x540 canvas.
-- Presentation modules consume these rects; this module owns no drawing.

local M = {}

local CANVAS_W = 960
local TOP_PAD = 8
local GWANG_W, GWANG_H, GWANG_GAP = 72, 108, 10
local HUD_Y = TOP_PAD + GWANG_H + 8

local function rect(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function M.gwang_slots()
    local count = 5
    local total_w = count * GWANG_W + (count - 1) * GWANG_GAP
    local start_x = math.floor((CANVAS_W - total_w) / 2)
    local slots = {}
    for i = 1, count do
        slots[i] = rect(start_x + (i - 1) * (GWANG_W + GWANG_GAP),
            TOP_PAD, GWANG_W, GWANG_H)
    end
    return slots
end

function M.scoreboard()
    return rect(12, HUD_Y, 300, 168)
end

function M.consumable_slots(capacity)
    local slot_w, slot_h, gap, right_pad = 126, 84, 9, 12
    local total_w = capacity * slot_w + math.max(0, capacity - 1) * gap
    local start_x = CANVAS_W - right_pad - total_w
    local slots = {}
    for i = 1, capacity do
        slots[i] = rect(start_x + (i - 1) * (slot_w + gap), HUD_Y,
            slot_w, slot_h)
    end
    return slots
end

function M.planets()
    return rect(12, HUD_Y + 176, 300, 48)
end

function M.round_hud()
    return rect(648, HUD_Y + 104, 300, 72)
end

return M