-- game/ui/gwang_slots.lua
-- Gwang (joker) slot bar: top row, max 5 slots.
-- Empty slots show dashed border; equipped show ★ + name + effect.

local gwang_art = require("game.ui.gwang_art")

local M = {}

M.MAX_SLOTS = 5

-- Layout: 960×540 viewport, slots near top
local VIEWPORT_W = 960
local SLOT_W     = 84
local SLOT_H     = 48
local SLOT_GAP   = 12
local TOP_PAD    = 12

-- Gwang identity → display info
local GWANG_INFO = {
    chips     = { name = "칩",    effect = "+30 칩" },
    mult      = { name = "배수",  effect = "+4 배수" },
    yaku_mult = { name = "족보",  effect = "×1.5 배수" },
}

--- Create a new gwang-slot UI state (5 empty slots).
function M.new()
    local slots = {}
    for i = 1, M.MAX_SLOTS do
        slots[i] = { gwang = nil }
    end
    return { slots = slots }
end

--- Return layout rectangles for all 5 slots (centred horizontally).
function M.slot_positions()
    local total_w = M.MAX_SLOTS * SLOT_W + (M.MAX_SLOTS - 1) * SLOT_GAP
    local start_x = math.floor((VIEWPORT_W - total_w) / 2)
    local positions = {}
    for i = 1, M.MAX_SLOTS do
        positions[i] = {
            x = start_x + (i - 1) * (SLOT_W + SLOT_GAP),
            y = TOP_PAD,
            w = SLOT_W,
            h = SLOT_H,
        }
    end
    return positions
end

--- Equip a gwang into the first available slot.
-- Returns true on success, false if full.
function M.equip(gs, gwang_data)
    for i = 1, M.MAX_SLOTS do
        if gs.slots[i].gwang == nil then
            gs.slots[i].gwang = {
                kind     = gwang_data.kind or "gwang",
                identity = gwang_data.identity,
            }
            return true
        end
    end
    return false
end

--- Check if a slot is empty.
function M.is_empty(gs, idx)
    return gs.slots[idx].gwang == nil
end

--- Sync slot state from a run-state gwang list.
function M.sync_from_run(gs, run_gwang)
    for i = 1, M.MAX_SLOTS do
        if run_gwang[i] then
            gs.slots[i].gwang = {
                kind     = run_gwang[i].kind or "gwang",
                identity = run_gwang[i].identity,
            }
        else
            gs.slots[i].gwang = nil
        end
    end
end

--- Return display text for an equipped gwang: ★ name effect
function M.display_text(gwang_data)
    local info = GWANG_INFO[gwang_data.identity]
    if not info then
        return "★ ?"
    end
    return "★ " .. info.name .. " " .. info.effect
end

--- Draw the slot bar (requires love.graphics).
function M.draw(gs)
    if not love or not love.graphics then return end
    local positions = M.slot_positions()
    local font = love.graphics.getFont()

    for i = 1, M.MAX_SLOTS do
        local p = positions[i]
        local slot = gs.slots[i]

        if slot.gwang then
            -- Filled slot: optional catalog art, with the star as fallback.
            love.graphics.setColor(0.15, 0.12, 0.25, 1)
            love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 2, 2)
            local has_art = gwang_art.draw(slot.gwang, p)
            love.graphics.setColor(1, 0.85, 0.2, 1)
            love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 2, 2)

            if not has_art then
                local sym = "★"
                local tw = font:getWidth(sym)
                local th = font:getHeight()
                love.graphics.setColor(1, 0.85, 0.2, 1)
                love.graphics.print(sym, p.x + (p.w - tw) / 2, p.y + (p.h - th) / 2)
            end
        else
            -- Empty slot: dashed border
            love.graphics.setColor(0.4, 0.4, 0.4, 0.6)
            -- Simulate dashed border with short line segments
            local dash = 3
            local gap  = 2
            -- Top and bottom edges
            for edge_y_offset = 0, p.h, p.h do
                local ey = p.y + edge_y_offset
                local cx = p.x
                while cx < p.x + p.w do
                    local seg_end = math.min(cx + dash, p.x + p.w)
                    love.graphics.line(cx, ey, seg_end, ey)
                    cx = seg_end + gap
                end
            end
            -- Left and right edges
            for edge_x_offset = 0, p.w, p.w do
                local ex = p.x + edge_x_offset
                local cy = p.y
                while cy < p.y + p.h do
                    local seg_end = math.min(cy + dash, p.y + p.h)
                    love.graphics.line(ex, cy, ex, seg_end)
                    cy = seg_end + gap
                end
            end
        end
    end
end

return M
