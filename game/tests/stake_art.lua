-- Engine-hosted contract for manifest-backed New Run stake chips.

local assets = require("game.asset_loader")
local stake_art = require("game.ui.stake_art")

local M = {}

local function assert_draw(kind, id, path, x, y)
    local texture = { getDimensions = function() return 16, 16 end }
    local calls = {}
    local requested
    local drawn = stake_art["draw_" .. kind](x, y, 16, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
        rectangle = function() error(kind .. " stake must not fall back to a rectangle") end,
        circle = function() error(kind .. " stake must not fall back to a circle") end,
    }, function(requested_id)
        requested = requested_id
        return texture
    end)

    assert(drawn == true, "runtime " .. kind .. " stake must draw")
    assert(requested == id, "stake slot must request the " .. kind .. " stake chip")
    assert(calls.color[1] == 1 and calls.color[4] == 1)
    assert(calls.draw[1] == texture and calls.draw[2] == x and calls.draw[3] == y,
        kind .. " stake must draw at the requested position")
    assert(calls.draw[5] == 1 and calls.draw[6] == 1,
        kind .. " stake must keep integer 1x nearest scale")

    local missing = stake_art["draw_" .. kind](0, 0, 16, {
        set_color = function() end,
        draw = function() error("missing " .. kind .. " stake texture must not draw") end,
        rectangle = function() end,
        circle = function() end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing " .. kind .. " stake texture must report false")
    assert(assets.runtime_path(id) == path,
        kind .. " stake chip must resolve through the runtime manifest")
end

function M.run()
    assets.clear_cache()
    local white = assets.entry("ui.stake_white")
    assert(white and white.status == "runtime", "white stake artwork must be promoted")
    assert(white.master.width == 384 and white.master.height == 384,
        "white stake must preserve a 384x384 master")
    assert(white.runtime.width == 16 and white.runtime.height == 16,
        "white stake runtime must fill the 16x16 stake-chip slot")
    assert(white.runtime.filter == "nearest")
    assert(white.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("white", "ui.stake_white", "assets/runtime/ui/stake-white-v1.png", 44, 123)

    local red = assets.entry("ui.stake_red")
    assert(red and red.status == "runtime", "red stake artwork must be promoted")
    assert(red.master.width == 384 and red.master.height == 384,
        "red stake must preserve a 384x384 master")
    assert(red.runtime.width == 16 and red.runtime.height == 16,
        "red stake runtime must fill the 16x16 stake-chip slot")
    assert(red.runtime.filter == "nearest")
    assert(red.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("red", "ui.stake_red", "assets/runtime/ui/stake-red-v1.png", 44, 123)

    local green = assets.entry("ui.stake_green")
    assert(green and green.status == "runtime", "green stake artwork must be promoted")
    assert(green.master.width == 384 and green.master.height == 384,
        "green stake must preserve a 384x384 master")
    assert(green.runtime.width == 16 and green.runtime.height == 16,
        "green stake runtime must fill the 16x16 stake-chip slot")
    assert(green.runtime.filter == "nearest")
    assert(green.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert_draw("green", "ui.stake_green", "assets/runtime/ui/stake-green-v1.png", 44, 123)

    print("  stake_art: OK")
end

return M
