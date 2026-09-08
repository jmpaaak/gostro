-- game/tests/action_buttons_ui.lua
-- Headless tests for game/ui/action_buttons.lua

local action_buttons = require("game.ui.action_buttons")

local M = {}

function M.run()
    -- new() returns valid initial state
    local ab = action_buttons.new()
    assert(ab.hands_left == 4, "default 4 hands, got " .. tostring(ab.hands_left))
    assert(ab.discards_left == 3, "default 3 discards, got " .. tostring(ab.discards_left))
    assert(ab.play_enabled == false, "play disabled initially (no selection)")
    assert(ab.discard_enabled == false, "discard disabled initially (no selection)")

    -- new() with custom counts
    local ab2 = action_buttons.new(5, 2)
    assert(ab2.hands_left == 5, "custom hands")
    assert(ab2.discards_left == 2, "custom discards")

    -- enable/disable based on selection count
    action_buttons.set_selection(ab, 3)
    assert(ab.play_enabled == true, "play enabled when cards selected")
    assert(ab.discard_enabled == true, "discard enabled when cards selected")

    action_buttons.set_selection(ab, 0)
    assert(ab.play_enabled == false, "play disabled when no selection")
    assert(ab.discard_enabled == false, "discard disabled when no selection")

    -- use_hand decrements hands_left
    action_buttons.set_selection(ab, 2)
    local ok = action_buttons.use_hand(ab)
    assert(ok == true, "use_hand succeeds")
    assert(ab.hands_left == 3, "hands decremented to 3")

    -- use_hand fails when hands_left == 0
    ab.hands_left = 0
    local ok2 = action_buttons.use_hand(ab)
    assert(ok2 == false, "use_hand fails at 0")
    assert(ab.hands_left == 0, "stays at 0")

    -- use_hand fails when no selection
    ab.hands_left = 2
    action_buttons.set_selection(ab, 0)
    local ok3 = action_buttons.use_hand(ab)
    assert(ok3 == false, "use_hand fails with no selection")

    -- use_discard decrements discards_left
    action_buttons.set_selection(ab, 1)
    local ok4 = action_buttons.use_discard(ab)
    assert(ok4 == true, "use_discard succeeds")
    assert(ab.discards_left == 2, "discards decremented to 2")

    -- use_discard fails when discards_left == 0
    ab.discards_left = 0
    local ok5 = action_buttons.use_discard(ab)
    assert(ok5 == false, "use_discard fails at 0")

    -- use_discard fails when no selection
    ab.discards_left = 2
    action_buttons.set_selection(ab, 0)
    local ok6 = action_buttons.use_discard(ab)
    assert(ok6 == false, "use_discard fails with no selection")

    -- reset restores counts
    ab.hands_left = 1
    ab.discards_left = 0
    action_buttons.reset(ab, 4, 3)
    assert(ab.hands_left == 4, "reset hands")
    assert(ab.discards_left == 3, "reset discards")

    -- hit_test: play button
    local btn = action_buttons.hit_test(ab, action_buttons.PLAY_X + 5, action_buttons.BUTTON_Y + 5)
    assert(btn == "play", "hit play button, got " .. tostring(btn))

    -- hit_test: discard button
    btn = action_buttons.hit_test(ab, action_buttons.DISCARD_X + 5, action_buttons.BUTTON_Y + 5)
    assert(btn == "discard", "hit discard button, got " .. tostring(btn))

    -- hit_test: miss
    btn = action_buttons.hit_test(ab, 0, 0)
    assert(btn == nil, "miss returns nil")

    -- display_text for play button
    local txt = action_buttons.display_text(ab, "play")
    assert(txt:find("놓기"), "play text contains 놓기")
    assert(txt:find(tostring(ab.hands_left)), "play text shows count")

    -- display_text for discard button
    txt = action_buttons.display_text(ab, "discard")
    assert(txt:find("버리기"), "discard text contains 버리기")
    assert(txt:find(tostring(ab.discards_left)), "discard text shows count")

    print("  action_buttons_ui: OK")
end

return M
