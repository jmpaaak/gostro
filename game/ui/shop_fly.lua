-- Shop purchase fly: a bought offer travels from its stall to its destination.

local shop_ui = require("game.ui.shop")
local gwang_slots = require("game.ui.gwang_slots")
local consumables_ui = require("game.ui.consumables")
local scoreboard = require("game.ui.scoreboard")

local M = {}

M.DURATION = 0.35

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function ease_out(t)
    local u = 1 - t
    return 1 - u * u
end

local function rect_center(rect)
    return rect.x + rect.w / 2, rect.y + rect.h / 2
end

function M.destination(kind, run_state, gwang_ui)
    if kind == "gwang" then
        local positions = gwang_slots.slot_positions()
        local count = 0
        if run_state and type(run_state.gwang) == "table" then
            count = #run_state.gwang
        elseif gwang_ui then
            for i = 1, gwang_slots.MAX_SLOTS do
                if gwang_ui.slots[i].gwang then count = count + 1 end
            end
        end
        local idx = math.max(1, math.min(gwang_slots.MAX_SLOTS, count))
        return positions[idx]
    end
    if kind == "tarot" or kind == "pack" then
        local view = consumables_ui.view(run_state or {})
        for _, slot in ipairs(view.slots) do
            if not slot.card then return slot.bounds end
        end
        return view.slots[#view.slots] and view.slots[#view.slots].bounds
    end
    return scoreboard.layout()
end

function M.start(shop, idx, dest)
    local positions = shop_ui.card_positions(shop)
    local from = positions[idx]
    if not from or not dest then return nil end
    local sx, sy = rect_center(from)
    local dx, dy = rect_center(dest)
    shop.fly = {
        kind = (shop.slots and shop.slots[idx] and shop.slots[idx].kind)
            or (shop.cards and shop.cards[idx] and shop.cards[idx].kind),
        from_x = sx,
        from_y = sy,
        to_x = dx,
        to_y = dy,
        w = from.w,
        h = from.h,
        timer = 0,
        duration = M.DURATION,
        x = sx,
        y = sy,
        scale = 1,
    }
    return shop.fly
end

function M.update(shop, dt)
    local fly = shop and shop.fly
    if not fly then return end
    fly.timer = fly.timer + dt
    local t = math.min(1, fly.timer / fly.duration)
    local e = ease_out(t)
    fly.x = lerp(fly.from_x, fly.to_x, e)
    fly.y = lerp(fly.from_y, fly.to_y, e)
    fly.scale = lerp(1, 0.45, e)
    if t >= 1 then
        shop.fly = nil
    end
end

function M.draw(shop)
    local fly = shop and shop.fly
    if not fly or not love or not love.graphics then return end
    local w, h = fly.w * fly.scale, fly.h * fly.scale
    love.graphics.setColor(1, 0.92, 0.35, 0.9)
    love.graphics.rectangle("fill", fly.x - w / 2, fly.y - h / 2, w, h, 4, 4)
    love.graphics.setColor(1, 1, 1, 1)
end

return M
