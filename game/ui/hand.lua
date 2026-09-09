-- game/ui/hand.lua
-- Hand display module: 8 cards at bottom, Balatro-style overlapping layout.
-- Selection up to 5 cards with order tracking.

local card = require("game.ui.card")
local effect_art = require("game.ui.effect_art")

local M = {}

M.MAX_SELECT = 5

-- Layout constants for 960×540 viewport
local VIEWPORT_W = 960
local VIEWPORT_H = 540
local OVERLAP    = 42   -- horizontal gap between cards (< card.WIDTH=72 → overlap)
local BOTTOM_PAD = 12   -- pixels from bottom edge of viewport
local HAND_Y     = VIEWPORT_H - card.HEIGHT - BOTTOM_PAD  -- top edge of unselected cards

--- Create a new empty hand state.
function M.new()
    return {
        cards          = {},
        selected_order = {},   -- list of card indices in selection order
        hover          = nil,
    }
end

--- Deal cards into the hand from kind strings or domain card objects.
-- Gameplay metadata (effect/uid/etc.) is shallow-copied; UI position and
-- selection state are always owned by the hand widget.
function M.deal(h, cards)
    local n = #cards
    -- Total width of the fan
    local fan_width = (n - 1) * OVERLAP + card.WIDTH
    local start_x = math.floor((VIEWPORT_W - fan_width) / 2)

    h.cards = {}
    h.selected_order = {}
    h.hover = nil
    for i, source in ipairs(cards) do
        local domain = type(source) == "table" and source or { kind = source }
        local x = start_x + (i - 1) * OVERLAP
        local widget = card.new(domain.kind, x, HAND_Y)
        for key, value in pairs(domain) do
            if key ~= "x" and key ~= "y" and key ~= "selected" then
                widget[key] = value
            end
        end
        h.cards[i] = widget
    end
end

--- Select a card by index. Returns true if selected, false if at max.
function M.select(h, idx)
    local c = h.cards[idx]
    if not c or c.selected then return false end
    if #h.selected_order >= M.MAX_SELECT then return false end
    c.selected = true
    h.selected_order[#h.selected_order + 1] = idx
    return true
end

--- Deselect a card by index.
function M.deselect(h, idx)
    local c = h.cards[idx]
    if not c or not c.selected then return end
    c.selected = false
    -- Remove from order list
    for i = #h.selected_order, 1, -1 do
        if h.selected_order[i] == idx then
            table.remove(h.selected_order, i)
            break
        end
    end
end

--- Toggle selection on a card.
function M.toggle(h, idx)
    local c = h.cards[idx]
    if not c then return end
    if c.selected then
        M.deselect(h, idx)
    else
        M.select(h, idx)
    end
end

--- Return the 1-based selection order for a card, or nil if not selected.
function M.selection_index(h, idx)
    for i, v in ipairs(h.selected_order) do
        if v == idx then return i end
    end
    return nil
end

--- Return the selected cards in selection order.
function M.get_selected(h)
    local result = {}
    for _, idx in ipairs(h.selected_order) do
        result[#result + 1] = h.cards[idx]
    end
    return result
end

--- Draw all cards in the hand (requires love.graphics).
function M.draw(h)
    if not love or not love.graphics then return end
    local font = love.graphics.getFont()

    for i, c in ipairs(h.cards) do
        card.draw(c)

        -- Draw selection order number on selected cards
        local sel_idx = M.selection_index(h, i)
        if sel_idx then
            local dy = card.draw_y(c)
            effect_art.draw_select(c.x, dy, card.WIDTH, card.HEIGHT)
            local num = tostring(sel_idx)
            local tw = font:getWidth(num)
            love.graphics.setColor(1, 1, 0.3, 1)
            love.graphics.print(num, c.x + (card.WIDTH - tw) / 2, dy - 8)
        end
    end
end

--- Hit-test: return card index at point (px, py), or nil.
-- Tests in reverse order (top card = last drawn = highest z).
function M.hit_test(h, px, py)
    for i = #h.cards, 1, -1 do
        if card.hit_test(h.cards[i], px, py) then
            return i
        end
    end
    return nil
end

function M.hover_index(h)
    return h.hover
end

function M.set_hover(h, idx)
    h.hover = idx
    for i, c in ipairs(h.cards) do
        c.hovered = (i == idx)
    end
end

function M.set_hover_at(h, px, py)
    M.set_hover(h, M.hit_test(h, px, py))
end

return M
