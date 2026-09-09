-- game/ui/scoreboard.lua
-- Scoreboard UI: chips × mult = total, progress bar, popup animation.

local panel_art = require("game.ui.panel_art")
local score_icon_art = require("game.ui.score_icon_art")

local M = {}

local VIEWPORT_W = 960
local VIEWPORT_H = 540
local POPUP_DURATION = 1.5  -- seconds

--- Create a new scoreboard state.
function M.new()
    return {
        chips = 0,
        mult = 1,
        displayed_score = 0,
        target = 0,
        popup = nil,  -- { value, timer, text }
    }
end

--- Set blind target score.
function M.set_target(sb, target)
    sb.target = target
end

--- Record a hand result: chips × mult → adds to displayed_score, triggers popup.
function M.set_hand_result(sb, chips, mult)
    sb.chips = chips
    sb.mult = mult
    local hand_score = chips * mult
    sb.displayed_score = sb.displayed_score + hand_score
    sb.popup = {
        value = hand_score,
        timer = POPUP_DURATION,
        text = M.format_score_text(chips, mult),
    }
end

--- Progress ratio (0..1, clamped).
function M.progress_ratio(sb)
    if sb.target <= 0 then return 0 end
    local r = sb.displayed_score / sb.target
    if r > 1 then r = 1 end
    return r
end

--- Reset scoreboard between rounds.
function M.reset(sb)
    sb.chips = 0
    sb.mult = 1
    sb.displayed_score = 0
    sb.target = 0
    sb.popup = nil
end

--- Tick popup timer.
function M.update(sb, dt)
    if sb.popup then
        sb.popup.timer = sb.popup.timer - dt
        if sb.popup.timer <= 0 then
            sb.popup = nil
        end
    end
end

--- Format "chips × mult = score" text.
function M.format_score_text(chips, mult)
    return tostring(chips) .. " × " .. tostring(mult) .. " = " .. tostring(chips * mult)
end

--- Draw scoreboard (requires love.graphics).
function M.draw(sb)
    if not love or not love.graphics then return end
    local font = love.graphics.getFont()
    local fh = font:getHeight()

    -- Score area: right side, below gwang slots
    local box_x = VIEWPORT_W - 330
    local box_y = 72
    local box_w = 315
    local box_h = 150

    -- Background panel
    if not panel_art.draw("metal", { x = box_x, y = box_y, w = box_w, h = box_h }) then
        love.graphics.setColor(0.08, 0.06, 0.15, 0.85)
        love.graphics.rectangle("fill", box_x, box_y, box_w, box_h, 3, 3)
        love.graphics.setColor(0.3, 0.3, 0.5, 0.8)
        love.graphics.rectangle("line", box_x, box_y, box_w, box_h, 3, 3)
    end

    -- Chips × Mult line
    local chips_x = box_x + 4
    if score_icon_art.draw_chip(chips_x, box_y + 2, 12) then
        chips_x = chips_x + 14
    end
    love.graphics.setColor(0.6, 0.85, 1, 1)
    local chips_txt = tostring(sb.chips)
    love.graphics.print(chips_txt, chips_x, box_y + 3)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    local times_x = chips_x + font:getWidth(chips_txt)
    love.graphics.print(" × ", times_x, box_y + 3)
    love.graphics.setColor(1, 0.5, 0.3, 1)
    local mult_txt = tostring(sb.mult)
    local mult_x = times_x + font:getWidth(" × ")
    love.graphics.print(mult_txt, mult_x, box_y + 3)
    
    local mult_icon_x = mult_x + font:getWidth(mult_txt) + 2
    score_icon_art.draw_mult(mult_icon_x, box_y + 2, 12)

    -- Total score
    love.graphics.setColor(1, 1, 1, 1)
    local score_str = tostring(sb.displayed_score)
    love.graphics.print(score_str, box_x + 4, box_y + 3 + fh + 2)

    -- Target text
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("/ " .. tostring(sb.target),
        box_x + 4 + font:getWidth(score_str .. " "), box_y + 3 + fh + 2)

    -- Progress bar
    local bar_x = box_x + 4
    local bar_y = box_y + 3 + (fh + 2) * 2
    local bar_w = box_w - 8
    local bar_h = 6
    local ratio = M.progress_ratio(sb)

    -- Bar background
    love.graphics.setColor(0.15, 0.15, 0.25, 1)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h, 2, 2)

    -- Bar fill
    if ratio >= 1 then
        love.graphics.setColor(0.2, 1, 0.4, 1)
    else
        love.graphics.setColor(0.3, 0.7, 1, 1)
    end
    love.graphics.rectangle("fill", bar_x, bar_y,
        math.floor(bar_w * ratio), bar_h, 2, 2)

    -- Popup: Balatro-style chips×mult floating text
    if sb.popup then
        local alpha = math.min(1, sb.popup.timer / 0.3) -- fade out last 0.3s
        local rise = (POPUP_DURATION - sb.popup.timer) * 20 -- float upward
        local px = VIEWPORT_W / 2
        local py = VIEWPORT_H / 2 - 10 - rise

        -- Shadow
        love.graphics.setColor(0, 0, 0, alpha * 0.6)
        love.graphics.print(sb.popup.text,
            px - font:getWidth(sb.popup.text) / 2 + 1, py + 1)

        -- Main text: large, bright
        love.graphics.setColor(1, 0.95, 0.3, alpha)
        love.graphics.print(sb.popup.text,
            px - font:getWidth(sb.popup.text) / 2, py)

        -- Score value below
        local val_str = tostring(sb.popup.value)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(val_str,
            px - font:getWidth(val_str) / 2, py + fh + 2)
    end
end

return M
