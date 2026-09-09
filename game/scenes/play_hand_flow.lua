-- Play / discard hand timing: gather, score, then redeal.
-- Scene code only requires this; it does not grow play.lua.

local round_engine = require("game.round_engine")
local scoring = require("game.scoring_pipeline")
local blind_flow = require("game.blind_flow")
local hand_ui = require("game.ui.hand")
local scoreboard_ui = require("game.ui.scoreboard")
local buttons_ui = require("game.ui.action_buttons")
local score_anim_ui = require("game.ui.score_anim")
local hwatu = require("game.hwatu")

local M = {}

local function selected_indices(scene)
    local indices = {}
    for i, idx in ipairs(scene.hand.selected_order) do
        indices[i] = idx
    end
    return indices
end

function M.reset(scene)
    scene.pending_redeal = nil
    scene.pending_discard = nil
    scene.pending_lose = nil
end

function M.busy(scene)
    if scene.hand and (scene.hand.gather or scene.hand.slide) then
        return true
    end
    if scene.pending_discard or scene.pending_redeal then
        return true
    end
    return scene.score_anim and score_anim_ui.is_playing(scene.score_anim)
end

function M.play_hand(scene, sync_preview)
    if scene.state ~= "playing" then return false end
    if M.busy(scene) then return false end
    local indices = selected_indices(scene)
    local cards = {}
    for i, idx in ipairs(indices) do
        cards[i] = scene.round.hand[idx]
    end
    if not round_engine.can_play(scene.round, indices) then return false end

    local result = scoring.score(cards, scene.run_state, { rng = scene.run_state.rng.cards })
    if not result then return false end
    local gather = hand_ui.start_gather(scene.hand)
    local anim_cards = {}
    for i = 1, #cards do
        local dest = gather and gather.cards[i]
        local widget = scene.hand.cards[indices[i]]
        anim_cards[i] = {
            kind = cards[i].kind,
            chips = hwatu.chips_of(cards[i].kind) or 0,
            anchor = widget,
            x = dest and dest.to_x or (widget and widget.x),
            y = dest and dest.to_y or (widget and widget.y),
        }
    end
    local transition = round_engine.play(scene.round, indices, result)

    blind_flow.score(scene.run_state, result.score, scene.round.hands_left)
    scoreboard_ui.set_hand_result(scene.scoreboard, result.chips, result.mult)
    if not scene.score_anim then scene.score_anim = score_anim_ui.new() end
    score_anim_ui.start(scene.score_anim, {
        cards = anim_cards,
        base_chips = result.chips,
        base_mult = result.mult,
        bonus_chips = 0,
        bonus_mult = 0,
        final_chips = result.chips,
        final_mult = result.mult,
        total = result.score,
        gwang_triggers = result.gwang_triggers or {},
    })
    scene.pending_redeal = true
    scene.pending_lose = transition == "lose"
    scene.buttons.hands_left = scene.round.hands_left
    scene.buttons.discards_left = scene.round.discards_left
    buttons_ui.set_selection(scene.buttons, 0)
    if sync_preview then sync_preview(scene) end
    return true, transition, result
end

function M.discard_hand(scene, sync_preview)
    if scene.state ~= "playing" then return false end
    if M.busy(scene) then return false end
    local indices = selected_indices(scene)
    if not round_engine.can_discard(scene.round, indices) then return false end
    if not hand_ui.start_discard_slide(scene.hand) then return false end
    scene.pending_discard = indices
    scene.buttons.discards_left = math.max(0, (scene.round.discards_left or 1) - 1)
    buttons_ui.set_selection(scene.buttons, 0)
    if sync_preview then sync_preview(scene) end
    return true
end

function M.tick(scene, dt, hooks)
    if scene.hand then hand_ui.update(scene.hand, dt) end
    if scene.score_anim then
        score_anim_ui.update(scene.score_anim, dt)
        scoreboard_ui.sync_anim(scene.scoreboard, scene.score_anim)
    end
    if scene.pending_discard and scene.hand and not scene.hand.slide then
        round_engine.discard(scene.round, scene.pending_discard)
        scene.pending_discard = nil
        hooks.sync_round_ui(scene)
    end
    local scoring = scene.score_anim and score_anim_ui.is_playing(scene.score_anim)
    if scene.pending_redeal
        and scene.hand
        and not scene.hand.gather
        and not scoring then
        hooks.sync_round_ui(scene)
        scene.pending_redeal = nil
        if scene.score_anim then score_anim_ui.dismiss(scene.score_anim) end
        if scene.pending_lose then
            blind_flow.lose(scene.run_state, scene.round.hands_left)
            scene.state = "lost"
            scene.pending_lose = nil
        else
            hooks.check_clear(scene)
        end
    end
    scoreboard_ui.update(scene.scoreboard, dt)
    buttons_ui.set_selection(scene.buttons, #scene.hand.selected_order)
    if hooks.sync_preview then hooks.sync_preview(scene) end
end

return M
