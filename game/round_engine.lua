-- Pure round state: finite draw/discard piles and action counters.
-- This module contains no UI or LÖVE dependencies. Callers apply the returned
-- "clear_blind" / "lose" transition through game.blind_flow.

local boss_rounds = require("game.boss_rounds")

local M = {}

local BASE_HAND_SIZE = 8
local BASE_HANDS = 4
local BASE_DISCARDS = 3
local MAX_PLAY = 5

M.BASE_HAND_SIZE = BASE_HAND_SIZE
M.BASE_HANDS = BASE_HANDS
M.BASE_DISCARDS = BASE_DISCARDS
M.MAX_PLAY = MAX_PLAY

local PLAY_KINDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

local function integer(value, name, minimum)
    if type(value) ~= "number" or value ~= math.floor(value) or value < minimum then
        error(name .. " must be an integer >= " .. tostring(minimum))
    end
    return value
end

local function copy_cards(cards)
    if type(cards) ~= "table" then
        error("deck must have cards")
    end
    local out = {}
    for i = 1, #cards do
        local card = cards[i]
        if type(card) ~= "table" or not PLAY_KINDS[card.kind] then
            error("round deck contains an invalid play card")
        end
        if card.month ~= nil or card.month_name ~= nil then
            error("round deck contains an invalid play card")
        end
        out[i] = card
    end
    return out
end

local function shuffle(cards, random)
    for i = #cards, 2, -1 do
        local j = random(1, i)
        if type(j) ~= "number" or j ~= math.floor(j) or j < 1 or j > i then
            error("cards rng returned an invalid index")
        end
        cards[i], cards[j] = cards[j], cards[i]
    end
end

local function cards_rng(run_state, options)
    local random = options.rng or (run_state.rng and run_state.rng.cards)
    if type(random) ~= "function" then
        error("round requires run_state.rng.cards")
    end
    return random
end

local function modifier(container, field)
    if type(container) ~= "table" then
        return 0
    end
    local value = container[field]
    if value == nil then
        return 0
    end
    return integer(value, field, 0)
end

local function initial_hand_size(run_state, options)
    if options.hand_size ~= nil then
        return integer(options.hand_size, "hand_size", 0)
    end
    local base = run_state.base_hand_size or run_state.hand_size or BASE_HAND_SIZE
    local size = integer(base, "base hand size", 0)
        + modifier(run_state.seals or run_state.vouchers, "hand_size")
        + modifier(run_state.plaques or run_state.tags, "hand_size_bonus")
    local boss = run_state.boss
    if type(boss) == "table" then
        local delta = boss.hand_size_delta or boss.hand_size_modifier
        if delta ~= nil then
            if type(delta) ~= "number" or delta ~= math.floor(delta) then
                error("boss hand size modifier must be an integer")
            end
            size = size + delta
        end
    end
    if size < 0 then
        size = 0
    end
    return size
end

local function initial_count(options_value, run_state, base, seal_field, name)
    if options_value ~= nil then
        return integer(options_value, name, 0)
    end
    return integer(run_state["base_" .. name] or base, "base " .. name, 0)
        + modifier(run_state.seals or run_state.vouchers, seal_field)
end

local function default_target(run_state)
    if run_state.target ~= nil then
        return run_state.target
    end
    -- Loaded lazily to keep round state independent from run transition code.
    return require("game.round_flow").target(run_state)
end

local function recycle(round)
    if #round.draw_pile > 0 or #round.discard_pile == 0 then
        return false
    end
    round.draw_pile = round.discard_pile
    round.discard_pile = {}
    shuffle(round.draw_pile, round.rng)
    round.reshuffles = round.reshuffles + 1
    return true
end

