local main_menu = require("game.ui.main_menu")
local run_setup = require("game.ui.run_setup")
local MenuScene = require("game.scenes.menu")
local scene_stack = require("game.scene_stack")

local M = {}

local function center(rect)
    return rect.x + rect.w / 2, rect.y + rect.h / 2
end

local function press(scene, rect)
    local x, y = center(rect)
    return scene:mousepressed(x, y, 1)
end

function M.run()
    local menu_scene = MenuScene.new("ROUTE123")
    local stack = scene_stack.new(menu_scene)
    menu_scene:bind(stack)

    local landing = main_menu.buttons(menu_scene.ui)[1]
    local x, y = center(landing)
    assert(menu_scene:mousepressed(x, y, 2) == nil, "non-primary mouse presses are ignored")
    assert(menu_scene.ui.mode == "landing", "ignored input does not change the scene")
    assert(menu_scene:mousepressed(x, y, 1) == "open_play_menu", "landing tap opens the tab panel")
    assert(stack.current == menu_scene and menu_scene.ui.mode == "play_menu",
        "opening the panel does not replace the scene")
    assert(menu_scene.setup and run_setup.selected_deck(menu_scene.setup).id == "hwatu",
        "menu owns a default New Run setup")

    local tabs = main_menu.tabs(menu_scene.ui)
    assert(press(menu_scene, tabs[2]) == "select_continue", "continue selects its tab")
    assert(stack.current == menu_scene, "continue never silently starts a run")
    assert(press(menu_scene, tabs[3]) == "select_challenges", "challenges selects its tab")
    assert(stack.current == menu_scene, "challenges never silently starts a run")
    assert(press(menu_scene, tabs[1]) == "select_new_game", "new game selects setup tab")
    assert(stack.current == menu_scene, "selecting New Run does not start until PLAY")
    local original_draw = run_setup.draw
    local drew_setup = false
    run_setup.draw = function(state)
        assert(state == menu_scene.setup, "scene draws its owned setup state")
        drew_setup = true
    end
    menu_scene:draw()
    run_setup.draw = original_draw
    assert(drew_setup, "New Run selection routes rendering to run setup")

    local controls = run_setup.layout()
    assert(press(menu_scene, controls.deck_left) == "deck_changed", "deck arrow is routed to setup")
    assert(run_setup.can_play(menu_scene.setup) == false, "wrapped locked deck disables PLAY")
    assert(press(menu_scene, controls.play) == "locked", "locked PLAY reports feedback")
    assert(stack.current == menu_scene, "locked PLAY cannot replace the menu scene")

    assert(press(menu_scene, controls.deck_right) == "deck_changed", "deck can return to unlocked default")
    assert(run_setup.set_seed(menu_scene.setup, "route-123") == "ROUTE123", "setup seed is normalized")
    assert(press(menu_scene, controls.seeded) == "seed_on", "seed toggle is routed")
    assert(press(menu_scene, controls.play) == "start_run", "valid PLAY starts the run")
    assert(stack.current ~= menu_scene and stack.current.state == "blind_select",
        "valid PLAY switches to a fresh PlayScene")
    assert(stack.current.run_state.seed == "ROUTE123", "selected seeded-run seed reaches PlayScene")
    assert(stack.current.run_state.starting_deck_id == "hwatu", "selected deck id reaches run state")
    assert(stack.current.run_state.stake_id == "white", "selected stake id reaches run state")
    assert(stack.current.round_select == stack.current.blind_select,
        "play scene exposes round selection while preserving its legacy alias")

    local thin_menu = MenuScene.new()
    local thin_stack = scene_stack.new(thin_menu)
    thin_menu:bind(thin_stack)
    press(thin_menu, main_menu.buttons(thin_menu.ui)[1])
    assert(press(thin_menu, controls.deck_right) == "deck_changed")
    assert(run_setup.selected_deck(thin_menu.setup).id == "thin")
    assert(press(thin_menu, controls.play) == "start_run")
    assert(thin_stack.current.run_state.starting_deck_id == "thin")
    assert(#thin_stack.current.run_state.deck.cards == 32,
        "the selected deck changes the finite gameplay deck, not just metadata")

    print("  menu_scene: OK")
end

return M
