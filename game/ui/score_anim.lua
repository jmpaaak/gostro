-- game/ui/score_anim.lua
-- Score animation module: Balatro-style per-card chip popup → mult apply → total countup.
-- Gwang joker glow effect when triggered.

local effect_art = require("game.ui.effect_art")

local gwang_slots = require("game.ui.gwang_slots")
local card = require("game.ui.card")

local M = {}

-- Timing constants (seconds)
M.CARD_DELAY    = 0.3   -- delay between each card chip popup
M.MULT_DURATION = 0.5   -- mult application phase duration
M.TOTAL_DURATION = 0.8  -- total countup phase duration
M.GLOW_DURATION = 2.0   -- gwang slot glow duration

local VIEWPORT_W = 960
local VIEWPORT_H = 540

--- Create a new score_anim state.
function M.new()
    return {
        phase = "idle",       -- idle | cards | mult | total | done
        card_popups = {},     -- { {kind, chips, x, y, alpha}, ... }
        card_index = 0,       -- current card being shown
        card_timer = 0,       -- timer for current card delay
        chips_shown = 0,      -- accumulated chips shown so far
        mult_timer = 0,       -- timer for mult phase
        total_timer = 0,      -- timer for total countup
        displayed_total = 0,  -- animated total value
        -- Data from start()
        base_chips = 0,
        base_mult = 1,
        bonus_chips = 0,
        bonus_mult = 0,
        final_chips = 0,
        final_mult = 1,
        total = 0,
        -- Gwang glow
        gwang_glows = {},     -- { {slot, identity, timer}, ... }
    }
end

--- Start a score animation sequence.
-- @param sa  score_anim state from new()
-- @param data table with fields:
--   cards: { {kind, chips}, ... }
--   base_chips, base_mult: raw evaluation
--   bonus_chips, bonus_mult: from gwang jokers
--   final_chips, final_mult: after bonuses
--   total: final score (chips × mult)
--   gwang_triggers: { {slot, identity}, ... }
function M.start(sa, data)
    sa.card_popups = {}
    for i, c in ipairs(data.cards) do
        sa.card_popups[i] = {
            kind = c.kind,
            chips = c.chips,
            x = c.x,
            y = c.y,
            anchor = c.anchor,
            alpha = 0,
            shown = false,
        }
    end
    sa.card_index = 1
    sa.card_timer = 0
    sa.chips_shown = 0

    sa.base_chips  = data.base_chips
    sa.base_mult   = data.base_mult
    sa.bonus_chips = data.bonus_chips
    sa.bonus_mult  = data.bonus_mult
    sa.final_chips = data.final_chips
    sa.final_mult  = data.final_mult
    sa.total       = data.total
    sa.displayed_total = 0

    sa.mult_timer  = 0
    sa.total_timer = 0

    -- Gwang glow setup
    sa.gwang_glows = {}
    for i, g in ipairs(data.gwang_triggers) do
        sa.gwang_glows[i] = {
            slot = g.slot,
            identity = g.identity,
            timer = M.GLOW_DURATION,
        }
    end

    sa.phase = "cards"
end

--- Tick the animation forward.
function M.update(sa, dt)
    -- Update gwang glows regardless of phase
    for _, g in ipairs(sa.gwang_glows) do
        g.timer = g.timer - dt
    end

    local remaining = dt

    if sa.phase == "cards" then
        -- Process cards one by one with CARD_DELAY between them
        while sa.phase == "cards" and remaining > 0 do
            local need = M.CARD_DELAY - sa.card_timer
            if remaining >= need then
                remaining = remaining - need
                sa.card_timer = 0
                -- Show current card popup
                if sa.card_index <= #sa.card_popups then
                    local popup = sa.card_popups[sa.card_index]
                    popup.shown = true
                    popup.alpha = 1
                    sa.chips_shown = sa.chips_shown + popup.chips
                    sa.card_index = sa.card_index + 1
                end
                -- Check if all cards shown
                if sa.card_index > #sa.card_popups then
                    sa.phase = "mult"
                    sa.mult_timer = 0
                end
            else
                sa.card_timer = sa.card_timer + remaining
                remaining = 0
                -- Fade in current popup
                if sa.card_index <= #sa.card_popups then
                    local popup = sa.card_popups[sa.card_index]
                    popup.alpha = math.min(1, sa.card_timer / (M.CARD_DELAY * 0.5))
                end
            end
        end
    end

    if sa.phase == "mult" and remaining > 0 then
        local need = M.MULT_DURATION - sa.mult_timer
        if remaining >= need then
            remaining = remaining - need
            sa.phase = "total"
            sa.total_timer = 0
            sa.displayed_total = 0
        else
            sa.mult_timer = sa.mult_timer + remaining
            remaining = 0
        end
    end

    if sa.phase == "total" and remaining > 0 then
        sa.total_timer = sa.total_timer + remaining
        local ratio = math.min(1, sa.total_timer / M.TOTAL_DURATION)
        -- Ease-out curve for countup
        local eased = 1 - (1 - ratio) * (1 - ratio)
        sa.displayed_total = math.floor(sa.total * eased)
        if sa.total_timer >= M.TOTAL_DURATION then
            sa.displayed_total = sa.total
            sa.phase = "done"
        end
    end
