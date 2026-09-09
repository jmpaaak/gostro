-- Play HUD geometry: Balatro-style left score, side buttons, no overlap.

local action_buttons = require("game.ui.action_buttons")
local card = require("game.ui.card")
local consumables_ui = require("game.ui.consumables")
local gwang_slots = require("game.ui.gwang_slots")
local hand = require("game.ui.hand")
local planets_ui = require("game.ui.planets_ui")
local run = require("game.run")
local scoreboard = require("game.ui.scoreboard")
local seed_ui = require("game.ui.seed")
local tarots = require("game.tarots")

local M = {}

local function overlaps(a, b)
    return a.x < b.x + b.w and b.x < a.x + a.w
        and a.y < b.y + b.h and b.y < a.y + a.h
end

local function rect(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function M.run()
    local sb = scoreboard.layout()
    assert(sb.x < 480, "scoreboard sits on the left half")
    assert(sb.x + sb.w <= 480, "scoreboard does not cross center into consumables")
    assert(sb.y >= 104, "scoreboard sits below the gwang row")
    assert(sb.x + sb.w <= 960 and sb.y + sb.h <= 540, "scoreboard stays on canvas")

    local play_btn = rect(action_buttons.PLAY_X, action_buttons.BUTTON_Y,
        action_buttons.BUTTON_W, action_buttons.BUTTON_H)
    local discard_btn = rect(action_buttons.DISCARD_X, action_buttons.BUTTON_Y,
        action_buttons.BUTTON_W, action_buttons.BUTTON_H)
    assert(play_btn.x + play_btn.w < 280, "play button is left of the hand fan")
    assert(discard_btn.x > 680, "discard button is right of the hand fan")

    local h = hand.new()
    hand.deal(h, { "pi", "pi", "pi", "pi", "pi", "pi", "pi", "pi" })
    local fan = rect(h.cards[1].x, h.cards[1].y,
        h.cards[8].x + card.WIDTH - h.cards[1].x, card.HEIGHT + card.LIFT)
    assert(not overlaps(play_btn, fan), "play button must not cover the hand")
    assert(not overlaps(discard_btn, fan), "discard button must not cover the hand")
    assert(not overlaps(sb, fan), "scoreboard must not cover the hand")

    local slots = gwang_slots.slot_positions()
    for i = 1, #slots do
        assert(not overlaps(sb, slots[i]), "scoreboard must not cover gwang slot " .. i)
        assert(not overlaps(play_btn, slots[i]), "play button must not cover gwang slot " .. i)
    end

    local state = run.new("HUD-LAYOUT")
    tarots.gain(state, "the_magician", "shop")
    local view = consumables_ui.view(state)
    for _, slot in ipairs(view.slots) do
        assert(not overlaps(sb, slot.bounds), "scoreboard must not cover consumable slots")
        assert(slot.bounds.x >= 480, "consumables stay on the right half")
    end

    local seed = seed_ui.field_rect()
    assert(seed.w >= 200 and seed.h >= 33, "seed field is readable at 960x540")
    assert(not overlaps(seed, sb), "seed field must not cover the scoreboard")

    local planets = planets_ui.layout()
    assert(planets.y >= sb.y + sb.h, "planet levels sit below the scoreboard")
    assert(not overlaps(planets, fan), "planet list must not cover the hand")

    print("  play_hud_layout: OK")
end

return M
