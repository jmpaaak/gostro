-- Win/loss summary is readable and exposes a real restart action.

local end_screen = require("game.ui.end_screen")
local play = require("game.scenes.play")

local M = {}

function M.run()
    local state = {
        ante = 4,
        round_score = 12345,
        seed = "RESULT42",
        gwang = {
            { kind = "gwang", identity = "chips" },
            { kind = "gwang", identity = "mult" },
        },
    }
    local lost = end_screen.view(state, "lost")
    assert(lost.title == "도전 종료")
    assert(lost.ante_label == "최종 고 4")
    assert(lost.score_label == "최종 점수 12345")
    assert(lost.seed_label == "시드 RESULT42")
    assert(#lost.gwang_labels == 2 and lost.gwang_labels[1]:find("칩"))
    assert(lost.restart_label == "다시 시작")

    local won = end_screen.view(state, "won")
    assert(won.title == "승리!")

    local button = end_screen.restart_rect()
    assert(end_screen.hit_test(button.x + button.w / 2, button.y + button.h / 2) == "restart")
    assert(end_screen.hit_test(0, 0) == nil)

    local scene = play.new({ starting_deck_id = "hwatu", stake_id = "white", seeded = true, seed = "RESULT42" })
    local old_state = scene.run_state
    scene.state = "lost"
    assert(end_screen.mousepressed(scene, button.x + 1, button.y + 1, play.restart) == "restart")
    assert(scene.state == "blind_select")
    assert(scene.run_state ~= old_state and scene.run_state.seed == old_state.seed)
    assert(scene.run_config.starting_deck_id == "hwatu")

    scene.state = "won"
    old_state = scene.run_state
    assert(end_screen.keypressed(scene, "return", play.restart) == "restart")
    assert(scene.state == "blind_select" and scene.run_state ~= old_state)

    print("  end_screen: OK")
end

return M
