-- game/ui/consumables.lua
-- Headless-safe tarot inventory layout and selection. Tarot effects remain in
-- game/tarots.lua; this module owns only presentation and pointer hit-testing.

local tarots = require("game.tarots")

local M = {}

local VIEWPORT_W = 960
local RIGHT_PAD = 12
local SLOT_Y = 112
local SLOT_W = 126
local SLOT_H = 84
local SLOT_GAP = 9

local EFFECT_LABELS = {
    convert = "패 변환",
    destroy = "패 파괴",
    enhance = "효과 부여",
    copy = "패 복제",
}

local function contains(bounds, x, y)
    return x >= bounds.x and x < bounds.x + bounds.w
        and y >= bounds.y and y < bounds.y + bounds.h
end

local function held_tarots(state)
    if type(state) ~= "table" or type(state.tarots) ~= "table" then
        return {}
    end
    return state.tarots
end

--- Build the inventory render model from run state.
function M.view(state, selected_slot)
    assert(type(state) == "table", "consumables UI requires run state")
    local capacity = tarots.max_slots(state)
    local cards = held_tarots(state)
    if not cards[selected_slot] then selected_slot = nil end

    local total_w = capacity * SLOT_W + math.max(0, capacity - 1) * SLOT_GAP
    local start_x = VIEWPORT_W - RIGHT_PAD - total_w
    local slots = {}
    for i = 1, capacity do
        local card = cards[i]
        slots[i] = {
            index = i,
            card = card,
            name = card and card.name or "비어 있음",
            effect = card and (EFFECT_LABELS[card.effect] or card.effect) or nil,
            selected = selected_slot == i,
            bounds = {
                x = start_x + (i - 1) * (SLOT_W + SLOT_GAP),
                y = SLOT_Y,
                w = SLOT_W,
                h = SLOT_H,
            },
        }
    end

    return {
        label = "소모품",
        capacity = capacity,
        selected_slot = selected_slot,
        slots = slots,
    }
end

--- Return only occupied slot indices; empty inventory space is inert.
function M.hit_test(state, x, y)
    local view = M.view(state)
    for _, slot in ipairs(view.slots) do
        if slot.card and contains(slot.bounds, x, y) then
            return slot.index
        end
    end
    return nil
end

function M.set_hover_at(state, x, y)
    return M.hit_test(state, x, y)
end

--- Resolve a pointer press into a selected slot. Pressing it again deselects it.
function M.select(state, selected_slot, x, y)
    local hit = M.hit_test(state, x, y)
    if hit == selected_slot then return nil end
    return hit or selected_slot
end

--- Route an occupied-slot press while keeping scene glue free of UI rules.
function M.route_press(scene, x, y)
    if not M.hit_test(scene.run_state, x, y) then return false end
    scene.selected_consumable = M.select(
        scene.run_state, scene.selected_consumable, x, y)
    return true
end

local function fit_scale(font, text, width, maximum)
    return math.min(maximum or 1, width / math.max(1, font:getWidth(text)))
end

function M.draw(state, selected_slot)
    if not love or not love.graphics then return end
    local view = M.view(state, selected_slot)
    local font = love.graphics.getFont()
    local first = view.slots[1]

    love.graphics.setColor(0.72, 0.76, 0.86, 1)
    love.graphics.print(view.label, first.bounds.x, SLOT_Y - 12)

    for _, slot in ipairs(view.slots) do
        local b = slot.bounds
        if slot.card then
            love.graphics.setColor(0.20, 0.12, 0.30, 1)
        else
            love.graphics.setColor(0.08, 0.09, 0.13, 0.8)
        end
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 2, 2)
        if slot.selected then
            love.graphics.setColor(1, 0.78, 0.25, 1)
        elseif slot.card then
            love.graphics.setColor(0.72, 0.45, 0.92, 1)
        else
            love.graphics.setColor(0.32, 0.34, 0.40, 1)
        end
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 2, 2)

        local name_scale = fit_scale(font, slot.name, b.w - 4, 0.75)
        love.graphics.setColor(slot.card and 1 or 0.48, slot.card and 1 or 0.50,
            slot.card and 1 or 0.56, 1)
        love.graphics.print(slot.name, b.x + 2, b.y + 4, 0, name_scale, name_scale)
        if slot.effect then
            local effect_scale = fit_scale(font, slot.effect, b.w - 4, 0.62)
            love.graphics.setColor(0.75, 0.66, 0.95, 1)
            love.graphics.print(slot.effect, b.x + 2, b.y + 16, 0,
                effect_scale, effect_scale)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return M
