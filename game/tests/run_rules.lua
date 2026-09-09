local run_rules = require("game.run_rules")

local M = {}

local function expect_rejected(config, unlocks, text)
    local valid, reason = run_rules.validate(config, unlocks)
    assert(valid == nil, text .. " must be rejected")
    assert(type(reason) == "string" and #reason > 0, text .. " must explain rejection")
end

function M.run()
    local valid, reason = run_rules.validate({
        starting_deck_id = "hwatu",
        stake_id = "white",
        seeded = false,
    })
    assert(valid ~= nil and reason == nil, "the default new-run configuration is valid")
    assert(valid.starting_deck_id == "hwatu" and valid.stake_id == "white",
        "validation returns canonical selections")
    valid = assert(run_rules.validate({ deck_id = "thin", stake_id = "white" }))
    assert(valid.starting_deck_id == "thin", "deck_id is accepted as the compact UI-facing alias")

    expect_rejected({ starting_deck_id = "missing", stake_id = "white" }, nil, "unknown deck")
    expect_rejected({ starting_deck_id = "hwatu", stake_id = "missing" }, nil, "unknown stake")
    expect_rejected({ starting_deck_id = "gwang_jackpot", stake_id = "white" }, nil, "locked deck")
    expect_rejected({ starting_deck_id = "hwatu", stake_id = "red" }, nil, "locked stake")
    expect_rejected({ starting_deck_id = "hwatu", stake_id = "green" }, nil, "locked green stake")

    valid = assert(run_rules.validate({
        starting_deck_id = "gwang_jackpot",
        stake_id = "white",
    }, { unlocked_decks = { gwang_jackpot = true } }))
    assert(valid.starting_deck_id == "gwang_jackpot", "explicit progress can unlock a deck")

    local created_a = assert(run_rules.create({
        starting_deck_id = "thin", stake_id = "white", seeded = true, seed = "create-seed",
    }))
    local created_b = assert(run_rules.create({
        starting_deck_id = "thin", stake_id = "white", seeded = true, seed = "create-seed",
    }))
    assert(created_a.starting_deck_id == "thin" and created_a.seed == "CREATESEED",
        "create returns a fully configured run")
    assert(created_a.rng.cards(1, 100000) == created_b.rng.cards(1, 100000),
        "create installs deterministic gameplay streams from the selected seed")
    local rejected_create, create_reason = run_rules.create({
        starting_deck_id = "missing", stake_id = "white",
    })
    assert(rejected_create == nil and type(create_reason) == "string",
        "create rejects an invalid selection instead of returning a partial run")

    local run = require("game.run")
    local deck = require("game.deck")

    local hwatu = assert(run_rules.apply(run.new(), {
        starting_deck_id = "hwatu", stake_id = "white", seeded = false,
    }))
    local hwatu_counts = deck.counts(hwatu.deck)
    assert(deck.total(hwatu.deck) == 40 and hwatu_counts.pi == 20,
        "hwatu uses the complete Korean starter composition")
    assert(hwatu.money == 4, "hwatu keeps the standard starting bankroll")
    assert(hwatu.progressEligible == true, "ordinary runs remain progress eligible")

    local thin = assert(run_rules.apply(run.new(), {
        starting_deck_id = "thin", stake_id = "white", seeded = false,
    }))
    local thin_counts = deck.counts(thin.deck)
    assert(deck.total(thin.deck) < deck.total(hwatu.deck) and thin_counts.pi < hwatu_counts.pi,
        "thin has a genuinely thinner, lower-pi play deck")
    assert(thin_counts.hongdan == 5 and thin_counts.cheongdan == 5
        and thin_counts.chodan == 5 and thin_counts.godori == 5,
        "thin preserves all four named hwatu play-card kinds")

    local jackpot = assert(run_rules.apply(run.new(), {
        starting_deck_id = "gwang_jackpot", stake_id = "white", seeded = true,
    }, { unlocked_decks = { gwang_jackpot = true } }))
    assert(#jackpot.gwang == 1 and jackpot.gwang[1].kind == "gwang",
        "gwang jackpot changes a starting run resource without putting gwang in the play deck")
    assert(jackpot.gwang[1].month == nil and jackpot.gwang[1].month_name == nil,
        "starting resources retain the no-month Korean hwatu model")
    assert(jackpot.progressEligible == false, "seeded runs cannot earn progress")

    local seeded_a = assert(run_rules.apply(run.new(), {
        deck_id = "hwatu", stake_id = "white", seeded = true, seed = "fixed-seed",
    }))
    local seeded_b = assert(run_rules.apply(run.new(), {
        deck_id = "hwatu", stake_id = "white", seeded = true, seed = "fixed-seed",
    }))
    assert(seeded_a.seed == "FIXEDSEED" and seeded_b.seed == seeded_a.seed,
        "apply installs the selected normalized seed on the run")
    assert(seeded_a.rng.cards(1, 100000) == seeded_b.rng.cards(1, 100000),
        "the selected seed controls gameplay RNG streams")

    local white = assert(run_rules.apply(run.new(), {
        starting_deck_id = "hwatu", stake_id = "white",
    }))
    assert(run_rules.adjust_target(white, 300) == 300, "white stake keeps the base target")
    assert(run_rules.adjust_economy(white, 7) == 7, "white stake keeps the base economy")
    assert(run_rules.discard_limit(white, 3) == 3, "white stake keeps base discards")

    local red = assert(run_rules.apply(run.new(), {
        starting_deck_id = "hwatu", stake_id = "red",
    }, { unlocked_stakes = { red = true } }))
    assert(red.run_rules.applied_stakes[1] == "white"
        and red.run_rules.applied_stakes[2] == "red",
        "a selected stake cumulatively applies every earlier tier")
    assert(run_rules.adjust_target(red, 300) == 375,
        "red stake raises gameplay targets")
    assert(run_rules.adjust_economy(red, 7) == 5 and red.money == 3,
        "red stake constrains payouts and starting economy with integer rounding")
    assert(run_rules.discard_limit(red, 3) == 2 and red.discard_limit == 2,
        "red stake constrains available discards")
    require("game.vouchers").apply(red, "wasteful")
    assert(run_rules.discard_limit(red) == 3,
        "voucher discard bonuses compose with the stake constraint")

    local green = assert(run_rules.apply(run.new(), {
        starting_deck_id = "hwatu", stake_id = "green",
    }, { unlocked_stakes = { red = true, green = true } }))
    assert(green.run_rules.applied_stakes[1] == "white"
        and green.run_rules.applied_stakes[2] == "red"
        and green.run_rules.applied_stakes[3] == "green",
        "green stake cumulatively applies every earlier tier")
    assert(run_rules.adjust_target(green, 300) == 375,
        "green stake keeps the red target until a later cycle adds its own effects")
    assert(run_rules.adjust_economy(green, 7) == 5 and green.money == 3,
        "green stake keeps the red economy until a later cycle adds its own effects")
    assert(run_rules.discard_limit(green, 3) == 2 and green.discard_limit == 2,
        "green stake keeps the red discard limit until a later cycle adds its own effects")

    local untouched = run.new()
    local rejected = run_rules.apply(untouched, {
        starting_deck_id = "missing", stake_id = "white",
    })
    assert(rejected == nil and untouched.deck == nil and untouched.starting_deck_id == nil,
        "apply validates before mutating run state")

    print("  run_rules: OK")
end

return M
