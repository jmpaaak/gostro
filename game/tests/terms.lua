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

function M.run()
    M.test_canonical_player_facing_labels()
    M.test_legacy_keys_are_explicit_aliases()
    M.test_unknown_keys_are_rejected()
    print("  terms: OK")
end

return M
