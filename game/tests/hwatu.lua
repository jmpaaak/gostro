local hwatu = require("game.hwatu")

local M = {}

local function cards(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = hwatu.card((select(i, ...)))
    end
    return out
end

local function yaku_blob(result)
    return table.concat(result.yaku, ",")
end

function M.run()
    assert(hwatu.GWANG_BASE == 1, "gwang joker base is 1 point")
    assert(hwatu.card("hongdan").kind == "hongdan")
    assert(hwatu.card("cheongdan").kind == "cheongdan")
    assert(hwatu.card("chodan").kind == "chodan")
    assert(hwatu.card("godori").kind == "godori")
    assert(hwatu.card("pi").kind == "pi")

    local face = hwatu.card("hongdan")
    assert(face.month == nil, "play cards have no month numbers")
    assert(face.month_name == nil, "play cards have no month names")

    local gwang_ok, gwang_err = pcall(hwatu.card, "gwang")
    assert(not gwang_ok)
    assert(tostring(gwang_err):find("joker", 1, true))

    local month_ok = pcall(hwatu.card, "hongdan", { month = 1 })
    assert(not month_ok, "month numbers are forbidden")

    local hongdan = hwatu.evaluate(cards("hongdan", "hongdan", "hongdan", "pi", "pi"))
    assert(yaku_blob(hongdan) == "hongdan")
    assert(hongdan.chips > 0 and hongdan.mult > 1)
    assert(hongdan.score == hongdan.chips * hongdan.mult)

    local cheongdan = hwatu.evaluate(cards("cheongdan", "cheongdan", "cheongdan"))
    assert(yaku_blob(cheongdan) == "cheongdan")
    assert(cheongdan.score == cheongdan.chips * cheongdan.mult)

    local chodan = hwatu.evaluate(cards("chodan", "chodan", "chodan", "godori", "pi"))
    assert(yaku_blob(chodan) == "chodan")

    local godori = hwatu.evaluate(cards("godori", "godori", "godori", "pi", "pi"))
    assert(yaku_blob(godori) == "godori")
    assert(godori.mult > 1)

    local pi = hwatu.evaluate(cards("pi", "pi", "pi", "pi", "pi"))
    assert(yaku_blob(pi) == "pi")
    assert(pi.score == pi.chips * pi.mult)

    local none = hwatu.evaluate(cards("hongdan", "hongdan", "cheongdan", "godori", "pi"))
    assert(#none.yaku == 0)
    assert(none.mult == 1)
    assert(none.score == none.chips)

    local too_many = pcall(hwatu.evaluate, cards("pi", "pi", "pi", "pi", "pi", "pi"))
    assert(not too_many, "play at most 5 cards")

    local gwang_hand = pcall(hwatu.evaluate, { { kind = "gwang" } })
    assert(not gwang_hand, "gwang is a joker slot, not a play card")

    local names = yaku_blob(hongdan) .. yaku_blob(cheongdan) .. yaku_blob(chodan) .. yaku_blob(godori) .. yaku_blob(pi)
    assert(not names:find("mae", 1, true))
    assert(not names:find("ppeok", 1, true))
    assert(not names:find("otti", 1, true))
    assert(not names:find("gwangyeol", 1, true))
    assert(not names:find("고수패", 1, true))
end

return M
