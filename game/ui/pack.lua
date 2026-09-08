-- game/ui/pack.lua
-- Modal booster-pack choice overlay. Layout and hit-testing share a pure view.

local M = {}

local VIEWPORT_W = 320
local PANEL = { x = 28, y = 14, w = 264, h = 152 }
local CHOICE_Y = 50
local CHOICE_H = 48
local CHOICE_W = 58
local CHOICE_GAP = 12
local SKIP = { x = 130, y = 136, w = 60, h = 18 }

local function contains(bounds, x, y)
    return x >= bounds.x and x < bounds.x + bounds.w
        and y >= bounds.y and y < bounds.y + bounds.h
end

--- Build the render model used by draw and hit_test.
function M.view(pending)
    assert(type(pending) == "table", "pack UI requires a pending pack")
    local count = #pending.choices
    local total_w = count * CHOICE_W + math.max(0, count - 1) * CHOICE_GAP
    local start_x = math.floor((VIEWPORT_W - total_w) / 2)
    local choices = {}
    for i, choice in ipairs(pending.choices) do
        choices[i] = {
            index = i,
            id = choice.id,
            name = choice.name,
            effect = choice.effect,
            bounds = {
                x = start_x + (i - 1) * (CHOICE_W + CHOICE_GAP),
                y = CHOICE_Y,
                w = CHOICE_W,
                h = CHOICE_H,
            },
        }
    end
    return {
        panel_bounds = PANEL,
        title = pending.name or "카드 팩",
        instruction = tostring(pending.choose or 1) .. "장 선택",
        choices = choices,
        skip_bounds = SKIP,
        skip_label = "건너뛰기",
    }
end

--- Return a choice index, "skip", or nil.
function M.hit_test(pending, x, y)
    if not pending then return nil end
    local view = M.view(pending)
    for i, choice in ipairs(view.choices) do
        if contains(choice.bounds, x, y) then return i end
    end
    if contains(view.skip_bounds, x, y) then return "skip" end
    return nil
end

local function centered(text, bounds, y, scale)
    local font = love.graphics.getFont()
    scale = scale or 1
    local width = font:getWidth(text) * scale
    love.graphics.print(text, bounds.x + math.floor((bounds.w - width) / 2), y,
        0, scale, scale)
end

--- Draw above the shop; the play scene routes input modally while it is open.
function M.draw(pending)
    if not pending or not love or not love.graphics then return end
    local view = M.view(pending)
    local panel = view.panel_bounds

    love.graphics.setColor(0.015, 0.02, 0.05, 0.96)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 5, 5)
    love.graphics.setColor(0.95, 0.65, 0.25, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.w, panel.h, 5, 5)
    centered(view.title, panel, panel.y + 7)
    love.graphics.setColor(0.75, 0.82, 0.9, 1)
    centered(view.instruction, panel, panel.y + 22)

    for _, choice in ipairs(view.choices) do
        local bounds = choice.bounds
        love.graphics.setColor(0.24, 0.17, 0.38, 1)
        love.graphics.rectangle("fill", bounds.x, bounds.y, bounds.w, bounds.h, 3, 3)
        love.graphics.setColor(0.82, 0.55, 1, 1)
        love.graphics.rectangle("line", bounds.x, bounds.y, bounds.w, bounds.h, 3, 3)
        love.graphics.setColor(1, 1, 1, 1)
        local font = love.graphics.getFont()
        local name_scale = math.min(1, (bounds.w - 4) / math.max(1, font:getWidth(choice.name)))
        centered(choice.name, bounds, bounds.y + 8, name_scale)
        love.graphics.setColor(0.75, 0.82, 0.9, 1)
        local effect = choice.effect or ""
        local effect_scale = math.min(0.8,
            (bounds.w - 4) / math.max(1, font:getWidth(effect)))
        centered(effect, bounds, bounds.y + 28, effect_scale)
    end

    love.graphics.setColor(0.45, 0.22, 0.12, 1)
    love.graphics.rectangle("fill", SKIP.x, SKIP.y, SKIP.w, SKIP.h, 3, 3)
    love.graphics.setColor(1, 0.75, 0.35, 1)
    love.graphics.rectangle("line", SKIP.x, SKIP.y, SKIP.w, SKIP.h, 3, 3)
    centered(view.skip_label, SKIP, SKIP.y + 3)
    love.graphics.setColor(1, 1, 1, 1)
end

return M