local function draw_into_hand(round, count)
    local drawn = {}
    for _ = 1, count do
        if #round.draw_pile == 0 then
            recycle(round)
        end
        if #round.draw_pile == 0 then
            break
        end
        local card = table.remove(round.draw_pile)
        round.hand[#round.hand + 1] = card
        drawn[#drawn + 1] = card
    end
    return drawn
end

local function validate_selection(round, selected)
    if type(selected) ~= "table" or #selected == 0 then
        return nil, "select at least one card"
    end
    if #selected > MAX_PLAY then
        return nil, "select at most 5 cards"
    end
    local seen = {}
    local cards = {}
    for i = 1, #selected do
        local index = selected[i]
        if type(index) ~= "number" or index ~= math.floor(index)
            or index < 1 or index > #round.hand then
            error("selected card index out of range")
        end
        if seen[index] then
            error("selected card index repeated")
        end
        seen[index] = true
        cards[i] = round.hand[index]
    end
    return { indices = seen, cards = cards }
end

local function remove_selection(round, selection)
    local remaining = {}
    for i = 1, #round.hand do
        if not selection.indices[i] then
            remaining[#remaining + 1] = round.hand[i]
        end
    end
    round.hand = remaining
    for i = 1, #selection.cards do
        round.discard_pile[#round.discard_pile + 1] = selection.cards[i]
    end
end

local function refill(round)
    return draw_into_hand(round, math.max(0, round.hand_size - #round.hand))
end

local function result_score(result)
    if type(result) == "number" then
        return result
    end
    if type(result) == "table" then
        return result.score
    end
    return nil
end

local function finish_transition(round)
    if round.score >= round.target then
        round.status = "finished"
        round.transition = "clear_blind"
    elseif round.hands_left == 0 then
        round.status = "finished"
        round.transition = "lose"
    end
    return round.transition
end

local function apply_hook(round)
    local boss = round.boss
    if type(boss) ~= "table" or boss.effect ~= "discard_hand" then
        return {}
    end
    local amount = math.min(boss.amount or 2, #round.hand)
    local hooked = {}
    for _ = 1, amount do
        local index = round.rng(1, #round.hand)
        local card = table.remove(round.hand, index)
        hooked[#hooked + 1] = card
        round.discard_pile[#round.discard_pile + 1] = card
    end
    refill(round)
    return hooked
end

--- Start a round from a run state and a finite deck (`{ cards = {...} }`).
--- Options can override target, hand_size, hands, discards, score, and rng.
function M.new(run_state, source_deck, options)
    if type(run_state) ~= "table" then
        error("run_state must be a table")
    end
    if options == nil and type(source_deck) == "table" and source_deck.cards == nil then
        options = source_deck
        source_deck = options.deck
    end
    options = options or {}
    source_deck = source_deck or options.deck or run_state.deck or require("game.deck").new()
    if type(source_deck) ~= "table" or type(source_deck.cards) ~= "table" then
        error("round requires a finite deck")
    end

    local random = cards_rng(run_state, options)
    local target = options.target
    if target == nil then
        target = default_target(run_state)
    end
    if type(target) ~= "number" or target < 0 then
        error("target must be a non-negative number")
    end
    local score = options.score
    if score == nil then
        score = run_state.round_score or 0
    end
    if type(score) ~= "number" or score < 0 then
        error("score must be a non-negative number")
    end

    local round = {
        hand = {},
        draw_pile = copy_cards(source_deck.cards),
        discard_pile = {},
        hand_size = initial_hand_size(run_state, options),
        hands_left = initial_count(options.hands, run_state, BASE_HANDS, "hands", "hands"),
        discards_left = initial_count(options.discards, run_state, BASE_DISCARDS, "discards", "discards"),
        target = target,
        score = score,
        status = "playing",
        transition = nil,
        rng = random,
        boss = run_state.boss,
        reshuffles = 0,
    }
    shuffle(round.draw_pile, random)
    draw_into_hand(round, round.hand_size)
    finish_transition(round)
    return round
end

function M.draw(round, count)
    if type(round) ~= "table" then
        error("round must be a table")
    end
    count = count or 1
    integer(count, "draw count", 0)
    return draw_into_hand(round, count)
end

function M.can_play(round, selected)
    if round.status ~= "playing" then
        return false, "round is finished"
    end
    if round.hands_left <= 0 then
        return false, "no hands left"
    end
    local selection, err = validate_selection(round, selected)
    if not selection then
        return false, err
    end
    if type(round.boss) == "table" and round.boss.effect == "full_hand" then
        return boss_rounds.psychic_allows(#selection.cards)
    end
    return true
end

--- Consume one hand, discard the selected cards, and refill from finite piles.
--- Returns transition-or-nil, played_cards. Transition is "clear_blind" or "lose".
function M.play(round, selected, result)
    local allowed, err = M.can_play(round, selected)
    if not allowed then
        return false, err
    end
    local score = result_score(result)
    if type(score) ~= "number" or score < 0 then
        error("play result must provide a non-negative score")
    end
    local selection = assert(validate_selection(round, selected))
    remove_selection(round, selection)
    round.hands_left = round.hands_left - 1
    round.score = round.score + score
    refill(round)
    round.last_hooked = apply_hook(round)
    return finish_transition(round), selection.cards
end

function M.can_discard(round, selected)
    if round.status ~= "playing" then
        return false, "round is finished"
    end
    if round.discards_left <= 0 then
        return false, "no discards left"
    end
    local selection, err = validate_selection(round, selected)
    if not selection then
        return false, err
    end
    return true
end

--- Consume one discard, move selected cards to discard, and refill the hand.
--- Returns true, discarded_cards; resource/state failures return false, reason.
function M.discard(round, selected)
    local allowed, err = M.can_discard(round, selected)
    if not allowed then
        return false, err
    end
    local selection = assert(validate_selection(round, selected))
    remove_selection(round, selection)
    round.discards_left = round.discards_left - 1
    refill(round)
    return true, selection.cards
end

-- Scene-facing names for eventual integration without coupling this module to UI.
M.start = M.new
M.play_hand = M.play
M.discard_hand = M.discard

return M
