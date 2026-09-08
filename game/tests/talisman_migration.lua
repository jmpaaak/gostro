-- Focused migration contract for the Tarot -> Talisman terminology change.
local M = {}

function M.run()
    print("  talisman_migration:")

    local talismans = require("game.talismans")
    local legacy = require("game.tarots")
    assert(legacy == talismans, "legacy module must alias the canonical module")
    assert(require("game.tarot_use") == require("game.talisman_use"),
        "legacy use controller must alias the canonical controller")
    assert(require("game.ui.tarot_target") == require("game.ui.talisman_target"),
        "legacy target UI must alias the canonical target UI")

    local expected = {
        { id = "dungap_bu", name = "둔갑부", effect = "convert", legacy = "the_magician" },
        { id = "somyeol_bu", name = "소멸부", effect = "destroy", legacy = "the_hanged_man" },
        { id = "gwangchae_bu", name = "광채부", effect = "enhance", legacy = "the_chariot" },
        { id = "bunsin_bu", name = "분신부", effect = "copy", legacy = "the_lovers" },
    }
    for i, wanted in ipairs(expected) do
        local actual = talismans.POOL[i]
        assert(actual.id == wanted.id and actual.name == wanted.name
            and actual.effect == wanted.effect)
        assert(talismans.by_id(wanted.legacy) == actual,
            "legacy ids must resolve without changing pool order")
    end

    local old_save = { tarots = { { id = "the_magician", effect = "convert" } }, vouchers = {} }
    local held = talismans.ensure(old_save)
    assert(held == old_save.tarots and old_save.talismans == old_save.tarots,
        "legacy save inventory must migrate by alias, without copying")
    assert(held[1].id == "dungap_bu" and held[1].name == "둔갑부",
        "legacy held cards must be canonicalized before display")
    local cards = { talismans.make_card("pi") }
    talismans.use(old_save, 1, cards, 1, { kind = "hongdan" })
    assert(cards[1].kind == "hongdan" and #old_save.talismans == 0)

    local fresh = { vouchers = {} }
    local gained = talismans.gain(fresh, "dungap_bu", "shop")
    assert(gained.name == "둔갑부" and fresh.talismans[1] == gained)
    assert(fresh.tarots == fresh.talismans, "legacy inventory field stays compatible")

    local packs = require("game.packs")
    assert(packs.DEFINITIONS.talisman_bundle.name == "부적 꾸러미")
    assert(packs.DEFINITIONS.arcana_pack == packs.DEFINITIONS.talisman_bundle,
        "legacy pack id must remain an alias")
    local state = {
        rng = { shop = function(min) return min end },
        vouchers = {},
    }
    local opened = packs.open(state, "arcana_pack")
    assert(opened.id == "talisman_bundle" and opened.name == "부적 꾸러미")
    assert(opened.choices[1].id == "dungap_bu",
        "legacy opening keeps the same seeded pool position")

    print("  talisman_migration: OK")
end

return M
