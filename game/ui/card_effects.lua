-- game/ui/card_effects.lua
-- Balatro-style card editions: hologram / foil / polychrome.
-- Visual overlay data + chips/mult bonuses. Headless-safe (love optional).

local M = {}

M.HOLOGRAM = "hologram"
M.FOIL = "foil"
M.POLYCHROME = "polychrome"

-- hologram +10 mult, foil +50 chips, polychrome ×1.5 mult
local BONUS = {
    hologram = { chips = 0,  mult_add = 10, mult_mul = 1 },
    foil     = { chips = 50, mult_add = 0,  mult_mul = 1 },
    polychrome = { chips = 0, mult_add = 0,  mult_mul = 1.5 },
}

local VISUAL = {
    hologram   = { kind = "hologram",   style = "rainbow_translucent", alpha = 0.45 },
    foil       = { kind = "foil",       style = "sparkle_overlay",     alpha = 0.55 },
    polychrome = { kind = "polychrome", style = "color_shift",         alpha = 0.50 },
}

function M.is_known(name)
    return BONUS[name] ~= nil
end

function M.bonus(name)
    if name == nil then
        return { chips = 0, mult_add = 0, mult_mul = 1 }
    end
    local b = BONUS[name]
    if not b then
        error("unknown card effect: " .. tostring(name))
    end
    return { chips = b.chips, mult_add = b.mult_add, mult_mul = b.mult_mul }
end

function M.visual(name)
    if name == nil then
        return nil
    end
    local v = VISUAL[name]
    if not v then
        error("unknown card effect: " .. tostring(name))
    end
    return { kind = v.kind, style = v.style, alpha = v.alpha }
end

function M.apply(card, name)
    if not BONUS[name] then
        error("unknown card effect: " .. tostring(name))
    end
    card.effect = name
    return card
end

--- Overlay RGBA for an effect at time t (seconds). Headless-testable.
function M.overlay_color(name, t)
    t = t or 0
    if name == "hologram" then
        -- rainbow: hue cycles around the spectrum
        local h = (t * 0.6) % 1
        local r, g, b = M._hsv(h, 0.7, 1)
        return { r, g, b, 0.45 }
    elseif name == "foil" then
        -- silver sparkle pulse
        local pulse = 0.55 + 0.35 * math.abs(math.sin(t * 8))
        return { 0.85, 0.90, 1.0, pulse }
    elseif name == "polychrome" then
        -- RGB color shift
        local r = 0.5 + 0.5 * math.sin(t * 2.1)
        local g = 0.5 + 0.5 * math.sin(t * 2.1 + 2.094)
        local b = 0.5 + 0.5 * math.sin(t * 2.1 + 4.189)
        return { r, g, b, 0.50 }
    elseif name == nil then
        return nil
    end
    error("unknown card effect: " .. tostring(name))
end

function M._hsv(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v, t, p end
    if i == 1 then return q, v, p end
    if i == 2 then return p, v, t end
    if i == 3 then return p, q, v end
    if i == 4 then return t, p, v end
    return v, p, q
end

--- Sum edition bonuses across a played hand.
-- chips += foil; mult = (mult + hologram) * product(polychrome).
function M.apply_bonuses(hand, chips, mult)
    local effect_chips = 0
    local effect_mult_add = 0
    local effect_mult_mul = 1
    for i = 1, #hand do
        local name = hand[i].effect
        if name ~= nil then
            local b = M.bonus(name)
            effect_chips = effect_chips + b.chips
            effect_mult_add = effect_mult_add + b.mult_add
            effect_mult_mul = effect_mult_mul * b.mult_mul
        end
    end
    chips = chips + effect_chips
    mult = (mult + effect_mult_add) * effect_mult_mul
    return chips, mult, {
        effect_chips = effect_chips,
        effect_mult_add = effect_mult_add,
        effect_mult_mul = effect_mult_mul,
    }
end

--- Draw overlay on a card rect. No-op without love.graphics.
function M.draw_overlay(name, x, y, w, h, t)
    if not name then return end
    if not love or not love.graphics then return end
    local edition_art = require("game.ui.edition_art")
    if edition_art.draw(name, x, y, w, h, t) then
        love.graphics.setColor(1, 1, 1, 1)
        return
    end
    local col = M.overlay_color(name, t)
    love.graphics.setColor(col[1], col[2], col[3], col[4])
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    if name == "foil" then
        -- sparkle ticks
        love.graphics.setColor(1, 1, 1, 0.35 + 0.25 * math.abs(math.sin((t or 0) * 10)))
        love.graphics.rectangle("line", x + 1, y + 1, w - 2, h - 2, 2, 2)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return M
