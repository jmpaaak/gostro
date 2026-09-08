local main_menu = require("game.ui.main_menu")

local M = {}

local function center(rect)
    return rect.x + rect.w / 2, rect.y + rect.h / 2
end

function M.run()
    local menu = main_menu.new()
    assert(menu.mode == "landing", "menu starts on the landing mode")
    assert(menu.selected_tab == "new_game", "new run is the initially selected tab")

    local landing = main_menu.buttons(menu)
    assert(#landing == 1 and landing[1].id == "play", "landing exposes one primary play action")
    assert(landing[1].label == "게임 시작", "landing action uses the Gostro Korean label")
    assert(landing[1].w >= 120 and landing[1].h >= 44, "primary action is a large touch target")

    local play = landing[1]
    assert(main_menu.hit_test(menu, play.x, play.y) == "play", "button includes its top-left edge")
    assert(main_menu.hit_test(menu, play.x + play.w - 1, play.y + play.h - 1) == "play",
        "button includes its inner bottom-right pixel")
    assert(main_menu.hit_test(menu, play.x + play.w, play.y + play.h) == nil,
        "button excludes coordinates beyond its bounds")
    assert(main_menu.hit_test(menu, 0, 0) == nil, "background is not interactive")

    local x, y = center(play)
    assert(main_menu.activate(menu, x, y) == "open_play_menu", "play opens the tab panel")
    assert(menu.mode == "play_menu", "play changes UI state immediately")

    local tabs = main_menu.tabs(menu)
    assert(#tabs == 3, "play panel exposes exactly three observed tabs")
    assert(tabs[1].id == "new_game" and tabs[1].label == "새 게임", "new run tab is first")
    assert(tabs[2].id == "continue" and tabs[2].label == "계속하기", "continue tab is second")
    assert(tabs[3].id == "challenges" and tabs[3].label == "도전", "challenges tab is third")
    for i, tab in ipairs(tabs) do
        assert(tab.w >= 80 and tab.h >= 44, "tab " .. i .. " is a large touch target")
        if i > 1 then
            assert(tabs[i - 1].x + tabs[i - 1].w <= tab.x, "tabs are horizontally ordered and non-overlapping")
            assert(tabs[i - 1].y == tab.y, "tabs share one horizontal row")
        end
        x, y = center(tab)
        assert(main_menu.hit_test(menu, x, y) == tab.id, "tab " .. tab.id .. " is hit-testable")
        assert(tab.selected == (tab.id == menu.selected_tab), "only selected tab exposes selected state")
    end

    local indicator = main_menu.selected_indicator(menu)
    assert(indicator.tab_id == "new_game", "selection indicator identifies the selected tab")
    assert(indicator.y + indicator.h <= tabs[1].y, "selection indicator is above the active tab")
    assert(indicator.x >= tabs[1].x and indicator.x + indicator.w <= tabs[1].x + tabs[1].w,
        "selection indicator is contained by the active tab width")

    x, y = center(tabs[2])
    assert(main_menu.activate(menu, x, y) == "select_continue", "continue tap returns a semantic tab action")
    assert(menu.mode == "play_menu" and menu.selected_tab == "continue", "continue tap switches tabs in place")
    indicator = main_menu.selected_indicator(menu)
    assert(indicator.tab_id == "continue", "indicator follows a tab switch")

    x, y = center(tabs[3])
    assert(main_menu.activate(menu, x, y) == "select_challenges", "challenge tap returns a semantic tab action")
    assert(menu.selected_tab == "challenges", "challenge tap switches tabs")

    x, y = center(tabs[1])
    assert(main_menu.activate(menu, x, y) == "select_new_game", "new run tab does not route to gameplay")
    assert(menu.selected_tab == "new_game", "new run tap only selects its panel")

    local back = main_menu.back_button(menu)
    assert(back.id == "back" and back.label == "뒤로", "panel exposes the observed Korean back action")
    assert(back.w >= 200 and back.h >= 36, "back is a wide bottom touch target")
    assert(back.y > tabs[1].y + tabs[1].h, "back sits below tab content")
    x, y = center(back)
    assert(main_menu.hit_test(menu, x, y) == "back", "back button is hit-testable")
    assert(main_menu.activate(menu, x, y) == "back_to_landing", "back returns a semantic action")
    assert(menu.mode == "landing", "back returns to landing")
    assert(#main_menu.buttons(menu) == 1, "landing is restored after back")

    print("  main_menu_ui: OK")
end

return M
