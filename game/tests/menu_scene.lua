local main_menu = require("game.ui.main_menu")
local MenuScene = require("game.scenes.menu")
local scene_stack = require("game.scene_stack")

local M = {}

local function center(button)
    return button.x + button.w / 2, button.y + button.h / 2
end

function M.run()
    local menu_scene = MenuScene.new()
    local stack = scene_stack.new(menu_scene)
    menu_scene:bind(stack)

    local landing = main_menu.buttons(menu_scene.ui)[1]
    local x, y = center(landing)
    assert(menu_scene:mousepressed(x, y, 2) == nil, "non-primary mouse presses are ignored")
    assert(menu_scene.ui.mode == "landing", "ignored input does not change the scene")
    assert(menu_scene:mousepressed(x, y, 1) == "open_play_menu", "landing tap is routed to the UI")
    assert(stack.current == menu_scene and menu_scene.ui.mode == "play_menu",
        "opening the submenu does not replace the scene")

    local submenu = main_menu.buttons(menu_scene.ui)
    x, y = center(submenu[2])
    assert(menu_scene:mousepressed(x, y, 1) == "continue_unavailable", "continue reports unavailable")
    assert(stack.current == menu_scene, "continue never silently starts a new run")
    x, y = center(submenu[3])
    assert(menu_scene:mousepressed(x, y, 1) == "challenges_unavailable", "challenges reports unavailable")
    assert(stack.current == menu_scene, "challenges never silently starts a new run")

    x, y = center(submenu[1])
    assert(menu_scene:mousepressed(x, y, 1) == "new_game", "new game action is returned")
    assert(stack.current ~= menu_scene, "new game replaces the menu scene")
    assert(stack.current.state == "blind_select" and stack.current.run_state ~= nil,
        "new game routes through scene stack to a fresh PlayScene")

    print("  menu_scene: OK")
end

return M