end

--- Dismiss the animation (return to idle).
function M.dismiss(sa)
    sa.phase = "idle"
    sa.card_popups = {}
    sa.gwang_glows = {}
end

--- Is animation currently playing?
function M.is_playing(sa)
    return sa.phase ~= "idle" and sa.phase ~= "done"
end

function M.popup_position(popup, fallback)
    local anchor = popup and popup.anchor
    if anchor and anchor.x and anchor.y then
        return anchor.x + card.WIDTH / 2, anchor.y - 30
    end
    if popup and popup.x then
        return popup.x + card.WIDTH / 2, (popup.y or 420) - 30
    end
    if fallback then
        return fallback.x + card.WIDTH / 2, (fallback.y or 420) - 30
    end
    return nil, nil
end

--- Draw the score animation (requires love.graphics).
function M.draw(sa, hand_cards)
    if not love or not love.graphics then return end
    if sa.phase == "idle" then return end

    local font = love.graphics.getFont()
    local fh = font:getHeight()

    -- Phase: cards — show chip popups above each card
    if sa.phase == "cards" or sa.phase == "mult" or sa.phase == "total" or sa.phase == "done" then
        for i, popup in ipairs(sa.card_popups) do
            if popup.shown then
                local card_x, text_y = M.popup_position(popup, hand_cards and hand_cards[i])
                if not card_x then
                    card_x = 10 + (i - 1) * 34 + 14
                    text_y = 93
                end
                local txt = "+" .. tostring(popup.chips)
                -- Floating chip text, anchored to the moving played card.
                love.graphics.setColor(0.6, 0.85, 1, popup.alpha)
                love.graphics.print(txt, card_x - font:getWidth(txt) / 2, text_y)
            end
        end
    end

    -- Phase: mult — show mult application
    if sa.phase == "mult" or sa.phase == "total" or sa.phase == "done" then
        local cx = VIEWPORT_W / 2
        local cy = VIEWPORT_H / 2 - 20

        -- Chips label
        love.graphics.setColor(0.6, 0.85, 1, 1)
        local chips_txt = tostring(sa.final_chips)
        love.graphics.print(chips_txt, cx - font:getWidth(chips_txt) - 10, cy)

        -- × symbol
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print("×", cx - 4, cy)

        -- Mult label (red/orange)
        love.graphics.setColor(1, 0.5, 0.3, 1)
        local mult_txt = tostring(sa.final_mult)
        love.graphics.print(mult_txt, cx + 10, cy)
    end

    -- Phase: total — burst only. The counting number is owned by scoreboard.popup.
    if sa.phase == "total" or sa.phase == "done" then
        local cx = VIEWPORT_W / 2
        local cy = VIEWPORT_H / 2
        local scale = 1
        if sa.phase == "total" then
            local ratio = math.min(1, sa.total_timer / M.TOTAL_DURATION)
            scale = 1.5 - 0.5 * ratio
        end
        effect_art.draw_score(cx, cy + fh / 2, scale, 0.9)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

--- Draw gwang slot glow overlay.
-- Call this after gwang_slots.draw() to overlay glow on triggered slots.
function M.draw_gwang_glow(sa)
    if not love or not love.graphics then return end
    for _, g in ipairs(sa.gwang_glows) do
        if g.timer > 0 then
            local alpha = math.min(1, g.timer / 0.5)  -- fade out in last 0.5s
            -- Pulse effect
            local pulse = 0.5 + 0.5 * math.sin(g.timer * 8)
            local positions = gwang_slots.slot_positions()
            local slot = positions[g.slot] or positions[1]
            local slot_x = slot.x
            local slot_y = slot.y
            local slot_w = slot.w
            local slot_h = slot.h

            -- Glow color depends on identity
            if g.identity == "chips" then
                love.graphics.setColor(0.3, 0.7, 1, alpha * pulse * 0.6)
            elseif g.identity == "mult" then
                love.graphics.setColor(1, 0.4, 0.2, alpha * pulse * 0.6)
            elseif g.identity == "yaku_mult" then
                love.graphics.setColor(1, 0.9, 0.2, alpha * pulse * 0.6)
            else
                love.graphics.setColor(1, 1, 1, alpha * pulse * 0.6)
            end

            -- Draw glow rectangle around slot
            love.graphics.rectangle("fill", slot_x - 2, slot_y - 2, slot_w + 4, slot_h + 4, 4, 4)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

return M
