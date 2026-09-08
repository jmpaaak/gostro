-- Gwang joker catalog: JSON identities + trigger apply loop.
-- This slice: always-trigger (+chips, +mult) only.

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

--- Apply equipped gwang to a scored hand.
-- ctx = { chips, mult, yaku, state, hand }
-- Always-trigger this slice: +chips and +mult every hand.
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
        if def and def.trigger == "always" then
            local e = def.effect or {}
            if e.chips then
                chips = chips + e.chips
            end
            if e.mult then
                mult = mult + e.mult
            end
            triggered[#triggered + 1] = { id = def.id, slot = i }
        end
    end
    return chips, mult, triggered
end

return M
