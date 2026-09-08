-- game/ui/tarot_target.lua
-- Headless-safe tarot option and single-card target selection. This module
-- builds a use request but deliberately never calls game.tarots.use.

local M = {}

local VIEWPORT_W = 320
local PANEL = { x = 12, y = 56, w = 296, h = 118 }
local CANCEL = { x = 270, y = 61, w = 30, h = 14 }
local OPTION_Y = 82
local OPTION_H = 18
local OPTION_GAP = 4
local TARGET_Y = 126
local TARGET_W = 24
local TARGET_H = 36
local TARGET_GAP = 6

local EFFECTS = {
    convert = {
        title = "패 변환",
        instruction = "종류를 고른 뒤 대상 패를 선택",
        option_key = "kind",
        options = {
            { value = "hongdan", label = "홍단" },
            { value = "cheongdan", label = "청단" },
            { value = "chodan", label = "초단" },
            { value = "godori", label = "고도리" },
            { value = "pi", label = "피" },
        },
    },
    destroy = {
        title = "패 파괴",
        instruction = "파괴할 패를 선택",
        options = {},
    },
    enhance = {
        title = "효과 부여",
        instruction = "효과를 고른 뒤 대상 패를 선택",
        option_key = "effect",
        options = {
            { value = "foil", label = "포일" },
            { value = "hologram", label = "홀로그램" },
            { value = "polychrome", label = "폴리크롬" },
        },
    },
    copy = {
        title = "패 복제",
        instruction = "복제할 패를 선택",
        options = {},
    },
}

local KIND_LABELS = {
    hongdan = "홍단",
    cheongdan = "청단",
    chodan = "초단",
    godori = "고도리",
    pi = "피",
}

local function contains(bounds, x, y)
    return type(x) == "number" and type(y) == "number"
        and x >= bounds.x and x < bounds.x + bounds.w
        and y >= bounds.y and y < bounds.y + bounds.h
end

local function definition(flow)
    local def = EFFECTS[flow and flow.effect]
    if not def then
        error("unknown tarot target effect: " .. tostring(flow and flow.effect))
    end
    return def
end

local function option_is_valid(def, value)
    for _, option in ipairs(def.options) do
        if option.value == value then return true end
    end
    return false
end

--- Start selection for one occupied consumable slot.
function M.new(slot, tarot)
    assert(type(slot) == "number" and slot >= 1 and slot % 1 == 0,
        "tarot target requires a positive slot")
    assert(type(tarot) == "table", "tarot target requires a tarot card")
    if not EFFECTS[tarot.effect] then
        error("unknown tarot target effect: " .. tostring(tarot.effect))
    end
    return {
        slot = slot,
        tarot_id = tarot.id,
        tarot_name = tarot.name,
        effect = tarot.effect,
        option = nil,
        target_index = nil,
        cancelled = false,
    }
end

--- Build all visible labels and the shared hit bounds.
function M.view(flow, cards)
    assert(type(flow) == "table", "tarot target UI requires flow state")
    assert(type(cards) == "table", "tarot target UI requires target cards")
    local def = definition(flow)
    local options = {}
    local option_count = #def.options
    if option_count > 0 then
        local available_w = PANEL.w - 28
        local option_w = math.floor((available_w - (option_count - 1) * OPTION_GAP)
            / option_count)
        local total_w = option_count * option_w + (option_count - 1) * OPTION_GAP
        local start_x = math.floor((VIEWPORT_W - total_w) / 2)
        for i, source in ipairs(def.options) do
            options[i] = {
                value = source.value,
                label = source.label,
                selected = flow.option == source.value,
                bounds = {
                    x = start_x + (i - 1) * (option_w + OPTION_GAP),
                    y = OPTION_Y,
                    w = option_w,
                    h = OPTION_H,
                },
            }
        end
    end

    local target_count = #cards
    local total_target_w = target_count * TARGET_W
        + math.max(0, target_count - 1) * TARGET_GAP
    local target_x = math.floor((VIEWPORT_W - total_target_w) / 2)
    local targets = {}
    for i, card in ipairs(cards) do
        targets[i] = {
            index = i,
            card = card,
            label = KIND_LABELS[card.kind] or tostring(card.kind or "?"),
            selected = flow.target_index == i,
            bounds = {
                x = target_x + (i - 1) * (TARGET_W + TARGET_GAP),
                y = TARGET_Y,
                w = TARGET_W,
                h = TARGET_H,
            },
        }
    end

    local can_select_target = option_count == 0
        or option_is_valid(def, flow.option)
    return {
        panel_bounds = PANEL,
        cancel_bounds = CANCEL,
        cancel_label = "취소",
        title = flow.tarot_name and (flow.tarot_name .. " · " .. def.title) or def.title,
        instruction = def.instruction,
        options = options,
        targets = targets,
        can_select_target = can_select_target,
        ready = not flow.cancelled and can_select_target
            and cards[flow.target_index] ~= nil,
    }
