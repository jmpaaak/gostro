-- Runtime image access controlled by assets/manifest.json.
-- Pending or incomplete records intentionally resolve to nil so callers retain fallbacks.

local M = {}
local MANIFEST_PATH = "assets/manifest.json"

local manifest_cache
local entries_by_id
local texture_cache = {}

local runtime_api = {
    read = function(path)
        if love and love.filesystem and love.filesystem.read then
            return love.filesystem.read(path)
        end
        local file = io.open(path, "rb")
        if not file then return nil end
        local value = file:read("*a")
        file:close()
        return value
    end,
    new_image = function(path)
        return love.graphics.newImage(path)
    end,
}

local function skip_ws(source, index)
    local _, last = source:find("^[ \t\n\r]*", index)
    return (last or index - 1) + 1
end

local function parse_string(source, index)
    index = index + 1
    local parts = {}
    while index <= #source do
        local char = source:sub(index, index)
        if char == '"' then
            return table.concat(parts), index + 1
        elseif char == "\\" then
            local escaped = source:sub(index + 1, index + 1)
            local replacements = {
                ['"'] = '"', ["\\"] = "\\", ["/"] = "/",
                b = "\b", f = "\f", n = "\n", r = "\r", t = "\t",
            }
            if escaped == "u" then
                -- Manifest lookup keys and paths are ASCII. Preserve other escaped
                -- codepoints as UTF-8 when LÖVE's utf8 module is available.
                local codepoint = tonumber(source:sub(index + 2, index + 5), 16)
                if utf8 and utf8.char then
                    parts[#parts + 1] = utf8.char(codepoint)
                else
                    parts[#parts + 1] = "?"
                end
                index = index + 6
            else
                parts[#parts + 1] = replacements[escaped] or escaped
                index = index + 2
            end
        else
            parts[#parts + 1] = char
            index = index + 1
        end
    end
    error("unterminated JSON string")
end

local function parse_number(source, index)
    local first, last = source:find("^-?%d+%.?%d*[eE]?[%+%-]?%d*", index)
    if not first then error("invalid JSON number at " .. index) end
    return tonumber(source:sub(first, last)), last + 1
end

local parse_value

local function parse_array(source, index)
    index = skip_ws(source, index + 1)
    local result = {}
    if source:sub(index, index) == "]" then return result, index + 1 end
    while true do
        local value
        value, index = parse_value(source, index)
        result[#result + 1] = value
        index = skip_ws(source, index)
        local char = source:sub(index, index)
        if char == "]" then return result, index + 1 end
        if char ~= "," then error("expected JSON array comma at " .. index) end
        index = skip_ws(source, index + 1)
    end
end

local function parse_object(source, index)
    index = skip_ws(source, index + 1)
    local result = {}
    if source:sub(index, index) == "}" then return result, index + 1 end
    while true do
        index = skip_ws(source, index)
        if source:sub(index, index) ~= '"' then
            error("expected JSON object key at " .. index)
        end
        local key
        key, index = parse_string(source, index)
        index = skip_ws(source, index)
        if source:sub(index, index) ~= ":" then
            error("expected JSON object colon at " .. index)
        end
        local value
        value, index = parse_value(source, skip_ws(source, index + 1))
        result[key] = value
        index = skip_ws(source, index)
        local char = source:sub(index, index)
        if char == "}" then return result, index + 1 end
        if char ~= "," then error("expected JSON object comma at " .. index) end
        index = skip_ws(source, index + 1)
    end
end

parse_value = function(source, index)
    index = skip_ws(source, index)
    local char = source:sub(index, index)
    if char == "{" then return parse_object(source, index) end
    if char == "[" then return parse_array(source, index) end
    if char == '"' then return parse_string(source, index) end
    if char == "-" or char:match("%d") then return parse_number(source, index) end
    if source:sub(index, index + 3) == "true" then return true, index + 4 end
    if source:sub(index, index + 4) == "false" then return false, index + 5 end
    if source:sub(index, index + 3) == "null" then return nil, index + 4 end
    error("invalid JSON value at " .. index)
end

local function decode(source)
    local value, next_index = parse_value(source, 1)
    next_index = skip_ws(source, next_index)
    if next_index <= #source then error("trailing JSON data at " .. next_index) end
    return value
end

local function load_manifest(api)
    if manifest_cache then return manifest_cache end
    api = api or runtime_api
    local raw = api.read(MANIFEST_PATH)
    if not raw then error("missing asset manifest: " .. MANIFEST_PATH) end
    local decoded = decode(raw)
    if type(decoded) ~= "table" or type(decoded.assets) ~= "table" then
        error("invalid asset manifest: assets array is required")
    end

    manifest_cache = decoded
    entries_by_id = {}
    for i = 1, #decoded.assets do
        local entry = decoded.assets[i]
        if type(entry) == "table" and type(entry.id) == "string" then
            if entries_by_id[entry.id] then
                error("duplicate asset manifest id: " .. entry.id)
            end
            entries_by_id[entry.id] = entry
        end
    end
    return manifest_cache
end

function M.clear_cache()
    manifest_cache = nil
    entries_by_id = nil
    texture_cache = {}
end

function M.entry(id, api)
    load_manifest(api)
    return entries_by_id[id]
end

function M.runtime_path(id, api)
    local entry = M.entry(id, api)
    local runtime = entry and entry.runtime
    if not entry or entry.status ~= "runtime" or type(runtime) ~= "table" then
        return nil
    end
    if type(runtime.path) ~= "string"
        or not runtime.path:match("^assets/runtime/.+%.png$")
        or runtime.filter ~= "nearest"
        or type(runtime.width) ~= "number"
        or type(runtime.height) ~= "number" then
        return nil
    end
    return runtime.path
end

function M.texture(id, api)
    api = api or runtime_api
    local path = M.runtime_path(id, api)
    if not path then return nil end
    if texture_cache[path] ~= nil then return texture_cache[path] or nil end

    local ok, image = pcall(api.new_image, path)
    if not ok or not image then
        texture_cache[path] = false
        return nil
    end
    if image.setFilter then image:setFilter("nearest", "nearest") end
    texture_cache[path] = image
    return image
end

return M
