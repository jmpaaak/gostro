-- Tests for card hologram/foil/polychrome effects.
-- Engine-hosted: visual overlay data + hwatu scoring bonuses.

local effects = require("game.ui.card_effects")
local hwatu = require("game.hwatu")

local M = {}

local function cards_with(...)
    local out = {}
    for i = 1, select("#", ...) do
        local spec = select(i, ...)
        if type(spec) == "string" then
            out[i] = hwatu.card(spec)
        else
            out[i] = hwatu.card(spec.kind, { effect = spec.effect })
        end
    end
    return out
end

function M.run()
    M.test_known_effects()
    M.test_bonuses()
    M.test_visual()
    M.test_apply_to_card()
    M.test_hwatu_hologram()
    M.test_hwatu_foil()
    M.test_hwatu_polychrome()
    M.test_hwatu_mixed_and_none()
    M.test_hwatu_rejects_unknown()
    print("  card_effects: OK")
end

function M.test_known_effects()
    assert(effects.HOLOGRAM == "hologram")
    assert(effects.FOIL == "foil")
    assert(effects.POLYCHROME == "polychrome")
    assert(effects.is_known("hologram"))
    assert(effects.is_known("foil"))
    assert(effects.is_known("polychrome"))
    assert(not effects.is_known("gold"))
    assert(not effects.is_known(nil))
end

function M.test_bonuses()
    local holo = effects.bonus("hologram")
    assert(holo.chips == 0)
    assert(holo.mult_add == 10)
    assert(holo.mult_mul == 1)

    local foil = effects.bonus("foil")
    assert(foil.chips == 50)
    assert(foil.mult_add == 0)
    assert(foil.mult_mul == 1)

    local poly = effects.bonus("polychrome")
    assert(poly.chips == 0)
    assert(poly.mult_add == 0)
    assert(poly.mult_mul == 1.5)

    local none = effects.bonus(nil)
    assert(none.chips == 0 and none.mult_add == 0 and none.mult_mul == 1)

    local ok = pcall(effects.bonus, "gold")
    assert(not ok, "unknown effect must error")
end

function M.test_visual()
    local holo = effects.visual("hologram")
    assert(holo.kind == "hologram")
    assert(holo.style == "rainbow_translucent")
    assert(type(holo.alpha) == "number" and holo.alpha > 0 and holo.alpha < 1)

    local foil = effects.visual("foil")
    assert(foil.kind == "foil")
    assert(foil.style == "sparkle_overlay")

    local poly = effects.visual("polychrome")
    assert(poly.kind == "polychrome")
    assert(poly.style == "color_shift")

    assert(effects.visual(nil) == nil)

    local c0 = effects.overlay_color("hologram", 0)
    local c1 = effects.overlay_color("hologram", 0.7)
    assert(type(c0[1]) == "number" and #c0 == 4)
    assert(c0[1] ~= c1[1] or c0[2] ~= c1[2], "hologram hue must shift over time")

    local f = effects.overlay_color("foil", 0)
    assert(f[1] > 0.7 and f[3] > 0.8, "foil is silver-blue")

    local p = effects.overlay_color("polychrome", 0.4)
    assert(#p == 4 and p[4] > 0)
end

function M.test_apply_to_card()
    local c = { kind = "pi" }
    effects.apply(c, "foil")
    assert(c.effect == "foil")
    assert(c.kind == "pi")

    local ok = pcall(effects.apply, c, "gold")
    assert(not ok, "unknown effect rejected")
end

function M.test_hwatu_hologram()
    -- 3 pi: chips 3, mult 1 → hologram adds +10 mult → 3 * 11 = 33
    local r = hwatu.evaluate(cards_with(
        { kind = "pi", effect = "hologram" },
        "pi",
        "pi"
    ))
    assert(#r.yaku == 0)
    assert(r.chips == 3)
    assert(r.mult == 11)
    assert(r.score == 33)
    assert(r.effect_chips == 0)
    assert(r.effect_mult_add == 10)
    assert(r.effect_mult_mul == 1)
end

function M.test_hwatu_foil()
    -- 1 pi foil: chips 1+50, mult 1 → 51
    local r = hwatu.evaluate(cards_with({ kind = "pi", effect = "foil" }))
    assert(r.chips == 51)
    assert(r.mult == 1)
    assert(r.score == 51)
    assert(r.effect_chips == 50)
end

function M.test_hwatu_polychrome()
    -- 3 hongdan yaku mult 2, plus polychrome ×1.5 → 2 * 1.5 = 3
    -- chips: 10+10+10 = 30, score 90
    local r = hwatu.evaluate(cards_with(
        { kind = "hongdan", effect = "polychrome" },
        "hongdan",
        "hongdan"
    ))
    assert(r.yaku[1] == "hongdan")
    assert(r.chips == 30)
    assert(r.mult == 3)
    assert(r.score == 90)
    assert(r.effect_mult_mul == 1.5)
end

function M.test_hwatu_mixed_and_none()
    -- foil + hologram + polychrome on 3 pi (no yaku):
    -- chips 1+1+1+50 = 53; mult (1+10)*1.5 = 16.5; score 53*16.5
    local r = hwatu.evaluate(cards_with(
        { kind = "pi", effect = "foil" },
        { kind = "pi", effect = "hologram" },
        { kind = "pi", effect = "polychrome" }
    ))
    assert(r.chips == 53)
    assert(r.mult == 16.5)
    assert(r.score == 53 * 16.5)
    assert(r.effect_chips == 50)
    assert(r.effect_mult_add == 10)
    assert(r.effect_mult_mul == 1.5)

    -- no effects: same as before
    local none = hwatu.evaluate(cards_with("pi", "pi", "pi"))
    assert(none.chips == 3)
    assert(none.mult == 1)
    assert(none.score == 3)
    assert(none.effect_chips == 0)
    assert(none.effect_mult_add == 0)
    assert(none.effect_mult_mul == 1)
end

function M.test_hwatu_rejects_unknown()
    local ok = pcall(hwatu.evaluate, { { kind = "pi", effect = "gold" } })
    assert(not ok, "unknown card effect rejected")

    local month = pcall(hwatu.card, "pi", { effect = "foil", month = 1 })
    assert(not month, "month still forbidden with effects")

    local face = hwatu.card("pi", { effect = "foil" })
    assert(face.kind == "pi")
    assert(face.effect == "foil")
    assert(face.month == nil)
end

return M
