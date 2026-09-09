-- game/ui/action_buttons.lua
-- Balatro-style bottom-center play/discard buttons with hand/discard counts.
-- Touch tap + keyboard shortcuts (space = play, d = discard).

local score_icon_art = require("game.ui.score_icon_art")
local button_art = require("game.ui.button_art")

local M = {}

local VIEWPORT_W = 960
local VIEWPORT_H = 540

-- Button dimensions
M.BUTTON_W = 174
M.BUTTON_H = 54

-- Layout: buttons sit left/right of the 8-card fan, not over the cards.
M.PLAY_X    = 18
M.DISCARD_X = VIEWPORT_W - M.BUTTON_W - 18
M.BUTTON_Y  = VIEWPORT_H - M.BUTTON_H - 126

-- Default counts per round (Balatro standard)
local DEFAULT_HANDS    = 4
local DEFAULT_DISCARDS = 3

--- Create a new action buttons state.
function M.new(hands, discards)
    return {
        hands_left     = hands or DEFAULT_HANDS,
        discards_left  = discards or DEFAULT_DISCARDS,
        play_enabled   = false,
        discard_enabled = false,
        selection_count = 0,
    }
end

--- Update enabled state based on how many cards are selected.
function M.set_selection(ab, count)
    ab.selection_count = count
    ab.play_enabled    = count > 0 and ab.hands_left > 0
    ab.discard_enabled = count > 0 and ab.discards_left > 0
end

--- Attempt to use a hand play. Returns true on success.
function M.use_hand(ab)
    if not ab.play_enabled then return false end
    ab.hands_left = ab.hands_left - 1
    M.set_selection(ab, 0)
    return true
end

--- Attempt to use a discard. Returns true on success.
function M.use_discard(ab)
    if not ab.discard_enabled then return false end
    ab.discards_left = ab.discards_left - 1
    M.set_selection(ab, 0)
    return true
end

--- Reset counts for a new round.
function M.reset(ab, hands, discards)
    ab.hands_left    = hands or DEFAULT_HANDS
    ab.discards_left = discards or DEFAULT_DISCARDS
    ab.selection_count = 0
    ab.play_enabled  = false
    ab.discard_enabled = false
end

--- Hit-test: returns "play", "discard", or nil.
function M.hit_test(ab, px, py)
    if py >= M.BUTTON_Y and py < M.BUTTON_Y + M.BUTTON_H then
        if px >= M.PLAY_X and px < M.PLAY_X + M.BUTTON_W then
            return "play"
        end
        if px >= M.DISCARD_X and px < M.DISCARD_X + M.BUTTON_W then
            return "discard"
        end
    end
    return nil
end

--- Display text for a button: "놓기 (N)" or "버리기 (N)".
function M.display_text(ab, which)
    if which == "play" then
        return "놓기 (" .. tostring(ab.hands_left) .. ")"
    elseif which == "discard" then
        return "버리기 (" .. tostring(ab.discards_left) .. ")"
    end
    return ""
end

--- Handle keyboard shortcut. Returns "play", "discard", or nil.
function M.keypressed(ab, key)
    if key == "space" and ab.play_enabled then
        return "play"
    elseif key == "d" and ab.discard_enabled then
        return "discard"
    end
    return nil
end

--- Draw buttons (requires love.graphics).
function M.draw(ab)
    if not love or not love.graphics then return end
    local font = love.graphics.getFont()
    local fh = font:getHeight()

    -- Play button
    local play_kind = ab.play_enabled and "primary" or "disabled"
    button_art.draw(play_kind, {x = M.PLAY_X, y = M.BUTTON_Y, w = M.BUTTON_W, h = M.BUTTON_H})

    -- Play text
    local play_txt = M.display_text(ab, "play")
    score_icon_art.draw_hand(M.PLAY_X + 3, M.BUTTON_Y + 3, 12)
    love.graphics.setColor(1, 1, 1, ab.play_enabled and 1 or 0.4)
    love.graphics.print(play_txt,
        M.PLAY_X + 17,
        M.BUTTON_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Discard button
    local dis_kind = ab.discard_enabled and "danger" or "disabled"
    button_art.draw(dis_kind, {x = M.DISCARD_X, y = M.BUTTON_Y, w = M.BUTTON_W, h = M.BUTTON_H})

    -- Discard text
    local dis_txt = M.display_text(ab, "discard")
    score_icon_art.draw_discard(M.DISCARD_X + 3, M.BUTTON_Y + 3, 12)
    love.graphics.setColor(1, 1, 1, ab.discard_enabled and 1 or 0.4)
    love.graphics.print(dis_txt,
        M.DISCARD_X + 17,
        M.BUTTON_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return M
