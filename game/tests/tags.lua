-- Tests for Balatro-style skip tags (small/big blind skip rewards).
-- Engine-hosted: catalog + run.skip_blind path.

local tags = require("game.tags")
local run = require("game.run")

local M = {}

local function ids_of(pool)
    local out = {}
    for i, t in ipairs(pool) do
        out[i] = t.id
    end
    return out
end

function M.run()
    M.test_pool_size()
    M.test_by_id()
    M.test_random()
    M.test_apply_coupon()
    M.test_apply_money()
    M.test_apply_editions()
    M.test_apply_mega()
    M.test_apply_shop_and_hand()
    M.test_skip_small()
    M.test_skip_big()
    M.test_cannot_skip_boss()
    M.test_cannot_skip_outside_play()
    M.test_skip_specified_tag()
    M.test_no_forbidden_words()
    print("  tags: OK")
end

function M.test_pool_size()
    assert(type(tags.POOL) == "table")
    assert(#tags.POOL >= 10, "tag pool must have 10+ kinds, got " .. tostring(#tags.POOL))
    local seen = {}
    for _, t in ipairs(tags.POOL) do
        assert(type(t.id) == "string" and t.id ~= "", "each tag needs an id")
        assert(type(t.name) == "string" and t.name ~= "", "each tag needs a name")
        assert(not seen[t.id], "duplicate tag id: " .. t.id)
        seen[t.id] = true
    end
    assert(tags.by_id("coupon"), "pool must include coupon (free reroll)")
    assert(tags.by_id("investment"), "pool must include investment (extra money)")
    assert(tags.by_id("mega"), "pool must include mega (duplicate next gwang)")
end

function M.test_by_id()
    local coupon = tags.by_id("coupon")
    assert(coupon.id == "coupon")
    assert(coupon.effect == "free_reroll")
    local ok = pcall(tags.by_id, "not_a_tag")
    assert(not ok, "unknown tag must error")
end

function M.test_random()
    local seen = {}
    for _ = 1, 80 do
        local t = tags.random(function(a, b) return a end) -- always first
        assert(t.id == tags.POOL[1].id)
        seen[t.id] = true
    end
    local t2 = tags.random(function(_, b) return b end) -- always last
    assert(t2.id == tags.POOL[#tags.POOL].id)
    local t3 = tags.random()
    assert(t3 and t3.id)
end

function M.test_apply_coupon()
    local state = run.new()
    tags.apply(state, "coupon")
    assert(state.tags.free_rerolls == 1)
    tags.apply(state, "coupon")
    assert(state.tags.free_rerolls == 2)
    assert(state.tags.owned[1] == "coupon")
end

function M.test_apply_money()
    local state = run.new()
    tags.apply(state, "investment")
    assert(state.tags.pending_money == 15)
    tags.apply(state, "handy")
    assert(state.tags.pending_money == 15 + tags.by_id("handy").amount)
    tags.apply(state, "economy")
    assert(state.tags.pending_money == 15 + tags.by_id("handy").amount + tags.by_id("economy").amount)
end

function M.test_apply_editions()
    local state = run.new()
    tags.apply(state, "foil")
    assert(state.tags.next_gwang_edition == "foil")
    tags.apply(state, "hologram")
    assert(state.tags.next_gwang_edition == "hologram")
    tags.apply(state, "polychrome")
    assert(state.tags.next_gwang_edition == "polychrome")
end

function M.test_apply_mega()
    local state = run.new()
    assert(not state.tags or not state.tags.duplicate_next_gwang)
    tags.apply(state, "mega")
    assert(state.tags.duplicate_next_gwang == true)
end

function M.test_apply_shop_and_hand()
    local state = run.new()
    tags.apply(state, "charm")
    assert(state.tags.extra_shop_slots >= 1)
    tags.apply(state, "uncommon")
    assert(state.tags.uncommon_shop == true)
    tags.apply(state, "juggle")
    assert(state.tags.hand_size_bonus >= 1)
    tags.apply(state, "d6")
    assert(state.tags.free_rerolls >= 2)
end

function M.test_skip_small()
    local state = run.new()
    assert(state.blind == "small")
    assert(state.phase == "play")
    run.skip_blind(state, "coupon")
    assert(state.phase == "play", "skip does not enter shop")
    assert(state.blind == "big", "skip small -> big")
    assert(state.round_score == 0)
    assert(state.tags.owned[1] == "coupon")
    assert(state.tags.free_rerolls == 1)
end

function M.test_skip_big()
    local state = run.new()
    state.blind = "big"
    run.skip_blind(state, "mega")
    assert(state.phase == "play")
    assert(state.blind == "boss", "skip big -> boss")
    assert(state.tags.duplicate_next_gwang == true)
end

function M.test_cannot_skip_boss()
    local state = run.new()
    state.blind = "boss"
    local ok = pcall(run.skip_blind, state, "coupon")
    assert(not ok, "cannot skip boss blind")
    assert(state.blind == "boss")
end

function M.test_cannot_skip_outside_play()
    local state = run.new()
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
    assert(state.phase == "shop")
    local ok = pcall(run.skip_blind, state, "coupon")
    assert(not ok, "skip only during play")
end

function M.test_skip_specified_tag()
    local state = run.new()
    run.skip_blind(state, "investment")
    assert(state.tags.pending_money == 15)
    assert(state.blind == "big")
end

function M.test_no_forbidden_words()
    local blob = table.concat(ids_of(tags.POOL), ",")
    for _, t in ipairs(tags.POOL) do
        blob = blob .. "," .. t.name .. "," .. tostring(t.effect)
    end
    assert(not blob:find("고수패", 1, true))
    assert(not blob:find("mae", 1, true))
    assert(not blob:find("ppeok", 1, true))
    assert(not blob:find("otti", 1, true))
    assert(not blob:find("gwangyeol", 1, true))
end

return M
