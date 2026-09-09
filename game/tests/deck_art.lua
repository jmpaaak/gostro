-- Engine-hosted contract for manifest-backed New Run deck thumbnails.

local assets = require("game.asset_loader")
local deck_art = require("game.ui.deck_art")

local M = {}

local function assert_draw(kind, id, path, x, y)
    local texture = { getDimensions = function() return 48, 48 end }
    local calls = {}
    local requested
    local drawn = deck_art["draw_" .. kind](x, y, 48, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
        rectangle = function() error(kind .. " deck must not fall back to a rectangle") end,
        circle = function() error(kind .. " deck must not fall back to a circle") end,
    }, function(requested_id)
        requested = requested_id
        return texture
    end)

    assert(drawn == true, "runtime " .. kind .. " deck must draw")
    assert(requested == id, "deck slot must request the " .. kind .. " deck thumbnail")
    assert(calls.color[1] == 1 and calls.color[4] == 1)
    assert(calls.draw[1] == texture and calls.draw[2] == x and calls.draw[3] == y,
        kind .. " deck must draw at the requested position")
    assert(calls.draw[5] == 1 and calls.draw[6] == 1,
        kind .. " deck must keep integer 1x nearest scale")

    local missing = deck_art["draw_" .. kind](0, 0, 48, {
        set_color = function() end,
        draw = function() error("missing " .. kind .. " deck texture must not draw") end,
        rectangle = function() end,
        circle = function() end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing " .. kind .. " deck texture must report false")
    assert(assets.runtime_path(id) == path,
        kind .. " deck thumbnail must resolve through the runtime manifest")
end

function M.run()
    assets.clear_cache()
    local blue = assets.entry("ui.deck_blue")
    assert(blue and blue.status == "runtime", "blue deck artwork must be promoted")
    assert(blue.master.width == 384 and blue.master.height == 384,
        "blue deck must preserve a 384x384 master")
    assert(blue.runtime.width == 48 and blue.runtime.height == 48,
        "blue deck runtime must fill the 48x48 deck-art slot")
    assert(blue.runtime.filter == "nearest")
    assert(blue.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("blue", "ui.deck_blue", "assets/runtime/ui/deck-blue-v1.png", 48, 66)

    local red = assets.entry("ui.deck_red")
    assert(red and red.status == "runtime", "red deck artwork must be promoted")
    assert(red.master.width == 384 and red.master.height == 384,
        "red deck must preserve a 384x384 master")
    assert(red.runtime.width == 48 and red.runtime.height == 48,
        "red deck runtime must fill the 48x48 deck-art slot")
    assert(red.runtime.filter == "nearest")
    assert(red.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("red", "ui.deck_red", "assets/runtime/ui/deck-red-v1.png", 48, 66)

    local yellow = assets.entry("ui.deck_yellow")
    assert(yellow and yellow.status == "runtime", "yellow deck artwork must be promoted")
    assert(yellow.master.width == 384 and yellow.master.height == 384,
        "yellow deck must preserve a 384x384 master")
    assert(yellow.runtime.width == 48 and yellow.runtime.height == 48,
        "yellow deck runtime must fill the 48x48 deck-art slot")
    assert(yellow.runtime.filter == "nearest")
    assert(yellow.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("yellow", "ui.deck_yellow", "assets/runtime/ui/deck-yellow-v1.png", 48, 66)

    print("  deck_art: OK")
end

return M
