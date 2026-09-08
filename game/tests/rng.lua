-- Tests for Balatro-style seed-string RNG (INBOX 22, first slice).
-- Engine-hosted. Headless-safe. No month numbers/names.

local rng = require("game.rng")

local M = {}

local function draw_n(random, n, lo, hi)
    local out = {}
    for i = 1, n do
        out[i] = random(lo, hi)
    end
    return out
end

local function same_seq(a, b)
    if #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end

function M.run()
    M.test_generate_seed_format()
    M.test_new_displays_normalized_seed()
    M.test_new_accepts_input_seed()
    M.test_empty_seed_generates()
    M.test_same_seed_same_sequence()
    M.test_different_seed_different_sequence()
    M.test_random_matches_math_random_signature()
    M.test_streams_are_independent()
    M.test_plan_shop_cards_boss_reproducible()
    print("  rng: OK")
end

function M.test_generate_seed_format()
    local seed = rng.generate()
    assert(type(seed) == "string")
    assert(#seed == 8, "generated seed is 8 chars, got " .. tostring(#seed))
    assert(seed:match("^[A-Z0-9]+$"), "generated seed is A-Z0-9")
    local seed2 = rng.generate()
    assert(type(seed2) == "string" and #seed2 == 8)
end

function M.test_new_displays_normalized_seed()
    local r = rng.new("abcd12ef")
    assert(r.seed == "ABCD12EF", "seed display is uppercase, got " .. tostring(r.seed))
end

function M.test_new_accepts_input_seed()
    local r = rng.new("run-seed-01")
    assert(r.seed == "RUNSEED01", "input strips non-alnum, got " .. tostring(r.seed))
    local r2 = rng.new("  gostro  ")
    assert(r2.seed == "GOSTRO")
end

function M.test_empty_seed_generates()
    local r = rng.new()
    assert(type(r.seed) == "string" and #r.seed == 8)
    assert(r.seed:match("^[A-Z0-9]+$"))
    local r2 = rng.new("")
    assert(type(r2.seed) == "string" and #r2.seed == 8)
end

function M.test_same_seed_same_sequence()
    local a = rng.new("SEEDTEST")
    local b = rng.new("seedtest")
    local sa = draw_n(a.random, 32, 1, 1000)
    local sb = draw_n(b.random, 32, 1, 1000)
    assert(same_seq(sa, sb), "same seed string yields the same run")
end

function M.test_different_seed_different_sequence()
    local a = draw_n(rng.new("ALPHA001").random, 24, 1, 1000)
    local b = draw_n(rng.new("BRAVO002").random, 24, 1, 1000)
    assert(not same_seq(a, b), "different seeds must diverge")
end

function M.test_random_matches_math_random_signature()
    local r = rng.new("SIGNATURE")
    local u = r.random()
    assert(type(u) == "number" and u >= 0 and u < 1, "random() in [0,1)")
    local n = r.random(5)
    assert(n >= 1 and n <= 5 and n == math.floor(n), "random(n) in 1..n")
    local m = r.random(3, 7)
    assert(m >= 3 and m <= 7 and m == math.floor(m), "random(a,b) in a..b")
end

function M.test_streams_are_independent()
    local r = rng.new("STREAMS1")
    local shop = r:stream("shop")
    local cards = r:stream("cards")
    local boss = r:stream("boss")
    local shop_seq = draw_n(shop, 8, 1, 30)
    local card_seq = draw_n(cards, 8, 1, 5)
    local boss_seq = draw_n(boss, 8, 1, 8)
    -- Re-open streams from a fresh generator: same seed, same named streams.
    local r2 = rng.new("STREAMS1")
    assert(same_seq(shop_seq, draw_n(r2:stream("shop"), 8, 1, 30)))
    assert(same_seq(card_seq, draw_n(r2:stream("cards"), 8, 1, 5)))
    assert(same_seq(boss_seq, draw_n(r2:stream("boss"), 8, 1, 8)))
    -- Drawing shop must not change the cards stream.
    local r3 = rng.new("STREAMS1")
    r3:stream("shop")(1, 30)
    r3:stream("shop")(1, 30)
    assert(same_seq(card_seq, draw_n(r3:stream("cards"), 8, 1, 5)),
        "shop draws must not perturb the cards stream")
end

function M.test_plan_shop_cards_boss_reproducible()
    local a = rng.plan("PLANSEED")
    local b = rng.plan("planseed")
    assert(a.seed == "PLANSEED")
    assert(b.seed == "PLANSEED")
    assert(same_seq(draw_n(a.shop, 12, 1, 30), draw_n(b.shop, 12, 1, 30)))
    assert(same_seq(draw_n(a.cards, 16, 1, 5), draw_n(b.cards, 16, 1, 5)))
    local a_boss = draw_n(a.boss, 8, 1, 8)
    assert(same_seq(a_boss, draw_n(b.boss, 8, 1, 8)))
    local c = rng.plan("OTHERSEED")
    assert(not same_seq(a_boss, draw_n(c.boss, 8, 1, 8)))
end

return M
