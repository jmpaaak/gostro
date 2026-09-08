-- game/ui/card.lua
-- Single hwatu card widget: data + optional rendering.
-- Play cards only (no gwang — gwang is a joker slot).

local M = {}

M.WIDTH  = 24
M.HEIGHT = 36
M.LIFT   = 8  -- pixels to raise when selected

local PLAY_KINDS = {
    hongdan   = true,
    cheongdan = true,
    chodan    = true,
    godori    = true,
    pi        = true,
}

local SYMBOLS = {
    hongdan   = "▐",   -- red flag
    cheongdan = "▌",   -- blue flag
    chodan    = "❀",   -- orchid
    godori    = "♦",   -- animal / bird
    pi        = "·",   -- dot
}

local BG_COLORS = {
    hongdan   = { 0.85, 0.20, 0.20 },
    cheongdan = { 0.20, 0.40, 0.85 },
    chodan    = { 0.30, 0.75, 0.35 },
    godori    = { 0.90, 0.65, 0.10 },
    pi        = { 0.55, 0.55, 0.55 },
}

--- Create a new card widget.
-- @param kind  string  one of the PLAY_KINDS
-- @param x     number  left edge in game coords
-- @param y     number  top edge in game coords (unselected)
-- @return table  card widget
function M.new(kind, x, y)
    if kind == "gwang" then
        error("gwang is a joker slot, not a play card")
    end
    if not PLAY_KINDS[kind] then
        error("unknown play card kind: " .. tostring(kind))
    end
    return {
        kind     = kind,
        x        = x,
        y        = y,
        selected = false,
    }
end

--- Toggle selection state.
function M.toggle_select(c)
    c.selected = not c.selected
end

--- Effective draw Y (lifted when selected).
function M.draw_y(c)
    return c.selected and (c.y - M.LIFT) or c.y
end

--- Symbol character for a play-card kind.
function M.symbol(kind)
    return SYMBOLS[kind]
end

--- Background colour table {r,g,b} for a kind.
function M.bg_color(kind)
    return BG_COLORS[kind]
end

--- Point-in-rect hit test (uses draw_y for lifted cards).
function M.hit_test(c, px, py)
    local dy = M.draw_y(c)
    return px >= c.x and px < c.x + M.WIDTH
       and py >= dy  and py < dy  + M.HEIGHT
end

--- Draw a card (requires love.graphics; safe to skip in headless).
function M.draw(c)
    if not love or not love.graphics then return end
    local dy = M.draw_y(c)
    local bg = BG_COLORS[c.kind]

    -- background rect
    love.graphics.setColor(bg[1], bg[2], bg[3], 1)
    love.graphics.rectangle("fill", c.x, dy, M.WIDTH, M.HEIGHT, 2, 2)

    -- border (highlight when selected)
    if c.selected then
        love.graphics.setColor(1, 1, 0.3, 1)
    else
        love.graphics.setColor(0.15, 0.15, 0.15, 1)
    end
    love.graphics.rectangle("line", c.x, dy, M.WIDTH, M.HEIGHT, 2, 2)

    -- symbol centred
    love.graphics.setColor(1, 1, 1, 1)
    local sym = SYMBOLS[c.kind]
    local font = love.graphics.getFont()
    local tw = font:getWidth(sym)
    local th = font:getHeight()
    love.graphics.print(sym, c.x + (M.WIDTH - tw) / 2, dy + (M.HEIGHT - th) / 2)
end

return M
