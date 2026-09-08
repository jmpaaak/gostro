local M = {}

local wish_cards = require("game.wish_cards")

M.TITLE = "기원패"

function M.draw(run_state)
    if not love or not love.graphics then return end

    local font = love.graphics.getFont()
    local fh = font:getHeight()

    local y_start = 40
    local x = 10

    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(M.TITLE, x, y_start)

    local all_wish_cards = wish_cards.all()
    local y = y_start + fh + 4

    for _, card in ipairs(all_wish_cards) do
        local lvl = wish_cards.get_level(run_state, card.yaku)
        if lvl > 1 then
            love.graphics.setColor(1, 0.9, 0.3, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        local txt = card.name .. " (Lv." .. tostring(lvl) .. ")"
        love.graphics.print(txt, x, y)
        y = y + fh + 2
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return M
