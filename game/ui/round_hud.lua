-- Right-column round status: ante, current 판, money, remaining deck.

local terms = require("game.terms")
local score_icon_art = require("game.ui.score_icon_art")
local play_layout = require("game.ui.play_layout")

local M = {}

local BOX = play_layout.round_hud()

function M.layout()
    return { x = BOX.x, y = BOX.y, w = BOX.w, h = BOX.h }
end

function M.view(run_state, round)
    local deck_left = 0
    if type(round) == "table" and type(round.draw_pile) == "table" then
        deck_left = #round.draw_pile
    end
    return {
        ante = terms.ante(run_state.ante or 1),
        blind = terms.blind_name(run_state.blind),
        money = "$" .. tostring(run_state.money or 0),
        deck = "패 " .. tostring(deck_left),
        hint = "패를 고르고 놓기",
    }
end

function M.draw(run_state, round)
    if not love or not love.graphics then return end
    local view = M.view(run_state, round)
    local font = love.graphics.getFont()
    local box = BOX

    love.graphics.setColor(0.08, 0.09, 0.16, 0.82)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h, 4, 4)
    love.graphics.setColor(0.72, 0.62, 0.28, 0.7)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h, 4, 4)

    love.graphics.setColor(0.98, 0.86, 0.42, 1)
    love.graphics.print(view.ante .. "  " .. view.blind, box.x + 10, box.y + 6)

    score_icon_art.draw_money(box.x + 10, box.y + 36, 16)
    love.graphics.setColor(0.85, 0.95, 0.72, 1)
    love.graphics.print(view.money, box.x + 30, box.y + 34)

    love.graphics.setColor(0.72, 0.80, 0.90, 1)
    love.graphics.print(view.deck, box.x + 120, box.y + 34)

    love.graphics.setColor(0.62, 0.68, 0.74, 1)
    love.graphics.print(view.hint, box.x + 10, box.y + box.h - font:getHeight() - 4)
    love.graphics.setColor(1, 1, 1, 1)
end

return M
