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
    assert(menu_scene:mousepressed(x, y, 1) == "select_continue", "continue reports select action")
    assert(stack.current == menu_scene, "continue never silently starts a new run")
    x, y = center(submenu[3])
    assert(menu_scene:mousepressed(x, y, 1) == "select_challenges", "challenges reports select action")
    assert(stack.current == menu_scene, "challenges never silently starts a new run")

    x, y = center(submenu[1])
    assert(menu_scene:mousepressed(x, y, 1) == "select_new_game", "new game tab action is returned")
    -- We can no longer assert that clicking the 'new_game' tab starts the game directly.
    -- Starting a game now happens via the 'play' button in run_setup UI.
    -- But run_setup is not fully integrated into menu.lua yet.
    -- So for now, we just assert that stack.current is still menu_scene.
    assert(stack.current == menu_scene, "new game tab selects tab, does not start run yet")

    print("  menu_scene: OK")
end

return M
