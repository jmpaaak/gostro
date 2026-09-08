-- Targeted tests for the pure, finite-deck round engine.

local deck = require("game.deck")
local run = require("game.run")
local round_engine = require("game.round_engine")

local M = {}

local KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

local function tiny_deck(n)
    local cards = {}
    for i = 1, n do
        cards[i] = { kind = KINDS[((i - 1) % #KINDS) + 1], id = i }
    end
    return { cards = cards }
end

local function ids(cards)
    local out = {}
    for i = 1, #cards do
        out[i] = cards[i].id or cards[i].kind
    end
    return table.concat(out, ",")
end

local function card_count(round)
    return #round.hand + #round.draw_pile + #round.discard_pile
end

function M.run()
    M.test_default_starter_deck_and_options_overload()
    M.test_initializes_from_finite_deck_and_modifiers()
    M.test_seeded_shuffle_is_reproducible()
    M.test_discard_consumes_and_replaces_selected_cards()
    M.test_play_consumes_hand_and_reshuffles_discard_pile()
    M.test_clear_transition_wins_on_last_hand()
    M.test_hands_exhausted_transition_loses_below_target()
    M.test_invalid_actions_do_not_mutate_round()
    M.test_psychic_requires_five_cards()
    print("  round_engine: OK")
end

function M.test_default_starter_deck_and_options_overload()
    local round = round_engine.new(run.new("DEFAULT1"), { hand_size = 5, target = 300 })
    assert(#round.hand == 5)
    assert(card_count(round) == deck.total(deck.new()))
    assert(round_engine.BASE_HAND_SIZE == 8)
    assert(round_engine.BASE_HANDS == 4)
    assert(round_engine.BASE_DISCARDS == 3)
    assert(round_engine.MAX_PLAY == 5)
end

function M.test_initializes_from_finite_deck_and_modifiers()
    local state = run.new("ROUND001")
    state.vouchers.hand_size = 1
    state.vouchers.hands = 2
    state.vouchers.discards = 1
    state.tags.hand_size_bonus = 1
    local source = deck.new()
    local round = round_engine.new(state, source, { target = 999 })

    assert(round.hand_size == 10)
    assert(#round.hand == 10)
    assert(round.hands_left == 6)
    assert(round.discards_left == 4)
    assert(#round.draw_pile == #source.cards - 10)
    assert(#round.discard_pile == 0)
    assert(card_count(round) == #source.cards)
    assert(round.target == 999 and round.score == 0)
    assert(round.status == "playing" and round.transition == nil)
end

function M.test_seeded_shuffle_is_reproducible()
    local a = round_engine.new(run.new("SAMESEED"), tiny_deck(12), { hand_size = 5, target = 100 })
    local b = round_engine.new(run.new("sameseed"), tiny_deck(12), { hand_size = 5, target = 100 })
    local c = round_engine.new(run.new("OTHER001"), tiny_deck(12), { hand_size = 5, target = 100 })

    assert(ids(a.hand) == ids(b.hand))
    assert(ids(a.draw_pile) == ids(b.draw_pile))
    assert(ids(a.hand) ~= ids(c.hand) or ids(a.draw_pile) ~= ids(c.draw_pile))
end

function M.test_discard_consumes_and_replaces_selected_cards()
    local round = round_engine.new(run.new("DISCARD1"), tiny_deck(10), {
        hand_size = 4, discards = 2, target = 100,
    })
    local before = card_count(round)
    local removed_a, removed_b = round.hand[1], round.hand[3]
    local ok, discarded = round_engine.discard(round, { 1, 3 })

    assert(ok == true)
    assert(#discarded == 2)
    assert(discarded[1] == removed_a and discarded[2] == removed_b)
    assert(round.discards_left == 1)
    assert(#round.hand == 4)
    assert(card_count(round) == before)
end

function M.test_play_consumes_hand_and_reshuffles_discard_pile()
    local round = round_engine.new(run.new("RESHUFF1"), tiny_deck(6), {
        hand_size = 4, hands = 3, discards = 1, target = 1000,
    })
    local before = card_count(round)

    local ok = round_engine.discard(round, { 1, 2, 3 })
    assert(ok == true)
    assert(round.reshuffles == 1, "replacement crosses into a deterministic reshuffle")
    assert(#round.hand == 4)
    assert(#round.draw_pile == 2)
    assert(#round.discard_pile == 0)

    local transition, played = round_engine.play(round, { 1, 2 }, 10)
    assert(transition == nil)
    assert(#played == 2)
    assert(round.hands_left == 2)
    assert(round.score == 10)
    assert(#round.hand == 4)
    assert(card_count(round) == before)
end

function M.test_clear_transition_wins_on_last_hand()
    local round = round_engine.new(run.new("CLEAR001"), tiny_deck(8), {
        hand_size = 4, hands = 1, target = 25,
    })
    local transition = round_engine.play(round, { 1 }, { score = 25 })
    assert(transition == "clear_blind")
    assert(round.transition == "clear_blind")
    assert(round.status == "finished")
    assert(round.hands_left == 0)
end

function M.test_hands_exhausted_transition_loses_below_target()
    local round = round_engine.new(run.new("LOSE0001"), tiny_deck(8), {
        hand_size = 4, hands = 1, target = 25,
    })
    local transition = round_engine.play(round, { 1 }, 24)
    assert(transition == "lose")
    assert(round.transition == "lose")
    assert(round.status == "finished")
    assert(round.hands_left == 0)
end

function M.test_invalid_actions_do_not_mutate_round()
    local round = round_engine.new(run.new("INVALID1"), tiny_deck(8), {
        hand_size = 4, hands = 1, discards = 1, target = 100,
    })
    local snapshot = table.concat({ #round.hand, #round.draw_pile, #round.discard_pile,
        round.hands_left, round.discards_left, round.score }, ":")
    local ok = pcall(round_engine.discard, round, { 1, 1 })
    assert(not ok, "duplicate selection is rejected")
    ok = pcall(round_engine.play, round, { 0 }, 5)
    assert(not ok, "out-of-range selection is rejected")
    local after = table.concat({ #round.hand, #round.draw_pile, #round.discard_pile,
        round.hands_left, round.discards_left, round.score }, ":")
    assert(snapshot == after)
end

function M.test_psychic_requires_five_cards()
    local state = run.new("PSYCHIC")
    state.blind = "boss"
    run.select_boss(state, "psychic")
    local round = round_engine.new(state, tiny_deck(10), { hand_size = 5, target = 100 })
    local ok, err = round_engine.can_play(round, { 1, 2, 3, 4 })
    assert(ok == false and err == "psychic requires a 5-card hand")
    local success = round_engine.can_play(round, { 1, 2, 3, 4, 5 })
    assert(success == true)
end

return M
