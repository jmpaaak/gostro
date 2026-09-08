local M = {}

local wish_cards = require("game.wish_cards")
local legacy_planets = require("game.planets")
local wish_cards_ui = require("game.ui.wish_cards_ui")
local legacy_planets_ui = require("game.ui.planets_ui")
local hwatu = require("game.hwatu")
local run = require("game.run")

local EXPECTED = {
    hongdan = { id = "wish_card_hongdan", legacy_id = "planet_hongdan", name = "붉은 띠의 기원", symbol = "홍" },
    cheongdan = { id = "wish_card_cheongdan", legacy_id = "planet_cheongdan", name = "푸른 띠의 기원", symbol = "청" },
    chodan = { id = "wish_card_chodan", legacy_id = "planet_chodan", name = "풀빛 띠의 기원", symbol = "초" },
    godori = { id = "wish_card_godori", legacy_id = "planet_godori", name = "세 새의 기원", symbol = "새" },
    pi = { id = "wish_card_pi", legacy_id = "planet_pi", name = "피 모으기의 기원", symbol = "피" },
}

function M.test_catalog_uses_korean_wish_card_identity()
    local found = {}
    for _, card in ipairs(wish_cards.all()) do
        local expected = EXPECTED[card.yaku]
        assert(expected, "unexpected wish card yaku: " .. tostring(card.yaku))
        assert(card.id == expected.id)
        assert(card.legacy_id == expected.legacy_id)
        assert(card.name == expected.name)
        assert(card.symbol == expected.symbol)
        assert(not card.name:find("Mars") and not card.name:find("Jupiter")
            and not card.name:find("Venus") and not card.name:find("Earth")
            and not card.name:find("Pluto"), "cosmic names must not remain")
        assert(card.month == nil and card.month_name == nil, "wish cards have no months")
        found[card.yaku] = true
    end
    for yaku in pairs(EXPECTED) do
        assert(found[yaku], "missing wish card for " .. yaku)
    end
end

function M.test_legacy_module_delegates_to_wish_cards()
    assert(legacy_planets == wish_cards, "legacy module must return the canonical wish-card API")
    assert(legacy_planets_ui == wish_cards_ui, "legacy UI path must delegate to the canonical UI")
    assert(wish_cards_ui.TITLE == "기원패")
    assert(wish_cards.by_id("planet_hongdan") == wish_cards.by_id("wish_card_hongdan"))
end

function M.test_buy_levels_the_saved_hand_state()
    local state = run.new()

    assert(wish_cards.get_level(state, "hongdan") == 1)
    local card = wish_cards.buy(state, "hongdan")
    assert(card.id == "wish_card_hongdan")
    assert(card.legacy_id == "planet_hongdan")
    assert(wish_cards.get_level(state, "hongdan") == 2)

    local hand = {
        hwatu.card("hongdan"),
        hwatu.card("hongdan"),
        hwatu.card("hongdan"),
        hwatu.card("pi"),
        hwatu.card("pi"),
    }
    local result = hwatu.evaluate(hand, state)
    assert(result.chips == 47, "expected 47 chips, got " .. result.chips)
    assert(result.mult == 3, "expected 3 mult, got " .. result.mult)
    assert(result.score == 47 * 3)
end

function M.run()
    M.test_catalog_uses_korean_wish_card_identity()
    M.test_legacy_module_delegates_to_wish_cards()
    M.test_buy_levels_the_saved_hand_state()
    print("  wish_cards: OK")
end

return M
