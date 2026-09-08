local terms = require("game.terms")

local M = {}

local function assert_display(key, expected)
    assert(terms.display(key) == expected,
        string.format("%s should display as %s", key, expected))
end

function M.test_canonical_player_facing_labels()
    assert_display("wish_card", "기원패")
    assert_display("talisman", "부적")
    assert_display("plaque", "패찰")
    assert_display("seal", "인장")
    assert_display("talisman_bundle", "부적 꾸러미")
    assert_display("round", "판")
    assert_display("opening", "첫판")
    assert_display("main", "큰판")
    assert_display("final", "대장판")
    assert_display("go", "고")
end

function M.test_legacy_keys_are_explicit_aliases()
    local expected = {
        planet = "wish_card",
        tarot = "talisman",
        tag = "plaque",
        voucher = "seal",
        arcana_pack = "talisman_bundle",
        blind = "round",
        small = "opening",
        big = "main",
        boss = "final",
        ante = "go",
    }

    for legacy, canonical in pairs(expected) do
        assert(terms.aliases[legacy] == canonical,
            string.format("%s should explicitly alias %s", legacy, canonical))
        assert(terms.canonical_key(legacy) == canonical)
        assert(terms.display(legacy) == terms.display(canonical))
    end
end

function M.test_unknown_keys_are_rejected()
    local ok, err = pcall(terms.display, "not_a_term")
    assert(not ok)
    assert(tostring(err):find("unknown term", 1, true))
end

function M.test_migration_api_compatibility()
    assert(terms.domain.planet == "기원패")
    assert(terms.domain.tarot == "부적")
    assert(terms.domain.tag == "패찰")
    assert(terms.domain.voucher == "인장")
    assert(terms.domain.arcana_pack == "부적 꾸러미")
    assert(terms.domain.blind == "판")
    assert(terms.ante(1) == "1고" and terms.ante(8) == "8고")
    assert(terms.blind_name("small") == "첫판")
    assert(terms.blind_name("big") == "큰판")
    assert(terms.blind_name("boss") == "대장판")
    assert(terms.blind_name("unknown") == "판")
end

function M.run()
    M.test_canonical_player_facing_labels()
    M.test_legacy_keys_are_explicit_aliases()
    M.test_unknown_keys_are_rejected()
    M.test_migration_api_compatibility()
    print("  terms: OK")
end

return M
