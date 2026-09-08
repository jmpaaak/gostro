-- game/ui/blind_select.lua
-- Blind selection screen: 3 cards (small/big/boss), target score, reward/penalty.

local terms = require("game.terms")
local blind_card_art = require("game.ui.blind_card_art")

local M = {}

local VIEWPORT_W = 320
local VIEWPORT_H = 180

-- Card layout: 3 cards centred
local CARD_W = 50
local CARD_H = 70
local CARD_GAP = 14
local CARD_Y = 36

local BLIND_REWARDS = {
    small = "+$3",
    big   = "+$5",
    boss  = "+$8",
}

local BLIND_COLOURS = {
    small = { 0.2, 0.5, 0.8 },
    big   = { 0.8, 0.6, 0.1 },
    boss  = { 0.8, 0.15, 0.15 },
}

--- Display name for a blind kind.
function M.display_name(kind)
    return terms.blind_name(kind)
end

--- Return 3 card display positions (centred).
function M.card_positions()
    local total_w = 3 * CARD_W + 2 * CARD_GAP
    local start_x = math.floor((VIEWPORT_W - total_w) / 2)
    local positions = {}
    for i = 1, 3 do
        positions[i] = {
            x = start_x + (i - 1) * (CARD_W + CARD_GAP),
            y = CARD_Y,
            w = CARD_W,
            h = CARD_H,
        }
    end
    return positions
end

--- Create display state from the gameplay-owned blind projection.
function M.new(model)
    if type(model) ~= "table" or type(model.blinds) ~= "table" then
        error("blind-select requires a blind flow model")
    end
    if not BLIND_REWARDS[model.current] then
        error("unknown current blind: " .. tostring(model.current))
    end
    local blinds = {}
    for i, projected in ipairs(model.blinds) do
        blinds[i] = {
            kind = projected.kind,
            target = projected.target,
            reward = BLIND_REWARDS[projected.kind],
            available = projected.playable == true,
            status = projected.status,
            boss = projected.boss,
        }
    end
    if #blinds ~= 3 then error("blind-select requires three blind projections") end
    return {
        ante     = model.ante,
        current  = model.current,
        blinds   = blinds,
        selected = nil,
    }
end

--- Select a blind by index (1-3). Sets state.selected to the blind kind.
function M.select_blind(s, idx)
    if idx < 1 or idx > 3 then
        error("blind index out of range: " .. tostring(idx))
    end
    if not s.blinds[idx].available then
        error("only the current blind can be selected")
    end
    s.selected = s.blinds[idx].kind
end

--- Hit-test: returns card index (1-3) or nil.
function M.hit_test(s, px, py)
    local positions = M.card_positions()
    for i = 1, 3 do
        local p = positions[i]
        if s.blinds[i].available
           and px >= p.x and px < p.x + p.w
           and py >= p.y and py < p.y + p.h then
            return i
        end
    end
    return nil
end

--- Draw the blind selection screen (requires love.graphics).
function M.draw(s)
    if not love or not love.graphics then return end
    local font = love.graphics.getFont()
    local fh = font:getHeight()
    local positions = M.card_positions()

    -- Title
    love.graphics.setColor(1, 0.9, 0.3, 1)
    local title = terms.ante(s.ante) .. " — " .. terms.domain.blind .. " 선택"
    love.graphics.print(title,
        math.floor(VIEWPORT_W / 2 - font:getWidth(title) / 2), 8)

    -- Cards
    for i = 1, 3 do
        local p = positions[i]
        local b = s.blinds[i]
        local col = BLIND_COLOURS[b.kind] or { 0.4, 0.4, 0.4 }
        local is_sel = (s.selected == b.kind)

        -- Card background
        local available = b.available
        local card_alpha = is_sel and 1 or (available and 0.82 or 0.38)
        local has_art = blind_card_art.draw(b.kind, p.x, p.y, p.w, p.h, card_alpha)
        if not has_art then
            love.graphics.setColor(col[1], col[2], col[3], card_alpha)
            love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 4, 4)
        end

        -- Selection border highlight
        if is_sel then
            love.graphics.setColor(1, 1, 0.4, 1)
            love.graphics.setLineWidth(2)
        else
            love.graphics.setColor(1, 1, 1, available and 0.5 or 0.2)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 4, 4)
        love.graphics.setLineWidth(1)

        -- Blind name
        love.graphics.setColor(1, 1, 1, 1)
        local name = terms.blind_name(b.kind)
        local nw = font:getWidth(name)
        love.graphics.print(name,
            p.x + math.floor((p.w - nw) / 2), p.y + 6)

        local status = available and "현재" or "순서 대기"
        love.graphics.setColor(1, 1, 1, available and 0.9 or 0.45)
        local sw = font:getWidth(status)
        love.graphics.print(status, p.x + math.floor((p.w - sw) / 2), p.y + 20)

        -- Target score
        local target_txt = tostring(b.target)
        local tw = font:getWidth(target_txt)
        love.graphics.setColor(1, 0.95, 0.6, 1)
        love.graphics.print(target_txt,
            p.x + math.floor((p.w - tw) / 2),
            p.y + math.floor(p.h / 2) - math.floor(fh / 2))

        -- Reward/penalty at bottom
        love.graphics.setColor(0.3, 1, 0.4, 1)
        local rw = font:getWidth(b.reward)
        love.graphics.print(b.reward,
            p.x + math.floor((p.w - rw) / 2), p.y + p.h - fh - 4)
    end

    -- Instruction
    love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
    local hint = "카드를 탭하여 " .. terms.domain.blind .. " 선택"
    love.graphics.print(hint,
        math.floor(VIEWPORT_W / 2 - font:getWidth(hint) / 2),
        CARD_Y + CARD_H + 12)

    -- Reset colour
    love.graphics.setColor(1, 1, 1, 1)
end

return M
