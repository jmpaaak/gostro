-- Scoreboard tally and center popup share the score_anim clock.

local score_anim = require("game.ui.score_anim")
local scoreboard = require("game.ui.scoreboard")

local M = {}

local function start_hand()
    local sa = score_anim.new()
    local sb = scoreboard.new()
    scoreboard.set_target(sb, 300)
    scoreboard.set_hand_result(sb, 50, 2)
    score_anim.start(sa, {
        cards = { { kind = "pi", chips = 50 } },
        base_chips = 50, base_mult = 2,
        bonus_chips = 0, bonus_mult = 0,
        final_chips = 50, final_mult = 2,
        total = 100,
        gwang_triggers = {},
    })
    return sa, sb
end

function M.run()
    local sa, sb = start_hand()
    assert(sb.popup == nil, "popup waits for the total phase")
    assert(sb.countup and sb.countup.waiting)

    score_anim.update(sa, score_anim.CARD_DELAY + 0.01)
    scoreboard.sync_anim(sb, sa)
    scoreboard.update(sb, 0)
    assert(sa.phase == "mult")
    assert(sb.displayed_score == 0, "tally still waits during mult")
    assert(sb.popup == nil, "center popup still waits during mult")
    assert(sb.display_chips == 50 and sb.display_mult == 2)

    score_anim.update(sa, score_anim.MULT_DURATION + 0.01)
    scoreboard.sync_anim(sb, sa)
    assert(sa.phase == "total")
    assert(sb.countup and sb.countup.waiting == false)
    assert(sb.popup ~= nil, "center popup starts with the countup")
    assert(sb.popup.live == true)
    assert(sb.popup.value == sa.displayed_total)
    assert(sb.displayed_score == sb.countup.from + sa.displayed_total)

    local mid_dt = score_anim.TOTAL_DURATION * 0.4
    score_anim.update(sa, mid_dt)
    scoreboard.sync_anim(sb, sa)
    scoreboard.update(sb, mid_dt)
    assert(sa.phase == "total")
    assert(sb.popup.live == true, "popup does not fade while counting")
    assert(sb.popup.value == sa.displayed_total, "popup number is the anim clock")
    assert(sb.displayed_score == sb.countup.from + sa.displayed_total,
        "left tally is the same clock")
    assert(sb.displayed_score > 0 and sb.displayed_score < 100)

    score_anim.update(sa, score_anim.TOTAL_DURATION)
    scoreboard.sync_anim(sb, sa)
    scoreboard.update(sb, 0)
    assert(sa.phase == "done")
    assert(sb.displayed_score == 100)
    assert(sb.countup == nil)
    assert(sb.popup and sb.popup.live == false)
    assert(sb.popup.value == 100)

    local timer = sb.popup.timer
    scoreboard.update(sb, 0.4)
    assert(sb.popup.timer < timer, "fade starts only after the countup")

    print("  score_timeline: OK")
end

return M
