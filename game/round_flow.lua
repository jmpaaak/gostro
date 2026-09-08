local run_rules = require("game.run_rules")
local plaques = require("game.plaques")
local round_targets = require("game.round_targets")
local boss_rounds = require("game.boss_rounds")
local economy = require("game.economy")
local seals = require("game.seals")
local run_history = require("game.run_history")

local M = {}

local KINDS = { "small", "big", "boss" }
local VALID_KIND = { small = true, big = true, boss = true }

--- Choose and copy the current go's final-round definition into mutable run state.
function M.select_boss(state, boss_id)
    if state.blind ~= "boss" then
        error("select_boss only on final rounds")
    end
    local stream = state.rng and state.rng.boss
    local definition = boss_id and boss_rounds.by_id(boss_id) or boss_rounds.random(stream)
    state.boss_id = definition.id
    state.boss = {
        id = definition.id,
        name = definition.name,
        effect = definition.effect,
        kind = definition.kind,
        amount = definition.amount,
    }
    return definition
end

--- Enter a round, selecting a boss when needed and clearing stale boss state otherwise.
function M.enter(state, kind, boss_id)
    if not VALID_KIND[kind] then error("unknown round") end
    state.blind = kind
    if kind == "boss" then
        if boss_id or not state.boss then
            M.select_boss(state, boss_id)
        end
    else
        state.boss_id = nil
        state.boss = nil
    end
    return {
        kind = kind,
        boss = state.boss_id and { id = state.boss_id } or nil,
    }
end

--- Project the gameplay target for a round without mutating run progression.
-- This is the shared target contract for selection UI, transitions, and rounds.
function M.target(state, kind)
    kind = kind or state.blind
    local projected = {}
    for key, value in pairs(state) do
        projected[key] = value
    end
    projected.blind = kind
    if kind ~= "boss" then
        projected.boss_id = nil
        projected.boss = nil
    elseif state.blind ~= "boss" then
        projected.boss_id = nil
        projected.boss = nil
    end
    return run_rules.adjust_target(state, round_targets.target(projected))
end

function M.view(state, plaque_id)
    if plaque_id then plaques.by_id(plaque_id) end
    local rounds = {}
    local model = {
        go = state.ante,
        current_round = state.blind,
        rounds = rounds,
        ante = state.ante,
        current = state.blind,
        phase = state.phase,
        blinds = rounds,
    }

    local found_current = false
    for index, kind in ipairs(KINDS) do
        local status = "upcoming"
        if kind == state.blind then
            status = "current"
            found_current = true
        elseif not found_current then
            status = "completed"
        end

        local skippable = false
        if status == "current" and kind ~= "boss" and plaque_id and state.phase == "play" then
            skippable = true
        end

        local b = {
            kind = kind,
            target = M.target(state, kind),
            playable = state.phase == "play" and status == "current",
            status = status,
            skippable = skippable,
        }
        if skippable then
            b.skip_plaque = plaques.by_id(plaque_id)
            b.skip_tag = b.skip_plaque -- legacy projection alias
        end
        if kind == "boss" and state.boss_id then
            b.boss = { id = state.boss_id }
        end
        model.rounds[index] = b
    end
    return model
end

function M.select(state, kind, boss_id)
    if state.phase ~= "play" then
        error("cannot select outside play")
    end
    if kind ~= state.blind then
        error("cannot jump to " .. kind)
    end
    if kind == "boss" and boss_id then
        M.select_boss(state, boss_id)
    end
    local target = M.target(state, kind)
    return {
        kind = kind,
        target = target,
        playable = true,
        boss = state.boss_id and { id = state.boss_id } or nil,
    }
end

--- Enter the current round and return the rules needed by the scene.
-- Round progression remains validated here; the scene only constructs its UI.
function M.begin(state, kind, boss_id)
    local selected = M.select(state, kind, boss_id)
    state.phase = "play"
    state.round_score = 0
    selected.discards = run_rules.discard_limit(state, 3)
    return selected
end

--- Apply one scored hand and mirror the round engine's remaining hands.
function M.score(state, amount, hands_left)
    if state.phase ~= "play" then
        error("score only during play")
    end
    state.round_score = state.round_score + amount
    state.hands_left = hands_left
    return state.round_score
end

--- Clear the current round once its adjusted target is met.
-- Returns the resulting run phase, or nil while the target is unmet.
function M.clear(state, hands_left)
    if state.phase ~= "play" then
        error("cannot clear outside play")
    end
    if state.round_score < M.target(state, state.blind) then
        return nil
    end
    if hands_left ~= nil then state.hands_left = hands_left end
    economy.cash_out(state)
    if state.ante >= round_targets.FINAL_GO and state.blind == "boss" then
        state.phase = "won"
        run_history.record(state, "won")
    else
        state.phase = "shop"
        local shop_rng = state.rng and state.rng.shop
        seals.stock_shop(state, shop_rng)
    end
    return state.phase
end

--- End the current round after the round engine exhausts every hand.
function M.lose(state, hands_left)
    if state.phase ~= "play" then
        error("cannot lose outside play")
    end
    if hands_left ~= 0 then
        error("cannot lose with hands remaining")
    end
    if state.round_score >= M.target(state, state.blind) then
        error("cannot lose a cleared blind")
    end
    state.hands_left = hands_left
    state.phase = "lost"
    run_history.record(state, "lost")
    return state.phase
end

--- Advance from the shop and describe the next selectable round.
function M.leave_shop(state)
    if state.phase ~= "shop" then
        error("leave shop only from shop")
    end
    if state.blind == "small" then
        M.enter(state, "big")
    elseif state.blind == "big" then
        M.enter(state, "boss")
    elseif state.blind == "boss" then
        state.ante = state.ante + 1
        M.enter(state, "small")
    else
        error("unknown blind")
    end
    state.phase = "play"
    state.round_score = 0
    local upgrades = state.seals or state.vouchers
    local extra_hands = upgrades and upgrades.hands or 0
    state.hands_left = 4 + extra_hands
    seals.clear_shop(state)
    return {
        go = state.ante,
        round = state.blind,
        ante = state.ante,
        kind = state.blind,
        phase = state.phase,
    }
end

function M.skip(state, kind, plaque_id)
    if state.phase ~= "play" then error("skip only during play") end
    if not plaque_id then error("skip requires a plaque") end
    if kind == "boss" then error("boss cannot skip") end
    if kind ~= "small" and kind ~= "big" then error("unknown blind") end
    if kind ~= state.blind then error("cannot skip a future blind") end
    local definition = plaques.by_id(plaque_id) -- validate before mutating the run

    plaques.apply(state, plaque_id)
    local next_kind = kind == "small" and "big" or "boss"
    M.enter(state, next_kind)
    state.round_score = 0
    return {
        go = state.ante,
        round = state.blind,
        ante = state.ante,
        kind = state.blind,
        phase = state.phase,
        plaque_id = definition.id,
        tag_id = plaque_id, -- legacy result alias
        boss = state.boss_id and { id = state.boss_id } or nil,
    }
end

--- Compatibility entry point for callers that historically omitted a reward id.
function M.skip_current(state, plaque_id)
    local selected_plaque = plaque_id or plaques.random().id
    return M.skip(state, state.blind, selected_plaque)
end

return M
