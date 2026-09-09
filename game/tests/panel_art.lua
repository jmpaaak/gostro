-- Engine-hosted contract for the manifest-backed wood panel 9-slice.

local assets = require("game.asset_loader")
local panel_art = require("game.ui.panel_art")

local M = {}

function M.run()
    assets.clear_cache()
    assert(assets.runtime_path("ui.panel_wood") == "assets/runtime/ui/panel-wood-v1.png",
        "wood panel must resolve through the runtime manifest")

    local entry = assets.entry("ui.panel_wood")
    assert(entry and entry.status == "runtime", "wood panel artwork must be promoted")
    assert(entry.master.width == 640 and entry.master.height == 368,
        "wood panel must preserve a 640x368 master")
    assert(entry.runtime.width == 80 and entry.runtime.height == 46,
        "wood panel runtime must be a 9-sliceable 80x46 tile")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

    local texture = {
        getWidth = function() return 80 end,
        getHeight = function() return 46 end,
        getDimensions = function() return 80, 46 end,
    }
    local draws = {}
    local graphics = {
        newQuad = function(x, y, w, h, iw, ih)
            return { x = x, y = y, w = w, h = h, iw = iw, ih = ih }
        end,
        setColor = function() end,
        draw = function(...) draws[#draws + 1] = { ... } end,
    }
    local prev_graphics = love and love.graphics
    love = love or {}
    love.graphics = graphics

    local drawn = panel_art.draw("wood", { x = 28, y = 14, w = 264, h = 152 }, {
        texture = function(id)
            assert(id == "ui.panel_wood", "pack overlay must request the wood panel")
            return texture
        end,
        graphics = graphics,
    })

    if prev_graphics then
        love.graphics = prev_graphics
    end

    assert(drawn, "runtime wood panel art must draw")
    assert(#draws == 9, "wood panel must 9-slice into nine patches")
    assert(draws[1][1] == texture and draws[1][3] == 28 and draws[1][4] == 14,
        "wood panel must start at the requested overlay origin")

    assert(assets.runtime_path("ui.panel_metal") == "assets/runtime/ui/panel-metal-v1.png",
        "metal panel must resolve through the runtime manifest")
    local metal = assets.entry("ui.panel_metal")
    assert(metal and metal.status == "runtime", "metal panel artwork must be promoted")
    assert(metal.master.width == 640 and metal.master.height == 368,
        "metal panel must preserve a 640x368 master")
    assert(metal.runtime.width == 80 and metal.runtime.height == 46,
        "metal panel runtime must be a 9-sliceable 80x46 tile")
    assert(metal.runtime.filter == "nearest")
    assert(metal.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

    local metal_draws = {}
    graphics.draw = function(...) metal_draws[#metal_draws + 1] = { ... } end
    local metal_texture = {
        getWidth = function() return 80 end,
        getHeight = function() return 46 end,
        getDimensions = function() return 80, 46 end,
    }
    local drawn_metal = panel_art.draw("metal", { x = 210, y = 24, w = 105, h = 50 }, {
        texture = function(id)
            assert(id == "ui.panel_metal", "scoreboard must request the metal panel")
            return metal_texture
        end,
        graphics = graphics,
    })
    assert(drawn_metal, "runtime metal panel art must draw")
    assert(#metal_draws == 9, "metal panel must 9-slice into nine patches")
    assert(metal_draws[1][1] == metal_texture
        and metal_draws[1][3] == 210 and metal_draws[1][4] == 24,
        "metal panel must start at the requested scoreboard origin")

    assert(panel_art.draw("glass", { x = 0, y = 0, w = 40, h = 40 }) == false,
        "unknown panel kinds must not pretend to draw")

    assets.clear_cache()
    print("  panel_art: OK")
end

return M
