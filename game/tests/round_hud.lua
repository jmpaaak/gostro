-- Playing HUD always shows ante, current blind, money, and remaining deck.

local play = require("game.scenes.play")
local round_hud = require("game.ui.round_hud")
local terms = require("game.terms")

local M = {}

local function overlaps(a, b)
    return a.x < b.x + b.w and b.x < a.x + a.w
        and a.y < b.y + b.h and b.y < a.y + a.h
end

function M.run()
    local scene = play.new("ROUND-HUD")
    play.select_blind(scene, 1)

    local view = round_hud.view(scene.run_state, scene.round)
    assert(view.ante == terms.ante(1), "ante uses Korean 고")
    assert(view.blind == terms.blind_name("small"), "current 판 is named")
    assert(view.money == "$" .. tostring(scene.run_state.money))
    assert(view.deck:find(tostring(#scene.round.draw_pile), 1, true),
        "deck count is the remaining draw pile")
    assert(view.hint == "패를 고르고 놓기")

    local box = round_hud.layout()
    assert(box.x >= 480, "round HUD sits on the right half")
    assert(box.y >= 156, "round HUD sits below consumable slots")
    assert(box.y + box.h <= 360, "round HUD stays above play/discard")
    local scoreboard = require("game.ui.scoreboard").layout()
    assert(not overlaps(box, scoreboard), "round HUD must not cover the scoreboard")

    print("  round_hud: OK")
end

return M
