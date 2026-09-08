-- Round selection screen: opening/main/final cards, target score, and reward.

local terms = require("game.terms")

local M = {}

local VIEWPORT_W = 320
local VIEWPORT_H = 180

-- Card layout: 3 cards centred
local CARD_W = 50
local CARD_H = 70
local CARD_GAP = 14
local CARD_Y = 36

local ROUND_REWARDS = {
    small = "+$3",
    big   = "+$5",
    boss  = "+$8",
}

local ROUND_COLOURS = {
    small = { 0.2, 0.5, 0.8 },
    big   = { 0.8, 0.6, 0.1 },
    boss  = { 0.8, 0.15, 0.15 },
}

--- Display name for a round kind. Kind ids remain save-compatible.
function M.display_name(kind)
    return terms.round_name(kind)
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

--- Create display state from the gameplay-owned round projection.
function M.new(model)
    local projected_rounds = type(model) == "table" and (model.rounds or model.blinds)
    if type(projected_rounds) ~= "table" then
        error("round-select requires a round flow model")
    end
    local current_round = model.current_round or model.current
    if current_round ~= "small" and current_round ~= "big" and current_round ~= "boss" then
        error("unknown current round: " .. tostring(current_round))
    end
    local rounds = {}
    for i, projected in ipairs(projected_rounds) do
        local skip_plaque = projected.skip_plaque or projected.skip_tag
        rounds[i] = {
            kind = projected.kind,
            target = projected.target,
            reward = ROUND_REWARDS[projected.kind],
            available = projected.playable == true,
            status = projected.status,
            boss = projected.boss,
            skippable = projected.skippable == true,
            skip_plaque = skip_plaque,
            skip_tag = skip_plaque, -- legacy UI-model alias
        }
    end
    if #rounds ~= 3 then error("round-select requires three round projections") end
    local go = model.go or model.ante
    return {
        go       = go,
        current_round = current_round,
        rounds   = rounds,
        ante     = go, -- legacy projection aliases
        current  = current_round,
        blinds   = rounds,
        selected = nil,
    }
end

--- Select a round by index (1-3). Kind ids remain small/big/boss.
function M.select_round(s, idx)
    if idx < 1 or idx > 3 then
        error("round index out of range: " .. tostring(idx))
    end
    if not s.rounds[idx].available then
        error("only the current round can be selected")
    end
    s.selected = s.rounds[idx].kind
end

M.select_blind = M.select_round

--- Hit-test: returns card index (1-3) or nil.
function M.hit_test(s, px, py)
    local positions = M.card_positions()
    for i = 1, 3 do
        local p = positions[i]
        if s.rounds[i].available
           and px >= p.x and px < p.x + p.w
           and py >= p.y and py < p.y + p.h then
            return i
        end
    end
    return nil
end

--- Draw the round selection screen (requires love.graphics).
function M.draw(s)
    if not love or not love.graphics then return end
    local font = love.graphics.getFont()
    local fh = font:getHeight()
    local positions = M.card_positions()

    -- Title
    love.graphics.setColor(1, 0.9, 0.3, 1)
    local title = terms.go_label(s.go or s.ante) .. " — 판 선택"
    love.graphics.print(title,
        math.floor(VIEWPORT_W / 2 - font:getWidth(title) / 2), 8)

    -- Cards
    for i = 1, 3 do
        local p = positions[i]
        local b = s.rounds[i]
        local col = ROUND_COLOURS[b.kind] or { 0.4, 0.4, 0.4 }
        local is_sel = (s.selected == b.kind)

        -- Card background
        local available = b.available
        love.graphics.setColor(col[1], col[2], col[3], is_sel and 1 or (available and 0.7 or 0.28))
        love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 4, 4)

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

        -- Round name
        love.graphics.setColor(1, 1, 1, 1)
        local name = terms.round_name(b.kind)
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
    local hint = "카드를 탭하여 판 선택"
    for _, round in ipairs(s.rounds) do
        if round.skippable and round.skip_plaque then
            hint = "건너뛰기 보상 · " .. round.skip_plaque.name
            break
        end
    end
    love.graphics.print(hint,
        math.floor(VIEWPORT_W / 2 - font:getWidth(hint) / 2),
        CARD_Y + CARD_H + 12)

    -- Reset colour
    love.graphics.setColor(1, 1, 1, 1)
end

return M
