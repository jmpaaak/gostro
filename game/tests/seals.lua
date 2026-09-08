-- Tests for Korean-themed 인장 permanent upgrades and legacy voucher compatibility.
local seals = require("game.seals")
local run = require("game.run")

local M = {}

local LEGACY_IDS = {
    "paint_brush", "wasteful", "grabber", "overstock",
    "reroll_surplus", "clearance_sale", "seed_money", "antimatter",
    "crystal_ball", "hone", "directors_cut", "money_tree",
}

local EFFECTS = {
    "hand_size", "discard", "hands", "shop_slots",
    "reroll_discount", "shop_discount", "interest_cap", "gwang_slots",
    "consumable_slots", "edition_rate", "boss_rerolls", "interest_rate",
}

local function enter_shop(state)
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "shop")
    return state
end

function M.test_catalog_uses_new_korean_seal_identities()
    assert(#seals.POOL == 12, "인장 catalog stays at twelve entries")
    local forbidden = {
        "paint_brush", "wasteful", "grabber", "overstock", "reroll_surplus",
        "clearance_sale", "seed_money", "antimatter", "crystal_ball", "hone",
        "directors_cut", "money_tree", "반물질", "수정구", "디렉터컷", "머니트리",
        "바우처", "voucher", "talisman",
    }
    for i, def in ipairs(seals.POOL) do
        assert(def.effect == EFFECTS[i], "catalog order/effects must preserve seeded behavior")
        local blob = def.id .. "," .. def.name
        for _, word in ipairs(forbidden) do
            assert(not blob:lower():find(word:lower(), 1, true), "new seal identity leaks legacy term: " .. word)
        end
    end
end

function M.test_legacy_ids_resolve_and_migrate_to_canonical_ids()
    for i, legacy_id in ipairs(LEGACY_IDS) do
        local def = seals.by_id(legacy_id)
        assert(def == seals.POOL[i], "legacy id keeps its original effect/order: " .. legacy_id)
        assert(def.id ~= legacy_id, "legacy id is an alias only: " .. legacy_id)
        assert(seals.canonical_id(legacy_id) == def.id)
    end

    local legacy = {
        vouchers = {
            owned = { "antimatter", "crystal_ball" },
            shop_id = "paint_brush",
            gwang_slots = 1,
            consumable_slots = 1,
        },
    }
    local migrated = seals.ensure(legacy)
    assert(legacy.seals == migrated and legacy.vouchers == migrated,
        "new and legacy save fields alias the same migrated state")
    assert(migrated.owned[1] == seals.canonical_id("antimatter"))
    assert(migrated.owned[2] == seals.canonical_id("crystal_ball"))
    assert(migrated.shop_id == seals.canonical_id("paint_brush"))

    local mixed = {
        seals = { owned = { "wide_mat" } },
        vouchers = { owned = { "wasteful" }, hands = 2 },
    }
    local merged = seals.ensure(mixed)
    assert(#merged.owned == 2 and merged.owned[2] == "emptying_jar")
    assert(merged.hands == 2, "a partially migrated save does not lose legacy fields")
    assert(mixed.seals == mixed.vouchers)
end

function M.test_legacy_and_canonical_ids_share_purchase_identity()
    local state = run.new("SEALCOMPAT")
    seals.apply(state, "antimatter")
    local canonical = seals.canonical_id("antimatter")
    assert(state.seals.owned[1] == canonical)
    assert(state.vouchers == state.seals, "legacy voucher state remains readable")
    local duplicate = pcall(seals.apply, state, canonical)
    assert(not duplicate, "legacy and canonical ids cannot be bought twice")
end

function M.test_seeded_stock_keeps_pool_index_and_uses_seal_api()
    local first = run.new("SEALSTOCK")
    local second = run.new("SEALSTOCK")
    enter_shop(first)
    enter_shop(second)
    assert(first.seals.shop_id == second.seals.shop_id, "same seed stocks the same 인장")
    assert(first.seals.shop_id == first.vouchers.shop_id, "legacy save field mirrors stock")
    local id = first.seals.shop_id
    local bought = run.buy_seal(first, id)
    assert(bought == first.seals and bought.owned[1] == id)
end

function M.run()
    M.test_catalog_uses_new_korean_seal_identities()
    M.test_legacy_ids_resolve_and_migrate_to_canonical_ids()
    M.test_legacy_and_canonical_ids_share_purchase_identity()
    M.test_seeded_stock_keeps_pool_index_and_uses_seal_api()
    print("  seals: OK")
end

return M
