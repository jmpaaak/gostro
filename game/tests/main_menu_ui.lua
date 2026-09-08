local main_menu = require("game.ui.main_menu")

local M = {}

function M.run()
    local menu = main_menu.new()
    assert(menu.mode == "landing", "menu starts on the landing mode")

    local landing = main_menu.buttons(menu)
    assert(#landing == 1 and landing[1].id == "play", "landing exposes one primary play action")
    assert(landing[1].label == "게임 시작", "landing action uses the Gostro Korean label")
    assert(landing[1].w >= 120 and landing[1].h >= 36, "primary action is a large touch target")

    local play = landing[1]
    assert(main_menu.hit_test(menu, play.x, play.y) == "play", "button includes its top-left edge")
    assert(main_menu.hit_test(menu, play.x + play.w - 1, play.y + play.h - 1) == "play",
        "button includes its inner bottom-right pixel")
    assert(main_menu.hit_test(menu, play.x + play.w, play.y + play.h) == nil,
        "button excludes coordinates beyond its bounds")
    assert(main_menu.hit_test(menu, 0, 0) == nil, "background is not interactive")

    assert(main_menu.activate(menu, play.x + 1, play.y + 1) == "open_play_menu",
        "primary action explicitly opens the play submenu")
    assert(menu.mode == "play_menu", "play action changes UI state immediately")

    local submenu = main_menu.buttons(menu)
    assert(#submenu == 3, "play submenu exposes exactly three observed actions")
    assert(submenu[1].id == "new_game" and submenu[1].label == "새 게임", "new game is first")
    assert(submenu[2].id == "continue" and submenu[2].label == "계속하기", "continue is second")
    assert(submenu[3].id == "challenges" and submenu[3].label == "도전", "challenges is third")
    for i, button in ipairs(submenu) do
        assert(button.w >= 120 and button.h >= 28, "submenu action " .. i .. " is touch-sized")
        if i > 1 then
            assert(submenu[i - 1].y + submenu[i - 1].h <= button.y, "submenu actions do not overlap")
        end
        assert(main_menu.hit_test(menu, button.x + button.w / 2, button.y + button.h / 2) == button.id,
            "submenu action " .. button.id .. " is hit-testable")
    end

    assert(main_menu.activate(menu, submenu[2].x + 1, submenu[2].y + 1) == "continue_unavailable",
        "continue returns an explicit non-transition action")
    assert(menu.mode == "play_menu" and menu.notice ~= nil, "continue remains in the submenu with feedback")
    assert(main_menu.activate(menu, submenu[3].x + 1, submenu[3].y + 1) == "challenges_unavailable",
        "challenges returns an explicit non-transition action")
    assert(menu.mode == "play_menu" and menu.notice ~= nil, "challenges remains in the submenu with feedback")
    assert(main_menu.activate(menu, submenu[1].x + 1, submenu[1].y + 1) == "new_game",
        "new game returns its routing action")

    print("  main_menu_ui: OK")
end

return M
