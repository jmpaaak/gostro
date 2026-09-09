-- Engine-hosted contract for the manifest-backed blue deck thumbnail.

local assets = require("game.asset_loader")
local deck_art = require("game.ui.deck_art")

local M = {}

function M.run()
    assets.clear_cache()
    assert(assets.runtime_path("ui.deck_blue") == "assets/runtime/ui/deck-blue-v1.png",
        "blue deck thumbnail must resolve through the runtime manifest")
    local entry = assets.entry("ui.deck_blue")
    assert(entry and entry.status == "runtime", "blue deck artwork must be promoted")
    assert(entry.master.width == 384 and entry.master.height == 384,
        "blue deck must preserve a 384x384 master")
    assert(entry.runtime.width == 48 and entry.runtime.height == 48,
        "blue deck runtime must fill the 48x48 deck-art slot")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

    local texture = { getDimensions = function() return 48, 48 end }
    local calls = {}
    local requested
    local drawn = deck_art.draw_blue(48, 66, 48, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
        rectangle = function() error("blue deck must not fall back to a rectangle") end,
        circle = function() error("blue deck must not fall back to a circle") end,
    }, function(id)
        requested = id
        return texture
    end)

    assert(drawn == true, "runtime blue deck must draw")
    assert(requested == "ui.deck_blue", "deck slot must request the blue deck thumbnail")
    assert(calls.color[1] == 1 and calls.color[4] == 1)
    assert(calls.draw[1] == texture and calls.draw[2] == 48 and calls.draw[3] == 66,
        "blue deck must draw at the requested position")
    assert(calls.draw[5] == 1 and calls.draw[6] == 1,
        "blue deck must keep integer 1x nearest scale")

    local missing = deck_art.draw_blue(0, 0, 48, {
        set_color = function() end,
        draw = function() error("missing blue deck texture must not draw") end,
        rectangle = function() end,
        circle = function() end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing blue deck texture must report false")

    print("  deck_art: OK")
end

return M
