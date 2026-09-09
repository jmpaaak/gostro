local M = {}

local planets = require("game.planets")

local BOX = { x = 12, y = 288, w = 300, h = 48 }

function M.layout()
    return { x = BOX.x, y = BOX.y, w = BOX.w, h = BOX.h }
end

function M.draw(run_state)
    if not love or not love.graphics then return end
    
    local font = love.graphics.getFont()
    local fh = font:getHeight()
    
    local y_start = BOX.y
    local x = BOX.x
    
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print("족보 레벨", x, y_start)
    
    local all_planets = planets.all()
    local y = y_start + fh + 4
    
    for _, p in ipairs(all_planets) do
        local lvl = planets.get_level(run_state, p.yaku)
        if lvl > 1 then
            love.graphics.setColor(1, 0.9, 0.3, 1)
            local txt = p.name .. " (Lv." .. tostring(lvl) .. ")"
            love.graphics.print(txt, x, y)
            y = y + fh + 2
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return M
