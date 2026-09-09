-- game/tests/scoreboard_ui.lua
-- Headless tests for game/ui/scoreboard.lua

local scoreboard = require("game.ui.scoreboard")
local run = require("game.run")

local M = {}

function M.run()
    require("game.tests.score_icon_art").run()

    -- new() returns a valid scoreboard state
    local sb = scoreboard.new()
    assert(sb.chips == 0, "initial chips == 0")
    assert(sb.mult == 1, "initial mult == 1")
    assert(sb.displayed_score == 0, "initial displayed score == 0")
    assert(sb.target == 0, "initial target == 0")
    assert(sb.popup == nil, "no popup initially")

    -- set_target: bind blind target
    local rs = run.new()
    scoreboard.set_target(sb, run.blind_target(rs))
    assert(sb.target == 300, "ante1 small target == 300")

    -- set_hand_result: chips × mult = score, waits for anim before countup
    scoreboard.set_hand_result(sb, 50, 2)
    assert(sb.chips == 50, "chips set")
    assert(sb.mult == 2, "mult set")
    assert(sb.countup ~= nil, "hand result starts a countup tween")
    assert(sb.countup.waiting == true, "countup waits for the total phase")
    assert(sb.displayed_score == 0, "countup starts from the previous total")
    assert(sb.popup == nil, "popup waits until the total phase")
    assert(sb.display_chips == 0 and sb.display_mult == 1)

    scoreboard.sync_anim(sb, { phase = "cards", chips_shown = 50 })
    assert(sb.display_chips == 50 and sb.display_mult == 1)
    scoreboard.update(sb, 10)
    assert(sb.displayed_score == 0, "waiting countup does not tick")

    scoreboard.sync_anim(sb, { phase = "mult" })
    assert(sb.display_chips == 50 and sb.display_mult == 2)

    scoreboard.sync_anim(sb, { phase = "total", displayed_total = 0 })
    assert(sb.countup.waiting == false)
    assert(sb.popup and sb.popup.live == true)
    scoreboard.sync_anim(sb, { phase = "done", displayed_total = 100 })
    assert(sb.displayed_score == 100, "countup settles on the scored total")
    assert(sb.countup == nil)

    assert(sb.popup ~= nil, "popup created")
    assert(sb.popup.value == 100, "popup value matches score")
    assert(sb.popup.timer > 0, "popup timer starts positive")

    -- accumulate: add more hand results
    scoreboard.set_hand_result(sb, 30, 3)
    scoreboard.sync_anim(sb, { phase = "done", displayed_total = 90 })
    assert(sb.displayed_score == 190, "100 + 30×3 = 190")

    -- progress_ratio: score vs target
    local ratio = scoreboard.progress_ratio(sb)
    assert(ratio > 0.63 and ratio < 0.64,
        "190/300 ≈ 0.633, got " .. tostring(ratio))

    -- progress clamped at 1.0 when score >= target
    scoreboard.set_hand_result(sb, 200, 1)
    scoreboard.sync_anim(sb, { phase = "done", displayed_total = 200 })
    ratio = scoreboard.progress_ratio(sb)
    assert(ratio == 1.0, "clamped at 1.0 when over target")
    assert(sb.displayed_score == 390, "total 390")

    -- reset clears everything
    scoreboard.reset(sb)
    assert(sb.chips == 0)
    assert(sb.mult == 1)
    assert(sb.displayed_score == 0)
    assert(sb.popup == nil)
    assert(sb.preview == nil)
    assert(sb.target == 0)

    local box = scoreboard.layout()
    assert(box.x == 12 and box.y == 124, "scoreboard is below the full-height gwang row")
    assert(box.x + box.w <= 480, "scoreboard stays on the left half")

    -- update ticks popup timer down
    scoreboard.set_target(sb, 300)
    scoreboard.set_hand_result(sb, 10, 1)
    scoreboard.sync_anim(sb, { phase = "done", displayed_total = 10 })
    assert(sb.popup ~= nil)
    local initial_timer = sb.popup.timer
    scoreboard.update(sb, 0.5)
    assert(sb.popup.timer < initial_timer, "popup timer decreased")

    -- popup disappears when timer <= 0
    scoreboard.update(sb, 100)
    assert(sb.popup == nil, "popup cleared after timer expires")

    -- format_score_text
    local txt = scoreboard.format_score_text(42, 3)
    assert(txt == "42 × 3 = 126", "format: got '" .. txt .. "'")

    print("  scoreboard_ui: OK")
end

return M
