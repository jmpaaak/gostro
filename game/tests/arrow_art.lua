-- Engine-hosted contract for manifest-backed New Run carousel arrows.

local assets = require("game.asset_loader")
local arrow_art = require("game.ui.arrow_art")

local M = {}

local function assert_draw(kind, id, path, x, y)
    local texture = { getDimensions = function() return 26, 18 end }
    local calls = {}
    local requested
    local drawn = arrow_art["draw_" .. kind](x, y, 26, 18, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
        rectangle = function() error(kind .. " arrow must not fall back to a rectangle") end,
        polygon = function() error(kind .. " arrow must not fall back to a polygon") end,
    }, function(requested_id)
        requested = requested_id
        return texture
    end)

    assert(drawn == true, "runtime " .. kind .. " arrow must draw")
    assert(requested == id, "arrow slot must request the " .. kind .. " arrow")
    assert(calls.color[1] == 1 and calls.color[4] == 1)
    assert(calls.draw[1] == texture and calls.draw[2] == x and calls.draw[3] == y,
        kind .. " arrow must draw at the requested position")
    assert((calls.draw[5] == nil or calls.draw[5] == 1)
        and (calls.draw[6] == nil or calls.draw[6] == 1),
        kind .. " arrow must keep integer 1x nearest scale")

    local missing = arrow_art["draw_" .. kind](0, 0, 26, 18, {
        set_color = function() end,
        draw = function() error("missing " .. kind .. " arrow texture must not draw") end,
        rectangle = function() end,
        polygon = function() end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing " .. kind .. " arrow texture must report false")
    assert(assets.runtime_path(id) == path,
        kind .. " arrow must resolve through the runtime manifest")
end

function M.run()
    assets.clear_cache()
    local left = assets.entry("ui.arrow_left")
    assert(left and left.status == "runtime", "left arrow artwork must be promoted")
    assert(left.master.width == 624 and left.master.height == 432,
        "left arrow must preserve a 624x432 master")
    assert(left.runtime.width == 26 and left.runtime.height == 18,
        "left arrow runtime must fill the 26x18 New Run arrow slot")
    assert(left.runtime.filter == "nearest")
    assert(left.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("left", "ui.arrow_left", "assets/runtime/ui/arrow-left-v1.png", 5, 67)

    print("  arrow_art: OK")
end

return M