end

--- Return a structured option/target/cancel hit, or nil.
function M.hit_test(flow, cards, x, y)
    if flow.cancelled then return nil end
    local view = M.view(flow, cards)
    if contains(view.cancel_bounds, x, y) then
        return { kind = "cancel" }
    end
    for _, option in ipairs(view.options) do
        if contains(option.bounds, x, y) then
            return { kind = "option", value = option.value }
        end
    end
    if view.can_select_target then
        -- Reverse order keeps later cards on top if layouts overlap later.
        for i = #view.targets, 1, -1 do
            local target = view.targets[i]
            if contains(target.bounds, x, y) then
                return { kind = "target", index = target.index }
            end
        end
    end
    return nil
end

--- Apply one pointer action to UI state. Returns "option", "target", or
-- "cancel" so a future scene adapter can consume the press modally.
function M.activate(flow, cards, x, y)
    local hit = M.hit_test(flow, cards, x, y)
    if not hit then return nil end
    if hit.kind == "cancel" then
        flow.cancelled = true
        flow.option = nil
        flow.target_index = nil
    elseif hit.kind == "option" then
        if flow.option == hit.value then
            flow.option = nil
        else
            flow.option = hit.value
        end
        -- A changed option requires an explicit target confirmation.
        flow.target_index = nil
    elseif hit.kind == "target" then
        if flow.target_index == hit.index then
            flow.target_index = nil
        else
            flow.target_index = hit.index
        end
    end
    return hit.kind
end

--- Produce arguments for tarots.use only when the selection is complete.
-- The returned table is data only; execution belongs to a later scene slice.
function M.request(flow, cards)
    local view = M.view(flow, cards)
    if not view.ready then return nil end
    local def = definition(flow)
    local opts = nil
    if def.option_key then
        opts = { [def.option_key] = flow.option }
    end
    return { slot = flow.slot, index = flow.target_index, opts = opts }
end

local function centered(text, bounds, y, scale)
    local font = love.graphics.getFont()
    scale = scale or 1
    local width = font:getWidth(text) * scale
    love.graphics.print(text, bounds.x + math.floor((bounds.w - width) / 2), y,
        0, scale, scale)
end

function M.draw(flow, cards)
    if not flow or not love or not love.graphics then return end
    local view = M.view(flow, cards)
    local panel = view.panel_bounds
    love.graphics.setColor(0.02, 0.025, 0.06, 0.96)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 5, 5)
    love.graphics.setColor(0.72, 0.45, 0.92, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.w, panel.h, 5, 5)
    love.graphics.setColor(1, 0.82, 0.35, 1)
    centered(view.title, panel, panel.y + 5, 0.9)
    love.graphics.setColor(0.72, 0.78, 0.88, 1)
    centered(view.instruction, panel, panel.y + 19, 0.72)

    for _, option in ipairs(view.options) do
        local b = option.bounds
        love.graphics.setColor(option.selected and 0.48 or 0.20,
            option.selected and 0.30 or 0.15, 0.55, 1)
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 3, 3)
        love.graphics.setColor(option.selected and 1 or 0.72, 0.72, 1, 1)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 3, 3)
        centered(option.label, b, b.y + 4, 0.7)
    end

    for _, target in ipairs(view.targets) do
        local b = target.bounds
        local enabled = view.can_select_target
        love.graphics.setColor(enabled and 0.76 or 0.20,
            enabled and 0.71 or 0.22, enabled and 0.53 or 0.25, 1)
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 2, 2)
        love.graphics.setColor(target.selected and 1 or 0.42,
            target.selected and 0.75 or 0.44, target.selected and 0.25 or 0.48, 1)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 2, 2)
        love.graphics.setColor(enabled and 0.12 or 0.45, 0.12, 0.14, 1)
        centered(target.label, b, b.y + 13, 0.55)
    end

    love.graphics.setColor(0.34, 0.16, 0.16, 1)
    love.graphics.rectangle("fill", CANCEL.x, CANCEL.y, CANCEL.w, CANCEL.h, 2, 2)
    love.graphics.setColor(1, 0.72, 0.62, 1)
    centered(view.cancel_label, CANCEL, CANCEL.y + 3, 0.62)
    love.graphics.setColor(1, 1, 1, 1)
end

return M