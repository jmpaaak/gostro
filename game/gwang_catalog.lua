-- Gwang joker catalog: JSON identities + trigger apply loop.
-- Triggers: always (+chips, +mult), contains_kind (×mult if kind in hand),
-- yaku (+chips when scored yaku matches yaku_need),
-- deck_size (×mult when play-card deck count ≤ deck_max),
-- money (+mult when held money ≥ money_min),
-- blind (×mult when current blind matches blind_need, e.g. boss).

local M = {}

local DATA_PATH = "game/data/gwang_jokers.json"

local cached = nil
local by_id = nil

local function skip_ws(str, i)
    local _, e = str:find("^[ \t\n\r]*", i)
    return (e or i - 1) + 1
end

local function parse_string(str, i)
    i = i + 1
    local buf = {}
    while i <= #str do
        local c = str:sub(i, i)
        if c == '"' then
            return table.concat(buf), i + 1
        elseif c == "\\" then
            local n = str:sub(i + 1, i + 1)
            local map = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }
            if n == "u" then
                local hex = str:sub(i + 2, i + 5)
                buf[#buf + 1] = string.char(tonumber(hex, 16) % 256)
                i = i + 6
            else
                buf[#buf + 1] = map[n] or n
                i = i + 2
            end
        else
            buf[#buf + 1] = c
            i = i + 1
        end
    end
    error("unterminated json string")
end

local function parse_number(str, i)
    local s, e = str:find("^-?%d+%.?%d*[eE]?[%+%-]?%d*", i)
    return tonumber(str:sub(s, e)), e + 1
end

local parse_value

local function parse_array(str, i)
    i = skip_ws(str, i + 1)
    local arr = {}
    if str:sub(i, i) == "]" then
        return arr, i + 1
    end
    while true do
        local v
        v, i = parse_value(str, i)
        arr[#arr + 1] = v
        i = skip_ws(str, i)
        local c = str:sub(i, i)
        if c == "]" then
            return arr, i + 1
        end
        if c ~= "," then
            error("expected comma in json array at " .. i)
        end
        i = skip_ws(str, i + 1)
    end
end

local function parse_object(str, i)
    i = skip_ws(str, i + 1)
    local obj = {}
    if str:sub(i, i) == "}" then
        return obj, i + 1
    end
    while true do
        i = skip_ws(str, i)
        if str:sub(i, i) ~= '"' then
            error("expected string key at " .. i)
        end
        local key
        key, i = parse_string(str, i)
        i = skip_ws(str, i)
        if str:sub(i, i) ~= ":" then
            error("expected colon at " .. i)
        end
        local val
        val, i = parse_value(str, skip_ws(str, i + 1))
        obj[key] = val
        i = skip_ws(str, i)
        local c = str:sub(i, i)
        if c == "}" then
            return obj, i + 1
        end
        if c ~= "," then
            error("expected comma in json object at " .. i)
        end
        i = skip_ws(str, i + 1)
    end
end

parse_value = function(str, i)
    i = skip_ws(str, i)
    local c = str:sub(i, i)
    if c == "{" then
        return parse_object(str, i)
    elseif c == "[" then
        return parse_array(str, i)
    elseif c == '"' then
        return parse_string(str, i)
    elseif c == "-" or (c >= "0" and c <= "9") then
        return parse_number(str, i)
    elseif str:sub(i, i + 3) == "true" then
        return true, i + 4
    elseif str:sub(i, i + 4) == "false" then
        return false, i + 5
    elseif str:sub(i, i + 3) == "null" then
        return nil, i + 4
    end
    error("bad json at " .. i)
end

local function decode_json(str)
    local v = parse_value(str, 1)
    return v
end

local function read_json()
    local raw
    if love and love.filesystem and love.filesystem.read then
        raw = love.filesystem.read(DATA_PATH)
    end
    if not raw then
        local f = io.open(DATA_PATH, "r")
        if f then
            raw = f:read("*a")
            f:close()
        end
    end
    if not raw then
        error("missing gwang catalog: " .. DATA_PATH)
    end
    return decode_json(raw)
end

local function load()
    if cached then
        return cached
    end
    local data = read_json()
    local jokers = data.jokers or data
    cached = {}
    by_id = {}
    for i = 1, #jokers do
        local j = jokers[i]
        if type(j) == "table" and j.id then
            cached[#cached + 1] = j
            by_id[j.id] = j
        end
    end
    return cached
end

function M.all()
    load()
    return cached
end

function M.get(id)
    load()
    return by_id[id]
end

local function hand_has_kind(hand, kind)
    if type(hand) ~= "table" or not kind then
        return false
    end
    for i = 1, #hand do
        local c = hand[i]
        if c and c.kind == kind then
            return true
        end
    end
    return false
end

local function yaku_has(yaku, need)
    if type(yaku) ~= "table" or not need then
        return false
    end
    for i = 1, #yaku do
        if yaku[i] == need then
            return true
        end
    end
    return false
end

local function deck_count(ctx)
    if type(ctx.deck_size) == "number" then
        return ctx.deck_size
    end
    local state = ctx.state
    if type(state) ~= "table" or type(state.deck) ~= "table" then
        return nil
    end
    local cards = state.deck.cards
    if type(cards) == "table" then
        return #cards
    end
    return nil
end

local function money_held(ctx)
    if type(ctx.money) == "number" then
        return ctx.money
    end
    local state = ctx.state
    if type(state) == "table" and type(state.money) == "number" then
        return state.money
    end
    return nil
end

local function current_blind(ctx)
    if type(ctx.blind) == "string" then
        return ctx.blind
    end
    local state = ctx.state
    if type(state) == "table" and type(state.blind) == "string" then
        return state.blind
    end
    return nil
end

local function should_trigger(def, ctx)
    if def.trigger == "always" then
        return true
    end
    if def.trigger == "contains_kind" then
        return hand_has_kind(ctx.hand, def.kind_need)
    end
    if def.trigger == "yaku" then
        return yaku_has(ctx.yaku, def.yaku_need)
    end
    if def.trigger == "deck_size" then
        local n = deck_count(ctx)
        local max = def.deck_max
        return type(n) == "number" and type(max) == "number" and n <= max
    end
    if def.trigger == "money" then
        local n = money_held(ctx)
        local min = def.money_min
        return type(n) == "number" and type(min) == "number" and n >= min
    end
    if def.trigger == "blind" then
        local b = current_blind(ctx)
        local need = def.blind_need
        return type(b) == "string" and type(need) == "string" and b == need
    end
    return false
end

local function apply_effect(chips, mult, effect)
    local e = effect or {}
    if e.chips then
        chips = chips + e.chips
    end
    if e.mult then
        mult = mult + e.mult
    end
    if e.mult_mul then
        mult = mult * e.mult_mul
    end
    return chips, mult
end

--- Apply equipped gwang to a scored hand.
-- ctx = { chips, mult, yaku, state, hand, deck_size, money, blind }
-- always: +chips / +mult every hand.
-- contains_kind: fire when ctx.hand includes def.kind_need (e.g. hongdan → ×2).
-- yaku: fire when ctx.yaku includes def.yaku_need (e.g. godori → +100 chips).
-- deck_size: fire when play-card count (ctx.deck_size or state.deck) ≤ deck_max.
-- money: fire when held money (ctx.money or state.money) ≥ money_min.
-- blind: fire when current blind (ctx.blind or state.blind) == blind_need (e.g. boss → ×2).
function M.apply(ctx)
    local chips = ctx.chips or 0
    local mult = ctx.mult or 1
    local triggered = {}
    local state = ctx.state
    if not state or type(state.gwang) ~= "table" then
        return chips, mult, triggered
    end
    load()
    for i = 1, #state.gwang do
        local g = state.gwang[i]
        local id = g and g.identity
        local def = id and by_id[id]
        if def and should_trigger(def, ctx) then
            chips, mult = apply_effect(chips, mult, def.effect)
            triggered[#triggered + 1] = { id = def.id, slot = i }
        end
    end
    return chips, mult, triggered
end

return M
