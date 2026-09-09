-- Selecting cards must preview chips x mult without consuming gwang state.

local hwatu = require("game.hwatu")
local pipeline = require("game.scoring_pipeline")
local play = require("game.scenes.play")
local run = require("game.run")
local hand_ui = require("game.ui.hand")
local buttons_ui = require("game.ui.action_buttons")

local M = {}

local function cards(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = hwatu.card((select(i, ...)))
    end
    return out
end

function M.run()
    assert(hwatu.yaku_label({}) == "바닥")
    assert(hwatu.yaku_label({ "hongdan" }) == "홍단")
    assert(hwatu.yaku_label({ "godori" }) == "고도리")

    local empty = pipeline.preview({}, run.new())
    assert(empty == nil, "no selection has no preview")

    local hongdan = pipeline.preview(cards("hongdan", "hongdan", "hongdan", "pi", "pi"), run.new())
    assert(hongdan.allowed == true)
    assert(hongdan.yaku_label == "홍단")
    assert(hongdan.chips == 32 and hongdan.mult == 2)
    assert(hongdan.score == 64)

    local none = pipeline.preview(cards("hongdan", "pi"), run.new())
    assert(none.yaku_label == "바닥")
    assert(none.mult == 1)

    local state = run.new()
    state.money = 4
    state.gwang = {
        { kind = "gwang", identity = "compound" },
        { kind = "gwang", identity = "once_x20" },
    }
    local preview = pipeline.preview(cards("pi"), state)
    assert(state.money == 4, "preview must not grant gwang money")
    assert(#state.gwang == 2 and state.gwang[2].identity == "once_x20",
        "preview must not consume once gwang")
    assert(preview.score > 1, "preview still shows once-gwang contribution")

    local played = assert(pipeline.score(cards("pi"), state))
    assert(state.money == 5, "real score still commits gwang money")
    assert(#state.gwang == 1, "real score still consumes once gwang")
    assert(played.score == preview.score, "preview matches the eventual play score")

    local scene = play.new("PREVIEW-HUD")
    play.select_blind(scene, 1)
    hand_ui.select(scene.hand, 1)
    buttons_ui.set_selection(scene.buttons, 1)
    play.sync_preview(scene)
    assert(scene.scoreboard.preview ~= nil, "selecting a card fills the scoreboard preview")
    assert(scene.scoreboard.preview.chips > 0)
    assert(type(scene.scoreboard.preview.yaku_label) == "string")
    hand_ui.deselect(scene.hand, 1)
    play.sync_preview(scene)
    assert(scene.scoreboard.preview == nil, "clearing selection clears preview")

    print("  score_preview: OK")
end

return M
