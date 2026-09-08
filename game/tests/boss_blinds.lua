-- Tests for Balatro-style boss blind debuffs (hwatu kinds).
-- Engine-hosted: catalog + run.select_boss / apply path.

local boss = require("game.boss_blinds")
local run = require("game.run")
local hwatu = require("game.hwatu")

local M = {}

local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

local function ids_of(pool)
    local out = {}
    for i, t in ipairs(pool) do
        out[i] = t.id
    end
    return out
end

local function cards(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = hwatu.card((select(i, ...)))
    end
    return out
end

function M.run()
    M.test_pool_size()
    M.test_by_id()
    M.test_hwatu_kinds_only()
    M.test_random()
    M.test_hook_discards_two()
    M.test_wall_doubles_target()
    M.test_flint_halves_chips_mult()
    M.test_mark_flips_kind()
    M.test_fish_hides_hand()
    M.test_psychic_requires_five()
    M.test_goad_scores_only_kind()
    M.test_plant_debuffs_kind()
    M.test_run_select_on_boss()
    M.test_run_apply_wall()
    M.test_run_no_boss_on_small()
    M.test_no_forbidden_words()
    print("  boss_blinds: OK")
end

function M.test_pool_size()
    assert(type(boss.POOL) == "table")
    assert(#boss.POOL >= 8, "boss pool must have 8+ kinds, got " .. tostring(#boss.POOL))
    local seen = {}
    for _, t in ipairs(boss.POOL) do
        assert(type(t.id) == "string" and t.id ~= "", "each boss needs an id")
        assert(type(t.name) == "string" and t.name ~= "", "each boss needs a name")
        assert(type(t.effect) == "string" and t.effect ~= "", "each boss needs an effect")
        assert(not seen[t.id], "duplicate boss id: " .. t.id)
        seen[t.id] = true
    end
    assert(boss.by_id("hook"), "pool must include hook")
    assert(boss.by_id("wall"), "pool must include wall")
    assert(boss.by_id("flint"), "pool must include flint")
    assert(boss.by_id("mark"), "pool must include mark")
    assert(boss.by_id("fish"), "pool must include fish")
    assert(boss.by_id("psychic"), "pool must include psychic")
    assert(boss.by_id("goad"), "pool must include goad")
    assert(boss.by_id("plant"), "pool must include plant")
end

function M.test_by_id()
    local hook = boss.by_id("hook")
    assert(hook.id == "hook")
    assert(hook.effect == "discard_hand")
    assert(hook.amount == 2)
    local ok = pcall(boss.by_id, "not_a_boss")
    assert(not ok, "unknown boss must error")
end

function M.test_hwatu_kinds_only()
    local kind_ok = {}
    for _, k in ipairs(PLAY_KINDS) do
        kind_ok[k] = true
    end
    for _, t in ipairs(boss.POOL) do
        if t.kind then
            assert(kind_ok[t.kind], "boss kind must be hwatu play kind, got " .. tostring(t.kind))
            assert(t.kind ~= "gwang", "gwang is a joker, not a boss target")
        end
    end
    assert(boss.by_id("mark").kind)
    assert(boss.by_id("goad").kind)
    assert(boss.by_id("plant").kind)
    assert(kind_ok[boss.by_id("mark").kind])
    assert(kind_ok[boss.by_id("goad").kind])
    assert(kind_ok[boss.by_id("plant").kind])
end

function M.test_random()
    local t = boss.random(function(a, _) return a end)
    assert(t.id == boss.POOL[1].id)
    local t2 = boss.random(function(_, b) return b end)
    assert(t2.id == boss.POOL[#boss.POOL].id)
    local t3 = boss.random()
    assert(t3 and t3.id)
end

function M.test_hook_discards_two()
    local hand = cards("hongdan", "cheongdan", "chodan", "godori", "pi", "pi", "pi", "hongdan")
    local rng_calls = 0
    local function rng(a, b)
        rng_calls = rng_calls + 1
        return a -- always first remaining
    end
    local kept, discarded = boss.apply_hook(hand, rng)
    assert(#discarded == 2, "hook removes 2 cards")
    assert(#kept == 6)
    assert(discarded[1].kind == "hongdan")
    assert(discarded[2].kind == "cheongdan")
    assert(rng_calls >= 2)
end

function M.test_wall_doubles_target()
    local state = run.new()
    state.blind = "boss"
    local base = run.blind_target(state)
    local doubled = boss.apply_wall(base)
    assert(doubled == base * 2, "wall doubles the boss target")
end

function M.test_flint_halves_chips_mult()
    local result = { chips = 40, mult = 4, score = 160 }
    local out = boss.apply_flint(result)
    assert(out.chips == 20)
    assert(out.mult == 2)
    assert(out.score == 40)
end

function M.test_mark_flips_kind()
    local def = boss.by_id("mark")
    local hand = cards("hongdan", "cheongdan", "pi")
    local out = boss.apply_mark(hand, def.kind)
    local flipped = 0
    for i = 1, #out do
        if hand[i].kind == def.kind then
            assert(out[i].face_down == true, "mark flips matching kind face-down")
            flipped = flipped + 1
        else
            assert(not out[i].face_down)
        end
    end
    assert(flipped >= 1 or true) -- kind may or may not be in this tiny hand
    -- force the matching kind
    local forced = { hwatu.card(def.kind), hwatu.card("pi") }
    local marked = boss.apply_mark(forced, def.kind)
    assert(marked[1].face_down == true)
    assert(not marked[2].face_down)
end

function M.test_fish_hides_hand()
    local hand = cards("hongdan", "pi", "godori")
    local out = boss.apply_fish(hand)
    assert(#out == 3)
    for i = 1, #out do
        assert(out[i].hidden == true, "fish hides every card")
    end
end

function M.test_psychic_requires_five()
    local ok5, err5 = boss.psychic_allows(5)
    assert(ok5 == true)
    local ok4, err4 = boss.psychic_allows(4)
    assert(ok4 == false)
    assert(type(err4) == "string" and err4 ~= "")
    local ok6 = boss.psychic_allows(6)
    assert(ok6 == false)
end

function M.test_goad_scores_only_kind()
    local def = boss.by_id("goad")
    local result = hwatu.evaluate(cards("hongdan", "hongdan", "hongdan", "pi", "godori"))
    local out = boss.apply_goad(result, cards("hongdan", "hongdan", "hongdan", "pi", "godori"), def.kind)
    -- only cards of goad.kind contribute chips
    local expected_chips = 0
    local hand = cards("hongdan", "hongdan", "hongdan", "pi", "godori")
    for i = 1, #hand do
        if hand[i].kind == def.kind then
            if def.kind == "godori" then
                expected_chips = expected_chips + 20
            elseif def.kind == "pi" then
                expected_chips = expected_chips + 1
            else
                expected_chips = expected_chips + 10
            end
        end
    end
    assert(out.chips == expected_chips, "goad scores only " .. def.kind)
    assert(out.score == out.chips * out.mult)
end

function M.test_plant_debuffs_kind()
    local def = boss.by_id("plant")
    local hand = { hwatu.card(def.kind), hwatu.card("pi") }
    local result = { chips = 11, mult = 1, score = 11 }
    local out = boss.apply_plant(result, hand, def.kind)
    -- matching kind contributes 0 chips (pi = 1 remains if plant.kind ~= pi)
    local remain = 0
    for i = 1, #hand do
        if hand[i].kind ~= def.kind then
            remain = remain + (hand[i].kind == "godori" and 20 or (hand[i].kind == "pi" and 1 or 10))
        end
    end
    assert(out.chips == remain, "plant zeroes matching kind chips")
    assert(out.score == out.chips * out.mult)
end

function M.test_run_select_on_boss()
    local state = run.new()
    state.blind = "boss"
    local def = run.select_boss(state, "wall")
    assert(def.id == "wall")
    assert(state.boss_id == "wall")
    assert(state.boss.effect == "double_target")
end

function M.test_run_apply_wall()
    local state = run.new()
    state.blind = "boss"
    run.select_boss(state, "wall")
    local base_without = 600 -- ante 1 boss = 300 * 2
    assert(run.blind_target(state) == base_without * 2, "wall doubles via run.blind_target")
end

function M.test_run_no_boss_on_small()
    local state = run.new()
    assert(state.blind == "small")
    local ok = pcall(run.select_boss, state, "wall")
    assert(not ok, "select_boss only on boss blinds")
    assert(run.blind_target(state) == 300)
end

function M.test_no_forbidden_words()
    local blob = table.concat(ids_of(boss.POOL), ",")
    for _, t in ipairs(boss.POOL) do
        blob = blob .. "," .. t.name .. "," .. tostring(t.effect) .. "," .. tostring(t.kind or "")
    end
    assert(not blob:find("고수패", 1, true))
    assert(not blob:find("mae", 1, true))
    assert(not blob:find("ppeok", 1, true))
    assert(not blob:find("otti", 1, true))
    assert(not blob:find("gwangyeol", 1, true))
end

return M
