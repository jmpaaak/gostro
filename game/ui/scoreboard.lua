-- game/ui/scoreboard.lua
-- Scoreboard UI: chips × mult = total, progress bar, popup animation.

local panel_art = require("game.ui.panel_art")
local score_icon_art = require("game.ui.score_icon_art")

local M = {}

local VIEWPORT_W = 960
local VIEWPORT_H = 540
local POPUP_DURATION = 1.5  -- seconds
local BOX = { x = 12, y = 112, w = 300, h = 168 }

--- Create a new scoreboard state.
function M.new()
    return {
        chips = 0,
        mult = 1,
        displayed_score = 0,
        target = 0,
        preview = nil,  -- { chips, mult, score, yaku_label }
        popup = nil,  -- { value, timer, text }
        countup = nil, -- { from, to, timer, duration }
        display_chips = 0,
        display_mult = 1,
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
    sb.display_chips = 0
    sb.display_mult = 1
    local hand_score = chips * mult
    local from = sb.displayed_score
    sb.countup = {
        from = from,
        to = from + hand_score,
        timer = 0,
        duration = 0.8,
        waiting = true,
    }
    sb.popup = nil
end

function M.sync_anim(sb, anim)
    if not anim then return end
    if anim.phase == "cards" then
        sb.display_chips = anim.chips_shown or 0
        sb.display_mult = 1
    elseif anim.phase == "mult" then
        sb.display_chips = sb.chips
        sb.display_mult = sb.mult
    elseif anim.phase == "total" or anim.phase == "done" then
        sb.display_chips = sb.chips
        sb.display_mult = sb.mult
        if sb.countup and sb.countup.waiting then
            sb.countup.waiting = false
        end
        if anim.phase == "done" and not sb.popup then
            sb.popup = {
                value = sb.chips * sb.mult,
                timer = POPUP_DURATION,
                text = M.format_score_text(sb.chips, sb.mult),
            }
        end
    end
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
    sb.preview = nil
    sb.popup = nil
    sb.countup = nil
    sb.display_chips = 0
    sb.display_mult = 1
end

function M.layout()
    return { x = BOX.x, y = BOX.y, w = BOX.w, h = BOX.h }
end

function M.set_preview(sb, preview)
    sb.preview = preview
end

--- Tick popup timer.
function M.update(sb, dt)
    if sb.popup then
        sb.popup.timer = sb.popup.timer - dt
        if sb.popup.timer <= 0 then
            sb.popup = nil
        end
    end
    if sb.countup and not sb.countup.waiting then
        sb.countup.timer = sb.countup.timer + dt
        local ratio = math.min(1, sb.countup.timer / sb.countup.duration)
        local eased = 1 - (1 - ratio) * (1 - ratio)
        sb.displayed_score = math.floor(sb.countup.from + (sb.countup.to - sb.countup.from) * eased)
        if ratio >= 1 then
            sb.displayed_score = sb.countup.to
            sb.countup = nil
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

    -- Score area: left side, below gwang slots
    local box_x = BOX.x
    local box_y = BOX.y
    local box_w = BOX.w
    local box_h = BOX.h

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
    local chips_txt = tostring(sb.display_chips or sb.chips)
    love.graphics.print(chips_txt, chips_x, box_y + 3)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    local times_x = chips_x + font:getWidth(chips_txt)
    love.graphics.print(" × ", times_x, box_y + 3)
    love.graphics.setColor(1, 0.5, 0.3, 1)
    local mult_txt = tostring(sb.display_mult or sb.mult)
    local mult_x = times_x + font:getWidth(" × ")
    love.graphics.print(mult_txt, mult_x, box_y + 3)
    
    local mult_icon_x = mult_x + font:getWidth(mult_txt) + 2
    score_icon_art.draw_mult(mult_icon_x, box_y + 2, 12)

    -- Total score vs blind target
    love.graphics.setColor(1, 1, 1, 1)
    local score_str = tostring(sb.displayed_score)
    love.graphics.print(score_str, box_x + 4, box_y + 3 + fh + 2)

    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("/ " .. tostring(sb.target),
        box_x + 4 + font:getWidth(score_str .. " "), box_y + 3 + fh + 2)

    local cursor_y = box_y + 3 + (fh + 2) * 2

    -- Selection preview: yaku name + chips x mult
    if sb.preview then
        love.graphics.setColor(0.98, 0.86, 0.42, 1)
        love.graphics.print(sb.preview.yaku_label or "바닥", box_x + 4, cursor_y)
        cursor_y = cursor_y + fh + 2
        love.graphics.setColor(0.6, 0.85, 1, 1)
        local preview_txt = tostring(sb.preview.chips) .. " × " .. tostring(sb.preview.mult)
        love.graphics.print(preview_txt, box_x + 4, cursor_y)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("= " .. tostring(sb.preview.score),
            box_x + 4 + font:getWidth(preview_txt .. " "), cursor_y)
        cursor_y = cursor_y + fh + 2
    else
        love.graphics.setColor(0.72, 0.76, 0.82, 1)
        love.graphics.print("패를 고르세요", box_x + 4, cursor_y)
        cursor_y = cursor_y + fh + 2
    end

    -- Progress bar
    local bar_x = box_x + 4
    local bar_y = cursor_y + 4
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
