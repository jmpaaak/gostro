-- Headless tests for the Korean skip-round plaque catalog.

local plaques = require("game.plaques")
local tags = require("game.tags")
local run = require("game.run")

local M = {}

local CANONICAL_IDS = {
    "saebaram", "mokdon", "pumasi", "salimkkun",
    "ssangdungi", "eunbit", "noeulbit", "obangsaek",
    "jangteo", "jingwipum", "neoreunson", "yutnori",
}

local LEGACY_IDS = {
    "coupon", "investment", "handy", "economy",
    "mega", "foil", "hologram", "polychrome",
    "charm", "uncommon", "juggle", "d6",
}

local EFFECTS = {
    { "free_reroll", 1 }, { "money", 15 }, { "money", 8 }, { "money", 10 },
    { "duplicate_next_gwang" }, { "next_gwang_finish", "silver" },
    { "next_gwang_finish", "sunset" }, { "next_gwang_finish", "obang" },
    { "extra_shop_slots", 1 }, { "rare_shop" }, { "hand_size", 1 },
    { "free_reroll", 2 },
}

function M.run()
    assert(tags == plaques, "game.tags is a compatibility alias for game.plaques")
    assert(#plaques.POOL == #CANONICAL_IDS, "the plaque pool keeps all 12 rewards")

    for i, expected in ipairs(CANONICAL_IDS) do
        local definition = plaques.POOL[i]
        assert(definition.id == expected, "plaque order changed at index " .. i)
        assert(type(definition.name) == "string" and definition.name:find("패찰", 1, true),
            "each reward has a Korean plaque name")
        assert(definition.effect == EFFECTS[i][1], "plaque effect changed at index " .. i)
        assert((definition.amount or definition.finish) == EFFECTS[i][2],
            "plaque effect payload changed at index " .. i)
        assert(plaques.by_id(LEGACY_IDS[i]) == definition,
            "legacy id resolves to canonical plaque at index " .. i)
    end

    assert(plaques.random(function(a) return a end).id == CANONICAL_IDS[1])
    assert(plaques.random(function(_, b) return b end).id == CANONICAL_IDS[#CANONICAL_IDS])

    local state = run.new("plaque-aliases")
    assert(state.plaques == state.tags, "new and legacy run-state fields share storage")

    plaques.apply(state, "saebaram")
    assert(state.plaques.free_rerolls == 1)
    plaques.apply(state, "mokdon")
    plaques.apply(state, "pumasi")
    plaques.apply(state, "salimkkun")
    assert(state.plaques.pending_money == 33)
    plaques.apply(state, "ssangdungi")
    assert(state.plaques.duplicate_next_gwang == true)

    plaques.apply(state, "eunbit")
    assert(state.plaques.next_gwang_finish == "silver")
    assert(state.tags.next_gwang_edition == "foil", "legacy finish field remains available")
    plaques.apply(state, "noeulbit")
    assert(state.plaques.next_gwang_finish == "sunset")
    plaques.apply(state, "obangsaek")
    assert(state.plaques.next_gwang_finish == "obang")

    plaques.apply(state, "jangteo")
    assert(state.plaques.extra_shop_slots == 1)
    plaques.apply(state, "jingwipum")
    assert(state.plaques.rare_shop == true and state.tags.uncommon_shop == true)
    plaques.apply(state, "neoreunson")
    assert(state.plaques.hand_size_bonus == 1)
    plaques.apply(state, "yutnori")
    assert(state.plaques.free_rerolls == 3)

    local legacy = { tags = { owned = {} } }
    plaques.apply(legacy, "coupon")
    assert(legacy.plaques == legacy.tags, "old saves gain the canonical field")
    assert(legacy.plaques.owned[1] == "saebaram", "old ids normalize on application")

    local ok = pcall(plaques.by_id, "not-a-plaque")
    assert(not ok, "unknown plaque ids are rejected")

    local blob = ""
    for _, definition in ipairs(plaques.POOL) do
        blob = blob .. "," .. definition.id .. "," .. definition.name
    end
    for _, forbidden in ipairs({
        "coupon", "investment", "handy", "economy", "mega", "foil", "hologram",
        "polychrome", "charm", "uncommon", "juggle", "d6",
        "쿠폰", "투자", "handy", "이코노미", "메가", "포일", "홀로그램",
        "폴리크롬", "언커먼", "저글",
    }) do
        assert(not blob:lower():find(forbidden, 1, true),
            "canonical plaque catalog exposes legacy name: " .. forbidden)
    end

    print("  plaques: OK")
end

return M
