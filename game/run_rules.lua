-- Pure New Run configuration rules.
-- Owns gameplay definitions while UI modules only choose their ids.

local M = {}

M.DECKS = {
    { id = "hwatu", unlocked = true },
    { id = "thin", unlocked = true },
    { id = "gwang_jackpot", unlocked = false },
}

-- Ordered weakest-to-strongest so later tiers can inherit earlier effects.
M.STAKES = {
    {
        id = "white",
        unlocked = true,
        effects = { target_multiplier = 1, economy_multiplier = 1, discard_delta = 0 },
    },
    {
        id = "red",
        unlocked = false,
        effects = { target_multiplier = 1.25, economy_multiplier = 0.75, discard_delta = -1 },
    },
}

local function index_by_id(entries)
    local result = {}
    for i = 1, #entries do
        result[entries[i].id] = entries[i]
    end
    return result
end

local DECK_BY_ID = index_by_id(M.DECKS)
local STAKE_BY_ID = index_by_id(M.STAKES)

local function is_unlocked(definition, unlocked)
    if definition.unlocked then return true end
    return type(unlocked) == "table" and unlocked[definition.id] == true
end

--- Validate and canonicalize a New Run selection without mutating input.
-- unlocks may contain unlocked_decks and unlocked_stakes id sets.
function M.validate(config, unlocks)
    if type(config) ~= "table" then
        return nil, "new-run configuration must be a table"
    end
    local deck_id = config.starting_deck_id or config.deck_id
    local stake_id = config.stake_id
    local deck_def = DECK_BY_ID[deck_id]
    if not deck_def then return nil, "unknown starting deck: " .. tostring(deck_id) end
    if not is_unlocked(deck_def, unlocks and unlocks.unlocked_decks) then
        return nil, "starting deck is locked: " .. tostring(deck_id)
    end
    local stake_def = STAKE_BY_ID[stake_id]
    if not stake_def then return nil, "unknown stake: " .. tostring(stake_id) end
    if not is_unlocked(stake_def, unlocks and unlocks.unlocked_stakes) then
        return nil, "stake is locked: " .. tostring(stake_id)
    end
    return {
        starting_deck_id = deck_id,
        stake_id = stake_id,
        seeded = config.seeded == true,
        seed = config.seed,
    }
end

local function build_hwatu_deck()
    return require("game.deck").new()
end

local function build_thin_deck()
    local deck = require("game.deck")
    local result = deck.new()
    -- Remove eight pi explicitly: preserve every named yaku kind and never put
    -- gwang/month metadata into the play deck.
    local remaining = 8
    for i = #result.cards, 1, -1 do
        if result.cards[i].kind == "pi" and remaining > 0 then
            deck.destroy(result, i)
            remaining = remaining - 1
        end
    end
    assert(remaining == 0, "starter deck must have at least eight pi")
    return result
end

local DECK_APPLIERS = {
    hwatu = function(state)
        state.deck = build_hwatu_deck()
        state.money = 4
    end,
    thin = function(state)
        state.deck = build_thin_deck()
        state.money = 4
    end,
    gwang_jackpot = function(state)
        state.deck = build_hwatu_deck()
        state.money = 0
        state.gwang = state.gwang or {}
        state.gwang[#state.gwang + 1] = { kind = "gwang", identity = "chips" }
    end,
}

local function apply_stake(state, selected_id)
    local rules = {
        target_multiplier = 1,
        economy_multiplier = 1,
        discard_delta = 0,
        applied_stakes = {},
    }
    for i = 1, #M.STAKES do
        local tier = M.STAKES[i]
        local effects = tier.effects or {}
        rules.target_multiplier = rules.target_multiplier * (effects.target_multiplier or 1)
        rules.economy_multiplier = rules.economy_multiplier * (effects.economy_multiplier or 1)
        rules.discard_delta = rules.discard_delta + (effects.discard_delta or 0)
        rules.applied_stakes[#rules.applied_stakes + 1] = tier.id
        if tier.id == selected_id then break end
    end
    state.run_rules = rules
end

local function rules_for(state)
    return type(state) == "table" and state.run_rules or nil
end

function M.adjust_target(state, base_target)
    assert(type(base_target) == "number" and base_target >= 0, "base target must be non-negative")
    local rules = rules_for(state)
    return math.ceil(base_target * (rules and rules.target_multiplier or 1))
end

function M.adjust_economy(state, base_amount)
    assert(type(base_amount) == "number" and base_amount >= 0, "base economy must be non-negative")
    local rules = rules_for(state)
    return math.floor(base_amount * (rules and rules.economy_multiplier or 1))
end

function M.discard_limit(state, base_discards)
    base_discards = base_discards or 3
    assert(type(base_discards) == "number" and base_discards >= 0, "base discards must be non-negative")
    local rules = rules_for(state)
    local voucher_bonus = 0
    if type(state) == "table" and type(state.vouchers) == "table" then
        voucher_bonus = state.vouchers.discards or 0
    end
    return math.max(0, base_discards + voucher_bonus + (rules and rules.discard_delta or 0))
end

--- Apply a validated selection to a freshly-created run state.
-- Validation happens before mutation; callers get nil + reason for bad choices.
function M.apply(state, config, unlocks)
    if type(state) ~= "table" then
        return nil, "run state must be a table"
    end
    local valid, reason = M.validate(config, unlocks)
    if not valid then return nil, reason end

    DECK_APPLIERS[valid.starting_deck_id](state)
    apply_stake(state, valid.stake_id)
    state.money = M.adjust_economy(state, state.money)
    state.discard_limit = M.discard_limit(state, 3)
    state.starting_deck_id = valid.starting_deck_id
    state.stake_id = valid.stake_id
    state.seeded = valid.seeded
    if valid.seeded and valid.seed ~= nil then
        local plan = require("game.rng").plan(valid.seed)
        state.seed = plan.seed
        state.rng = { shop = plan.shop, cards = plan.cards, boss = plan.boss }
    end
    state.progressEligible = not valid.seeded
    return state
end

return M
