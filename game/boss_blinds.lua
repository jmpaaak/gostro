-- game/boss_blinds.lua
-- Balatro-style boss blind debuffs, mapped onto hwatu play kinds.
-- Headless-safe. Gwang = jokers; never 고수패. No month numbers.

local M = {}

local PLAY_KINDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

local CHIP_VALUE = {
    hongdan = 10,
    cheongdan = 10,
    chodan = 10,
    godori = 20,
    pi = 1,
}

-- 8 boss blinds. Kind-targeted ones hit hongdan/cheongdan/chodan/godori/pi.
M.POOL = {
    { id = "hook",    name = "갈고리",   effect = "discard_hand",   amount = 2 },
    { id = "wall",    name = "성벽",     effect = "double_target" },
    { id = "flint",   name = "부싯돌",   effect = "halve_score" },
    { id = "mark",    name = "낙인",     effect = "flip_kind",      kind = "hongdan" },
    { id = "fish",    name = "물고기",   effect = "hide_hand" },
    { id = "psychic", name = "영매",     effect = "full_hand",      amount = 5 },
    { id = "goad",    name = "몰이",     effect = "score_only_kind", kind = "godori" },
    { id = "plant",   name = "초목",     effect = "debuff_kind",     kind = "cheongdan" },
}

local BY_ID = {}
for _, t in ipairs(M.POOL) do
    BY_ID[t.id] = t
end

function M.by_id(id)
    local t = BY_ID[id]
    if not t then
        error("unknown boss: " .. tostring(id))
    end
    return t
end

--- Pick a random boss. Optional rng(min, max) matching math.random.
function M.random(rng)
    rng = rng or math.random
    return M.POOL[rng(1, #M.POOL)]
end

local function copy_card(card)
    local out = { kind = card.kind }
    if card.effect then
        out.effect = card.effect
    end
    if card.face_down then
        out.face_down = true
    end
    if card.hidden then
        out.hidden = true
    end
    return out
end

local function copy_hand(hand)
    local out = {}
    for i = 1, #hand do
        out[i] = copy_card(hand[i])
    end
    return out
end

--- The Hook: randomly discard `amount` cards from the current hand.
function M.apply_hook(hand, rng)
    rng = rng or math.random
    local remaining = copy_hand(hand)
    local discarded = {}
    local n = 2
    if n > #remaining then
        n = #remaining
    end
    for _ = 1, n do
        local idx = rng(1, #remaining)
        discarded[#discarded + 1] = remaining[idx]
        table.remove(remaining, idx)
    end
    return remaining, discarded
end

--- The Wall: double the blind target.
function M.apply_wall(target)
    return target * 2
end

--- The Flint: halve chips and mult (floor), then recompute score.
function M.apply_flint(result)
    local chips = math.floor((result.chips or 0) / 2)
    local mult = math.floor((result.mult or 1) / 2)
    if mult < 1 then
        mult = 1
    end
    return {
        chips = chips,
        mult = mult,
        score = chips * mult,
        yaku = result.yaku,
    }
end

--- The Mark: flip a specific hwatu kind face-down.
function M.apply_mark(hand, kind)
    if not PLAY_KINDS[kind] then
        error("mark kind must be a play kind")
    end
    local out = copy_hand(hand)
    for i = 1, #out do
        if out[i].kind == kind then
            out[i].face_down = true
        end
    end
    return out
end

--- The Fish: hide every card in the hand (face values unknown).
function M.apply_fish(hand)
    local out = copy_hand(hand)
    for i = 1, #out do
        out[i].hidden = true
    end
    return out
end

--- The Psychic: only a 5-card full hand may be played.
function M.psychic_allows(n)
    if n == 5 then
        return true
    end
    return false, "psychic requires a 5-card hand"
end

local function chips_of_kind(kind)
    return CHIP_VALUE[kind] or 0
end

--- The Goad: only one hwatu kind scores chips.
function M.apply_goad(result, hand, kind)
    if not PLAY_KINDS[kind] then
        error("goad kind must be a play kind")
    end
    local chips = 0
    for i = 1, #hand do
        if hand[i].kind == kind then
            chips = chips + chips_of_kind(kind)
        end
    end
    local mult = result.mult or 1
    return {
        chips = chips,
        mult = mult,
        score = chips * mult,
        yaku = result.yaku,
    }
end

--- The Plant: a specific hwatu kind is debuffed (0 chips).
function M.apply_plant(result, hand, kind)
    if not PLAY_KINDS[kind] then
        error("plant kind must be a play kind")
    end
    local chips = 0
    for i = 1, #hand do
        if hand[i].kind ~= kind then
            chips = chips + chips_of_kind(hand[i].kind)
        end
    end
    local mult = result.mult or 1
    return {
        chips = chips,
        mult = mult,
        score = chips * mult,
        yaku = result.yaku,
    }
end

--- Apply a boss definition onto a scoring result / hand snapshot.
-- Returns a table of side-effects used by run/play.
function M.apply(def, ctx)
    ctx = ctx or {}
    local effect = def.effect
    if effect == "discard_hand" then
        local kept, discarded = M.apply_hook(ctx.hand or {}, ctx.rng)
        return { hand = kept, discarded = discarded }
    elseif effect == "double_target" then
        return { target = M.apply_wall(ctx.target or 0) }
    elseif effect == "halve_score" then
        return { result = M.apply_flint(ctx.result or { chips = 0, mult = 1, score = 0 }) }
    elseif effect == "flip_kind" then
        return { hand = M.apply_mark(ctx.hand or {}, def.kind) }
    elseif effect == "hide_hand" then
        return { hand = M.apply_fish(ctx.hand or {}) }
    elseif effect == "full_hand" then
        local ok, err = M.psychic_allows(ctx.n or 0)
        return { allowed = ok, err = err }
    elseif effect == "score_only_kind" then
        return { result = M.apply_goad(ctx.result or { chips = 0, mult = 1 }, ctx.hand or {}, def.kind) }
    elseif effect == "debuff_kind" then
        return { result = M.apply_plant(ctx.result or { chips = 0, mult = 1 }, ctx.hand or {}, def.kind) }
    else
        error("unknown boss effect: " .. tostring(effect))
    end
end

return M
