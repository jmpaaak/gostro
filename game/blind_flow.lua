local run = require("game.run")
local run_rules = require("game.run_rules")
local tags = require("game.tags")

local M = {}

local KINDS = { "small", "big", "boss" }

local function target_for(state, kind)
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
    return run_rules.adjust_target(state, run.blind_target(projected))
end

function M.view(state, tag_id)
    if tag_id then tags.by_id(tag_id) end -- validate tag
    local model = {
        ante = state.ante,
        current = state.blind,
        phase = state.phase,
        blinds = {},
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
        if status == "current" and kind ~= "boss" and tag_id and state.phase == "play" then
            skippable = true
        end

        local b = {
            kind = kind,
            target = target_for(state, kind),
            playable = state.phase == "play" and status == "current",
            status = status,
            skippable = skippable,
        }
        if skippable then
            b.skip_tag = tags.by_id(tag_id)
        end
        if kind == "boss" and state.boss_id then
            b.boss = { id = state.boss_id }
        end
        model.blinds[index] = b
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
        run.select_boss(state, boss_id)
    end
    local target = target_for(state, kind)
    return {
        kind = kind,
        target = target,
        playable = true,
        boss = state.boss_id and { id = state.boss_id } or nil,
    }
end

--- Enter the current blind and return the round rules needed by the scene.
-- Blind progression remains validated here; the scene only constructs its UI.
function M.begin(state, kind, boss_id)
    local selected = M.select(state, kind, boss_id)
    state.phase = "play"
    state.round_score = 0
    selected.discards = run_rules.discard_limit(state, 3)
    return selected
end

function M.skip(state, kind, tag_id)
    if not tag_id then error("skip requires a tag") end
    if kind == "boss" then error("boss cannot skip") end
    if kind ~= state.blind then error("cannot skip a future blind") end
    run.skip_blind(state, tag_id)
end

return M
