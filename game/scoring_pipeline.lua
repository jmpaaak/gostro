-- Pure scoring orchestration for the play scene.
--
-- The mechanics run in this deterministic order:
--   1. score-time boss validation (Psychic)
--   2. hwatu.evaluate(hand, run_state), which owns base/yaku, wish-card,
--      edition, and gwang ordering (including money/once state changes)
--   3. one score-mutating boss hook (Flint/Goad/Plant)
--   4. final score event
--
-- This module does not add the score to run_state. The caller owns that commit.

local hwatu = require("game.hwatu")
local wish_cards = require("game.wish_cards")
local boss_blinds = require("game.boss_blinds")

local M = {}

local SCORE_BOSS_EFFECTS = {
    halve_score = true,
    score_only_kind = true,
    debuff_kind = true,
}

local function active_boss(state)
    if type(state) ~= "table" or state.blind ~= "boss" then
        return nil
    end
    if type(state.boss) == "table" then
        return state.boss
    end
    if state.boss_id then
        return boss_blinds.by_id(state.boss_id)
    end
    return nil
end

local function copy_cards(hand)
    local out = {}
    for i = 1, #hand do
        local card = hand[i]
        out[i] = { kind = card.kind, effect = card.effect }
    end
    return out
end

local function copy_list(values)
    local out = {}
    for i = 1, #(values or {}) do
        out[i] = values[i]
    end
    return out
end

local function append_mechanic_events(events, hand, state, result)
    events[#events + 1] = {
        type = "hand",
        cards = copy_cards(hand),
        yaku = copy_list(result.yaku),
    }

    -- Wish-card application is owned by hwatu.evaluate. These events only expose
    -- the applied levels to animation; they never recalculate or reapply it.
    if type(state) == "table" then
        for i = 1, #(result.yaku or {}) do
            local yaku = result.yaku[i]
            local level = wish_cards.get_level(state, yaku)
            if level > 1 then
                events[#events + 1] = {
                    type = "wish_card",
                    legacy_type = "planet",
                    yaku = yaku,
                    level = level,
                }
            end
        end
    end

    if (result.effect_chips or 0) ~= 0
        or (result.effect_mult_add or 0) ~= 0
        or (result.effect_mult_mul or 1) ~= 1 then
        events[#events + 1] = {
            type = "edition",
            chips = result.effect_chips or 0,
            mult_add = result.effect_mult_add or 0,
            mult_mul = result.effect_mult_mul or 1,
        }
    end

    for i = 1, #(result.gwang_triggers or {}) do
        local trigger = result.gwang_triggers[i]
        events[#events + 1] = {
            type = "gwang",
            id = trigger.id,
            identity = trigger.id,
            slot = trigger.slot,
        }
    end
end

--- Score one played hand without committing it to the run's round score.
-- Stateful gwang effects are intentionally committed inside hwatu.evaluate,
-- their existing owner; calling any lower-level gwang/edition API here would
-- apply those mechanics twice.
--
-- Returns result (including result.events), or nil, reason when a score-time
-- boss validation rejects the hand.
function M.score(hand, run_state, opts)
    opts = opts or {}
    local boss = active_boss(run_state)

    -- Validate before evaluate: an invalid Psychic play must not grant money
    -- or consume an equipped once-trigger gwang.
    if boss and boss.effect == "full_hand" then
        local outcome = boss_blinds.apply(boss, { n = type(hand) == "table" and #hand or 0 })
        if not outcome.allowed then
            return nil, outcome.err
        end
    end

    -- This is the sole call that applies wish-card, edition, and gwang mechanics.
    local result = hwatu.evaluate(hand, run_state)
    local events = {}
    append_mechanic_events(events, hand, run_state, result)

    -- Hand-management and target bosses are applied by their respective play
    -- paths. Only score-mutating bosses belong in this pipeline.
    if boss and SCORE_BOSS_EFFECTS[boss.effect] then
        local outcome = boss_blinds.apply(boss, {
            hand = hand,
            result = result,
            rng = opts.rng,
        })
        local scored = outcome.result
        result.chips = scored.chips
        result.mult = scored.mult
        result.score = scored.score
        events[#events + 1] = {
            type = "boss",
            id = boss.id,
            effect = boss.effect,
            chips = result.chips,
            mult = result.mult,
        }
    end

    events[#events + 1] = {
        type = "score",
        chips = result.chips,
        mult = result.mult,
        score = result.score,
    }
    result.events = events
    return result
end

-- `evaluate` is the scene-facing spelling; `score` is the concise API name.
M.evaluate = M.score

return M
