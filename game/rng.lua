-- game/rng.lua
-- Balatro-style seed-string RNG. Headless-safe. No month numbers/names.
-- Named streams keep shop / cards / boss sequences independent.

local M = {}

local MOD = 4294967296 -- 2^32
local ALPH = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

local function u32(n)
    n = n % MOD
    if n < 0 then
        n = n + MOD
    end
    return n
end

--- FNV-1a-ish 32-bit mix; exact in IEEE doubles for 32-bit ints.
local function hash32(s)
    local h = 2166136261
    for i = 1, #s do
        h = u32(h + s:byte(i))
        h = u32(h * 16777619)
    end
    if h == 0 then
        h = 1
    end
    return h
end

-- Numerical Recipes LCG.
local function step(state)
    return u32(state * 1664525 + 1013904223)
end

local function rand(holder, a, b)
    holder[1] = step(holder[1])
    local u = holder[1] / MOD
    if a == nil and b == nil then
        return u
    end
    if b == nil then
        b = a
        a = 1
    end
    a = math.floor(a)
    b = math.floor(b)
    if a > b then
        a, b = b, a
    end
    return a + math.floor(u * (b - a + 1))
end

local function make_random(holder)
    return function(a, b)
        return rand(holder, a, b)
    end
end

function M.normalize(s)
    if s == nil then
        return ""
    end
    return tostring(s):upper():gsub("[^A-Z0-9]", "")
end

--- 8-char A-Z0-9 seed, Balatro-style.
function M.generate()
    local chars = {}
    for i = 1, 8 do
        local idx = math.random(1, #ALPH)
        chars[i] = ALPH:sub(idx, idx)
    end
    return table.concat(chars)
end

function M.new(seed_str)
    local seed = M.normalize(seed_str)
    if seed == "" then
        seed = M.generate()
    end
    local obj = { seed = seed, _state = { hash32(seed) } }
    obj.random = make_random(obj._state)
    function obj:stream(name)
        return M.stream(self, name)
    end
    return obj
end

--- Independent stream keyed by seed + name (shop / cards / boss).
function M.stream(self, name)
    local holder = { hash32(self.seed .. ":" .. tostring(name or "")) }
    return make_random(holder)
end

--- Run-start plan: seed → shop / cards / boss sequences.
function M.plan(seed_str)
    local r = M.new(seed_str)
    return {
        seed = r.seed,
        shop = r:stream("shop"),
        cards = r:stream("cards"),
        boss = r:stream("boss"),
    }
end

return M
