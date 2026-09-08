-- game/packs.lua
-- Pure booster-pack state. Opening reveals deterministic choices; choosing is
-- a separate action so a purchase never silently grants a consumable.

local tarots = require("game.tarots")

local M = {}

M.DEFINITIONS = {
    arcana_pack = {
        id = "arcana_pack",
        name = "아르카나 팩",
        choice_count = 3,
        choose = 1,
    },
}

local function definition(id)
    local found = M.DEFINITIONS[id]
    if not found then
        error("unknown pack: " .. tostring(id))
    end
    return found
end

local function shop_rng(state)
    local random = state.rng and state.rng.shop
    if type(random) ~= "function" then
        error("pack requires run_state.rng.shop")
    end
    return random
end

local function tarot_choice(def)
    return {
        id = def.id,
        name = def.name,
        effect = def.effect,
    }
end

function M.open(state, id)
    if type(state) ~= "table" then
        error("pack requires run state")
    end
    if state.pending_pack then
        error("a pack is already open")
    end

    local def = definition(id)
    local random = shop_rng(state)
    local pending = {
        id = def.id,
        name = def.name,
        choose = def.choose,
        choices = {},
    }
    for i = 1, def.choice_count do
        pending.choices[i] = tarot_choice(tarots.POOL[random(1, #tarots.POOL)])
    end
    state.pending_pack = pending
    return pending
end

function M.choose(state, index)
    local pending = state and state.pending_pack
    if not pending then
        error("no pack is open")
    end
    local choice = pending.choices[index]
    if not choice then
        error("pack choice out of range")
    end

    local gained = tarots.gain(state, choice.id, "shop")
    state.pending_pack = nil
    return gained
end

function M.skip(state)
    local pending = state and state.pending_pack
    if not pending then
        error("no pack is open")
    end
    state.pending_pack = nil
    return pending
end

return M