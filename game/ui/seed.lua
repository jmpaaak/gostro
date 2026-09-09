-- game/ui/seed.lua
-- Balatro-style seed display + input. Headless-safe. No month numbers/names.

local rng = require("game.rng")

local M = {}

M.MAX_LEN = 8

function M.field_rect()
    return { x = 12, y = 12, w = 228, h = 36 }
end

function M.new(seed_str)
    local seed = rng.normalize(seed_str)
    if seed == "" then
        seed = rng.generate()
    end
    return {
        seed = seed,
        input = "",
        focused = false,
    }
end

function M.display(s)
    return s.seed
end

function M.label(s)
    if s.focused then
        if s.input == "" then
            return "시드: _"
        end
        return "시드: " .. s.input
    end
    return "시드: " .. s.seed
end

function M.set_seed(s, seed_str)
    local seed = rng.normalize(seed_str)
    if seed == "" then
        seed = rng.generate()
    end
    s.seed = seed
    s.input = ""
    s.focused = false
    return seed
end

function M.focus(s)
    s.focused = true
    s.input = ""
end

function M.unfocus(s)
    s.focused = false
    s.input = ""
end

function M.hit_test(s, px, py)
    local r = M.field_rect()
    if px >= r.x and px < r.x + r.w and py >= r.y and py < r.y + r.h then
        return "field"
    end
    return nil
end

local function is_alnum_key(key)
    return type(key) == "string" and #key == 1 and key:match("^[A-Za-z0-9]$") ~= nil
end

function M.keypressed(s, key)
    if not s.focused then
        return nil
    end
    if key == "escape" then
        M.unfocus(s)
        return nil
    end
    if key == "return" or key == "kpenter" then
        return M.set_seed(s, s.input)
    end
    if key == "backspace" then
        if #s.input > 0 then
            s.input = s.input:sub(1, -2)
        end
        return nil
    end
    if is_alnum_key(key) and #s.input < M.MAX_LEN then
        s.input = s.input .. key:upper()
    end
    return nil
end

function M.draw(s)
    if not love or not love.graphics then return end
    local r = M.field_rect()
    if s.focused then
        love.graphics.setColor(0.15, 0.2, 0.35, 0.9)
    else
        love.graphics.setColor(0.08, 0.1, 0.18, 0.8)
    end
    love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 2, 2)
    if s.focused then
        love.graphics.setColor(1, 0.9, 0.3, 1)
    else
        love.graphics.setColor(0.7, 0.75, 0.85, 1)
    end
    love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 2, 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(M.label(s), r.x + 8, r.y + 4)
    love.graphics.setColor(1, 1, 1, 1)
end

return M
