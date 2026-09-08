-- Tests for always + contains-kind + yaku + deck-size + money gwang jokers
-- (INBOX 21a/21b/21c/21d/21e). Catalog JSON + apply loop in hwatu.evaluate.

local catalog = require("game.gwang_catalog")
local hwatu = require("game.hwatu")
local run = require("game.run")
local deck = require("game.deck")

local M = {}

local function cards(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = hwatu.card((select(i, ...)))
    end
    return out
end

function M.run()
    M.test_catalog_loads_always_jokers()
    M.test_get_by_id()
    M.test_apply_always_chips()
    M.test_apply_always_mult()
    M.test_apply_always_chips_and_mult()
    M.test_hwatu_evaluate_applies_always()
    M.test_hwatu_without_gwang_unchanged()
    M.test_unknown_identity_is_noop()
    M.test_catalog_loads_contains_kind()
    M.test_apply_hongdan_x2_when_hand_has_hongdan()
    M.test_apply_hongdan_x2_skips_without_hongdan()
    M.test_hwatu_evaluate_hongdan_x2()
    M.test_catalog_loads_yaku()
    M.test_apply_godori_chips_when_yaku_is_godori()
    M.test_apply_godori_chips_skips_without_godori_yaku()
    M.test_hwatu_evaluate_godori_chips()
    M.test_catalog_loads_deck_size()
    M.test_apply_thin_deck_x3_when_deck_le_30()
    M.test_apply_thin_deck_x3_skips_when_deck_over_30()
    M.test_hwatu_evaluate_thin_deck_x3()
    M.test_catalog_loads_money()
    M.test_apply_rich_mult_when_money_ge_20()
    M.test_apply_rich_mult_skips_when_money_under_20()
    M.test_hwatu_evaluate_rich_mult()
    print("  gwang_catalog: OK")
end

function M.test_catalog_loads_always_jokers()
    local all = catalog.all()
    assert(type(all) == "table" and #all >= 2, "catalog must list always-trigger jokers")
    local seen = {}
    for i = 1, #all do
        local j = all[i]
        assert(j.id and j.id ~= "", "each joker has an id")
        assert(
            j.trigger == "always"
                or j.trigger == "contains_kind"
                or j.trigger == "yaku"
                or j.trigger == "deck_size"
                or j.trigger == "money",
            "known trigger"
        )
        assert(j.kind == nil or j.kind == "gwang", "gwang are joker slots")
        seen[j.id] = j
    end
    assert(seen.chips, "chips joker in catalog")
    assert(seen.mult, "mult joker in catalog")
    assert(seen.chips.trigger == "always")
    assert(seen.mult.trigger == "always")
    assert((seen.chips.effect.chips or 0) == 30)
    assert((seen.mult.effect.mult or 0) == 4)
end

function M.test_get_by_id()
    local chips = catalog.get("chips")
    assert(chips.id == "chips")
    assert(chips.trigger == "always")
    assert(chips.effect.chips == 30)
    assert(catalog.get("no_such_gwang") == nil)
end

function M.test_apply_always_chips()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        yaku = { "hongdan" },
        state = { gwang = { { kind = "gwang", identity = "chips" } } },
    })
    assert(chips == 62, "always chips +30, got " .. tostring(chips))
    assert(mult == 2, "chips joker does not change mult")
    assert(#triggered == 1)
    assert(triggered[1].id == "chips")
end

function M.test_apply_always_mult()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        yaku = { "hongdan" },
        state = { gwang = { { identity = "mult" } } },
    })
    assert(chips == 32)
    assert(mult == 6, "always mult +4, got " .. tostring(mult))
    assert(#triggered == 1)
    assert(triggered[1].id == "mult")
end

function M.test_apply_always_chips_and_mult()
    local chips, mult = catalog.apply({
        chips = 32,
        mult = 2,
        state = {
            gwang = {
                { identity = "chips" },
                { identity = "mult" },
            },
        },
    })
    assert(chips == 62)
    assert(mult == 6)
end

function M.test_hwatu_evaluate_applies_always()
    local hand = cards("hongdan", "hongdan", "hongdan", "pi", "pi")
    local base = hwatu.evaluate(hand)
    -- 3*10 + 2*1 = 32 chips, hongdan yaku mult 2
    assert(base.chips == 32)
    assert(base.mult == 2)

    local state = run.new()
    state.gwang = {
        { kind = "gwang", identity = "chips" },
        { kind = "gwang", identity = "mult" },
    }
    local with = hwatu.evaluate(hand, state)
    assert(with.chips == 62, "evaluate applies always +30 chips, got " .. tostring(with.chips))
    assert(with.mult == 6, "evaluate applies always +4 mult, got " .. tostring(with.mult))
    assert(with.score == 62 * 6)
    assert(with.gwang_triggers and #with.gwang_triggers == 2)
end

function M.test_hwatu_without_gwang_unchanged()
    local hand = cards("pi", "pi", "pi", "pi", "pi")
    local a = hwatu.evaluate(hand)
    local b = hwatu.evaluate(hand, run.new())
    assert(a.chips == b.chips)
    assert(a.mult == b.mult)
    assert(a.score == b.score)
end

function M.test_unknown_identity_is_noop()
    local chips, mult, triggered = catalog.apply({
        chips = 10,
        mult = 1,
        state = { gwang = { { identity = "not_in_catalog" } } },
    })
    assert(chips == 10)
    assert(mult == 1)
    assert(#triggered == 0)
end

function M.test_catalog_loads_contains_kind()
    local j = catalog.get("hongdan_x2")
    assert(j, "hongdan_x2 joker in catalog")
    assert(j.trigger == "contains_kind")
    assert(j.kind_need == "hongdan")
    assert((j.effect.mult_mul or 0) == 2)
end

function M.test_apply_hongdan_x2_when_hand_has_hongdan()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        hand = cards("hongdan", "pi", "pi"),
        state = { gwang = { { kind = "gwang", identity = "hongdan_x2" } } },
    })
    assert(chips == 32, "contains_kind does not add chips")
    assert(mult == 4, "hongdan in hand ×2, got " .. tostring(mult))
    assert(#triggered == 1)
    assert(triggered[1].id == "hongdan_x2")
end

function M.test_apply_hongdan_x2_skips_without_hongdan()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        hand = cards("cheongdan", "cheongdan", "pi"),
        state = { gwang = { { identity = "hongdan_x2" } } },
    })
    assert(chips == 32)
    assert(mult == 2, "no hongdan → no ×2, got " .. tostring(mult))
    assert(#triggered == 0)
end

function M.test_hwatu_evaluate_hongdan_x2()
    local with_hd = cards("hongdan", "hongdan", "hongdan", "pi", "pi")
    local no_hd = cards("cheongdan", "cheongdan", "cheongdan", "pi", "pi")
    local state = run.new()
    state.gwang = { { kind = "gwang", identity = "hongdan_x2" } }

    local base_hd = hwatu.evaluate(with_hd)
    local with = hwatu.evaluate(with_hd, state)
    assert(base_hd.chips == 32)
    assert(base_hd.mult == 2)
    assert(with.chips == 32)
    assert(with.mult == 4, "hongdan yaku 2 ×2 = 4, got " .. tostring(with.mult))
    assert(with.score == 32 * 4)
    assert(with.gwang_triggers and #with.gwang_triggers == 1)
    assert(with.gwang_triggers[1].id == "hongdan_x2")

    local base_no = hwatu.evaluate(no_hd)
    local skipped = hwatu.evaluate(no_hd, state)
    assert(skipped.chips == base_no.chips)
    assert(skipped.mult == base_no.mult)
    assert(not skipped.gwang_triggers or #skipped.gwang_triggers == 0)
end

function M.test_catalog_loads_yaku()
    local j = catalog.get("godori_chips")
    assert(j, "godori_chips joker in catalog")
    assert(j.trigger == "yaku")
    assert(j.yaku_need == "godori")
    assert((j.effect.chips or 0) == 100)
end

function M.test_apply_godori_chips_when_yaku_is_godori()
    local chips, mult, triggered = catalog.apply({
        chips = 62,
        mult = 2,
        yaku = { "godori" },
        hand = cards("godori", "godori", "godori", "pi", "pi"),
        state = { gwang = { { kind = "gwang", identity = "godori_chips" } } },
    })
    assert(chips == 162, "godori yaku +100 chips, got " .. tostring(chips))
    assert(mult == 2, "godori_chips does not change mult")
    assert(#triggered == 1)
    assert(triggered[1].id == "godori_chips")
end

function M.test_apply_godori_chips_skips_without_godori_yaku()
    -- 1 godori in hand is not the godori yaku (needs 3).
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        yaku = { "hongdan" },
        hand = cards("hongdan", "hongdan", "hongdan", "godori", "pi"),
        state = { gwang = { { identity = "godori_chips" } } },
    })
    assert(chips == 32, "no godori yaku → no +100, got " .. tostring(chips))
    assert(mult == 2)
    assert(#triggered == 0)
end

function M.test_hwatu_evaluate_godori_chips()
    local godori_hand = cards("godori", "godori", "godori", "pi", "pi")
    local hongdan_hand = cards("hongdan", "hongdan", "hongdan", "pi", "pi")
    local state = run.new()
    state.gwang = { { kind = "gwang", identity = "godori_chips" } }

    local base_g = hwatu.evaluate(godori_hand)
    -- 3*20 + 2*1 = 62 chips, godori yaku mult 2
    assert(base_g.chips == 62)
    assert(base_g.mult == 2)
    assert(base_g.yaku[1] == "godori")
    local with = hwatu.evaluate(godori_hand, state)
    assert(with.chips == 162, "evaluate applies yaku +100 chips, got " .. tostring(with.chips))
    assert(with.mult == 2)
    assert(with.score == 162 * 2)
    assert(with.gwang_triggers and #with.gwang_triggers == 1)
    assert(with.gwang_triggers[1].id == "godori_chips")

    local base_h = hwatu.evaluate(hongdan_hand)
    local skipped = hwatu.evaluate(hongdan_hand, state)
    assert(skipped.chips == base_h.chips)
    assert(skipped.mult == base_h.mult)
    assert(not skipped.gwang_triggers or #skipped.gwang_triggers == 0)
end

function M.test_catalog_loads_deck_size()
    local j = catalog.get("thin_deck_x3")
    assert(j, "thin_deck_x3 joker in catalog")
    assert(j.trigger == "deck_size")
    assert((j.deck_max or 0) == 30)
    assert((j.effect.mult_mul or 0) == 3)
end

function M.test_apply_thin_deck_x3_when_deck_le_30()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        deck_size = 30,
        state = { gwang = { { kind = "gwang", identity = "thin_deck_x3" } } },
    })
    assert(chips == 32, "deck_size does not add chips")
    assert(mult == 6, "deck ≤30 ×3, got " .. tostring(mult))
    assert(#triggered == 1)
    assert(triggered[1].id == "thin_deck_x3")
end

function M.test_apply_thin_deck_x3_skips_when_deck_over_30()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        deck_size = 31,
        state = { gwang = { { identity = "thin_deck_x3" } } },
    })
    assert(chips == 32)
    assert(mult == 2, "deck 31 → no ×3, got " .. tostring(mult))
    assert(#triggered == 0)
end

function M.test_hwatu_evaluate_thin_deck_x3()
    local hand = cards("hongdan", "hongdan", "hongdan", "pi", "pi")
    local state = run.new()
    state.gwang = { { kind = "gwang", identity = "thin_deck_x3" } }

    local fat = deck.new()
    assert(deck.total(fat) == 40)
    state.deck = fat
    local base = hwatu.evaluate(hand)
    assert(base.chips == 32)
    assert(base.mult == 2)
    local skipped = hwatu.evaluate(hand, state)
    assert(skipped.chips == 32)
    assert(skipped.mult == 2, "starter 40-card deck does not ×3, got " .. tostring(skipped.mult))
    assert(not skipped.gwang_triggers or #skipped.gwang_triggers == 0)

    local thin = deck.new()
    for _ = 1, 10 do
        deck.destroy(thin, 1)
    end
    assert(deck.total(thin) == 30)
    state.deck = thin
    local with = hwatu.evaluate(hand, state)
    assert(with.chips == 32)
    assert(with.mult == 6, "deck ≤30 ×3, got " .. tostring(with.mult))
    assert(with.score == 32 * 6)
    assert(with.gwang_triggers and #with.gwang_triggers == 1)
    assert(with.gwang_triggers[1].id == "thin_deck_x3")
end

function M.test_catalog_loads_money()
    local j = catalog.get("rich_mult")
    assert(j, "rich_mult joker in catalog")
    assert(j.trigger == "money")
    assert((j.money_min or 0) == 20)
    assert((j.effect.mult or 0) == 4)
end

function M.test_apply_rich_mult_when_money_ge_20()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        money = 20,
        state = { gwang = { { kind = "gwang", identity = "rich_mult" } } },
    })
    assert(chips == 32, "money trigger does not add chips")
    assert(mult == 6, "money ≥$20 +4 mult, got " .. tostring(mult))
    assert(#triggered == 1)
    assert(triggered[1].id == "rich_mult")
end

function M.test_apply_rich_mult_skips_when_money_under_20()
    local chips, mult, triggered = catalog.apply({
        chips = 32,
        mult = 2,
        money = 19,
        state = { gwang = { { identity = "rich_mult" } } },
    })
    assert(chips == 32)
    assert(mult == 2, "money $19 → no +4, got " .. tostring(mult))
    assert(#triggered == 0)
end

function M.test_hwatu_evaluate_rich_mult()
    local hand = cards("hongdan", "hongdan", "hongdan", "pi", "pi")
    local state = run.new()
    state.gwang = { { kind = "gwang", identity = "rich_mult" } }

    state.money = 19
    local base = hwatu.evaluate(hand)
    assert(base.chips == 32)
    assert(base.mult == 2)
    local skipped = hwatu.evaluate(hand, state)
    assert(skipped.chips == 32)
    assert(skipped.mult == 2, "money $19 does not +4, got " .. tostring(skipped.mult))
    assert(not skipped.gwang_triggers or #skipped.gwang_triggers == 0)

    state.money = 20
    local with = hwatu.evaluate(hand, state)
    assert(with.chips == 32)
    assert(with.mult == 6, "money ≥$20 +4 mult, got " .. tostring(with.mult))
    assert(with.score == 32 * 6)
    assert(with.gwang_triggers and #with.gwang_triggers == 1)
    assert(with.gwang_triggers[1].id == "rich_mult")
end

return M
