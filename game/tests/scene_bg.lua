-- Engine-hosted contract for manifest-backed scene background art.

local assets = require("game.asset_loader")
local scene_bg = require("game.ui.scene_bg")

local M = {}

local function graphics_stub()
    local texture = {
        getWidth = function() return 320 end,
        getHeight = function() return 180 end,
    }
    local draws = {}
    local cleared = {}
    local graphics = {
        setColor = function() end,
        clear = function(...) cleared[#cleared + 1] = { ... } end,
        draw = function(...) draws[#draws + 1] = { ... } end,
        rectangle = function() error("scene background must not fall back to primitives") end,
    }
    return texture, draws, cleared, graphics
end

function M.run()
    assets.clear_cache()
    assert(assets.runtime_path("ui.play_bg") == "assets/runtime/ui/play-bg-v1.png",
        "play background must resolve through the runtime manifest")

    local play_entry = assets.entry("ui.play_bg")
    assert(play_entry and play_entry.status == "runtime", "play background artwork must be promoted")
    assert(play_entry.master.width == 960 and play_entry.master.height == 540,
        "play background must preserve a 960x540 master")
    assert(play_entry.runtime.width == 320 and play_entry.runtime.height == 180,
        "play background runtime must fill the 320x180 canvas")
    assert(play_entry.runtime.filter == "nearest")
    assert(play_entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

    local play_texture, play_draws, play_cleared, play_graphics = graphics_stub()
    local play_drawn = scene_bg.draw("play", {
        texture = function(id)
            assert(id == "ui.play_bg", "play scene must request ui.play_bg")
            return play_texture
        end,
        graphics = play_graphics,
    })

    assert(play_drawn, "runtime play background art must draw")
    assert(#play_cleared == 1, "play background must clear under transparent Pixel Perfect edges")
    assert(#play_draws == 1, "play background must draw a single full-canvas texture")
    assert(play_draws[1][1] == play_texture and play_draws[1][2] == 0 and play_draws[1][3] == 0,
        "play background must start at the canvas origin")

    assert(assets.runtime_path("ui.shop_bg") == "assets/runtime/ui/shop-bg-v1.png",
        "shop background must resolve through the runtime manifest")

    local shop_entry = assets.entry("ui.shop_bg")
    assert(shop_entry and shop_entry.status == "runtime", "shop background artwork must be promoted")
    assert(shop_entry.master.width == 960 and shop_entry.master.height == 540,
        "shop background must preserve a 960x540 master")
    assert(shop_entry.runtime.width == 320 and shop_entry.runtime.height == 180,
        "shop background runtime must fill the 320x180 canvas")
    assert(shop_entry.runtime.filter == "nearest")
    assert(shop_entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

    local shop_texture, shop_draws, shop_cleared, shop_graphics = graphics_stub()
    local shop_drawn = scene_bg.draw("shop", {
        texture = function(id)
            assert(id == "ui.shop_bg", "shop scene must request ui.shop_bg")
            return shop_texture
        end,
        graphics = shop_graphics,
    })

    assert(shop_drawn, "runtime shop background art must draw")
    assert(#shop_cleared == 1, "shop background must clear under transparent Pixel Perfect edges")
    assert(#shop_draws == 1, "shop background must draw a single full-canvas texture")
    assert(shop_draws[1][1] == shop_texture and shop_draws[1][2] == 0 and shop_draws[1][3] == 0,
        "shop background must start at the canvas origin")

    print("  scene_bg: OK")
end

return M
