-- Manifest-backed pixel artwork for equipped gwang slots.

local assets = require("game.asset_loader")

local M = {}

local runtime_api = {
    get_scissor = function() return love.graphics.getScissor() end,
    set_scissor = function(...) return love.graphics.setScissor(...) end,
    set_color = function(...) return love.graphics.setColor(...) end,
    draw = function(...) return love.graphics.draw(...) end,
}

function M.asset_id(gwang)
    if type(gwang) ~= "table" or type(gwang.identity) ~= "string"
        or gwang.identity == "" then
        return nil
    end
    return "gwang." .. gwang.identity
end

function M.draw(gwang, rect, api, texture_loader)
    local id = M.asset_id(gwang)
    if not id then return false end
    local texture = (texture_loader or assets.texture)(id)
    if not texture then return false end

    api = api or runtime_api
    local image_w, image_h = texture:getWidth(), texture:getHeight()
    if image_w <= 0 or image_h <= 0 then return false end
    local scale = math.max(rect.w / image_w, rect.h / image_h)
    local x = rect.x + (rect.w - image_w * scale) / 2
    local y = rect.y + (rect.h - image_h * scale) / 2
    local old_x, old_y, old_w, old_h = api.get_scissor()
    api.set_scissor(rect.x, rect.y, rect.w, rect.h)
    api.set_color(1, 1, 1, 1)
    api.draw(texture, x, y, 0, scale, scale)
    if old_x ~= nil then
        api.set_scissor(old_x, old_y, old_w, old_h)
    else
        api.set_scissor()
    end
    return true
end

return M