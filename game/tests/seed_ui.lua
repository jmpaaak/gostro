-- Headless tests for game/ui/seed.lua (INBOX 22, seed display + input).
-- No month numbers/names. Engine-hosted.

local seed_ui = require("game.ui.seed")
local rng = require("game.rng")

local M = {}

function M.run()
    M.test_new_displays_seed()
    M.test_new_from_run()
    M.test_set_seed_normalizes()
    M.test_unfocused_ignores_keys()
    M.test_type_and_backspace()
    M.test_confirm_applies_normalized_seed()
    M.test_empty_confirm_generates()
    M.test_hit_test_field()
    M.test_label()
    M.test_play_scene_shows_and_applies_seed()
    print("  seed_ui: OK")
end

function M.test_new_displays_seed()
    local s = seed_ui.new("abcd12ef")
    assert(s.seed == "ABCD12EF", "display is uppercase, got " .. tostring(s.seed))
    assert(s.input == "", "input buffer empty until focused typing")
    assert(s.focused == false, "starts unfocused")
end

function M.test_new_from_run()
    local run = require("game.run")
    local state = run.new("run-seed-01")
    local s = seed_ui.new(state.seed)
    assert(s.seed == "RUNSEED01")
    assert(seed_ui.display(s) == "RUNSEED01")
end

function M.test_set_seed_normalizes()
    local s = seed_ui.new("AAAA0000")
    seed_ui.set_seed(s, " gostro-01 ")
    assert(s.seed == "GOSTRO01")
    assert(s.input == "")
    assert(s.focused == false)
end

function M.test_unfocused_ignores_keys()
    local s = seed_ui.new("SEEDTEST")
    assert(seed_ui.keypressed(s, "a") == nil)
    assert(s.input == "")
    assert(s.seed == "SEEDTEST")
end

function M.test_type_and_backspace()
    local s = seed_ui.new("SEEDTEST")
    seed_ui.focus(s)
    assert(s.focused == true)
    assert(s.input == "")
    seed_ui.keypressed(s, "a")
    seed_ui.keypressed(s, "b")
    seed_ui.keypressed(s, "1")
    seed_ui.keypressed(s, "-") -- stripped
    seed_ui.keypressed(s, "c")
    assert(s.input == "AB1C", "typed A-Z0-9 only, got " .. tostring(s.input))
    seed_ui.keypressed(s, "backspace")
    assert(s.input == "AB1")
    -- cap at 8
    for _ = 1, 10 do
        seed_ui.keypressed(s, "z")
    end
    assert(#s.input == 8)
    assert(s.input == "AB1ZZZZZ")
    seed_ui.unfocus(s)
    assert(s.focused == false)
    assert(s.input == "")
end

function M.test_confirm_applies_normalized_seed()
    local s = seed_ui.new("OLDSEED1")
    seed_ui.focus(s)
    seed_ui.keypressed(s, "n")
    seed_ui.keypressed(s, "e")
    seed_ui.keypressed(s, "w")
    seed_ui.keypressed(s, "1")
    local applied = seed_ui.keypressed(s, "return")
    assert(applied == "NEW1", "confirm returns normalized seed, got " .. tostring(applied))
    assert(s.seed == "NEW1")
    assert(s.focused == false)
    assert(s.input == "")
end

function M.test_empty_confirm_generates()
    local s = seed_ui.new("OLDSEED1")
    seed_ui.focus(s)
    local applied = seed_ui.keypressed(s, "return")
    assert(type(applied) == "string" and #applied == 8)
    assert(applied:match("^[A-Z0-9]+$"))
    assert(s.seed == applied)
    assert(s.focused == false)
    -- generated seed is rng-normalize compatible
    assert(rng.normalize(applied) == applied)
end

function M.test_hit_test_field()
    local s = seed_ui.new("HITTEST1")
    local box = seed_ui.field_rect()
    assert(box.w > 0 and box.h > 0)
    assert(seed_ui.hit_test(s, box.x + 1, box.y + 1) == "field")
    assert(seed_ui.hit_test(s, -1, -1) == nil)
end

function M.test_label()
    local s = seed_ui.new("LABEL001")
    local txt = seed_ui.label(s)
    assert(txt:find("LABEL001", 1, true), "label shows seed")
    assert(not txt:lower():find("month", 1, true))
end

function M.test_play_scene_shows_and_applies_seed()
    local play = require("game.scenes.play")
    local scene = play.new("run-seed-01")
    assert(scene.run_state.seed == "RUNSEED01")
    assert(scene.seed.seed == "RUNSEED01")
    play.apply_seed(scene, "new-seed")
    assert(scene.run_state.seed == "NEWSEED")
    assert(scene.seed.seed == "NEWSEED")
    assert(scene.state == "blind_select")
end

return M
