-- Optional data-URL artwork for gwang joker slots.

local catalog = require("game.gwang_catalog")
local asset_art = require("game.ui.gwang_asset_art")

local M = {}
local cache = {}

local runtime_api = {
    decode_base64 = function(payload)
        return love.data.decode("string", "base64", payload)
    end,
    new_file_data = function(bytes, filename)
        return love.filesystem.newFileData(bytes, filename)
    end,
    new_image = function(file_data)
        return love.graphics.newImage(file_data)
    end,
    get_scissor = function()
        return love.graphics.getScissor()
    end,
    set_scissor = function(...)
        return love.graphics.setScissor(...)
    end,
    set_color = function(...)
        return love.graphics.setColor(...)
    end,
    draw = function(...)
        return love.graphics.draw(...)
    end,
}

local function image_parts(value)
    if type(value) ~= "string" then
        return nil
    end
    local subtype, payload = value:match("^data:image/([%w%.%+%-]+);base64,(.+)$")
    if not subtype or payload == "" then
        return nil
    end
    local extension = subtype == "jpeg" and "jpg" or subtype:gsub("[^%w]", "")
    if extension == "" then
        return nil
    end
    return payload, extension
end

function M.clear_cache()
    cache = {}
end

function M.texture_for(gwang, api, lookup)
    if type(gwang) ~= "table" or not gwang.identity then
        return nil
    end
    api = api or runtime_api
    lookup = lookup or catalog.get
    local definition = lookup(gwang.identity)
    local data_url = definition and definition.image
    local payload, extension = image_parts(data_url)
    if not payload then
        return nil
    end
    if cache[data_url] ~= nil then
        return cache[data_url] or nil
    end

    local ok, texture = pcall(function()
        local bytes = api.decode_base64(payload)
        local file_data = api.new_file_data(bytes, "gwang-art." .. extension)
        local image = api.new_image(file_data)
        if image.setFilter then
            image:setFilter("linear", "linear")
        end
        return image
    end)
    if not ok or not texture then
        cache[data_url] = false
        return nil
    end
    cache[data_url] = texture
    return texture
end

--- Draw artwork with a centered cover crop. Returns false for the star fallback.
function M.draw(gwang, rect, api, lookup)
    api = api or runtime_api
    if asset_art.draw(gwang, rect, api) then
        return true
    end
    local texture = M.texture_for(gwang, api, lookup)
    if not texture then
        return false
    end

    local image_w, image_h = texture:getWidth(), texture:getHeight()
    if image_w <= 0 or image_h <= 0 then
        return false
    end
    local scale = math.max(rect.w / image_w, rect.h / image_h)
    local x = rect.x + (rect.w - image_w * scale) / 2
    local y = rect.y + (rect.h - image_h * scale) / 2
    local old_x, old_y, old_w, old_h = api.get_scissor()
    api.set_scissor(rect.x, rect.y, rect.w, rect.h)
    if api.set_color then
        api.set_color(1, 1, 1, 1)
    end
    api.draw(texture, x, y, 0, scale, scale)
    if old_x ~= nil then
        api.set_scissor(old_x, old_y, old_w, old_h)
    else
        api.set_scissor()
    end
    return true
end

return M