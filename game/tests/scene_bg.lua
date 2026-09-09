-- Engine-hosted contract for manifest-backed play-scene background art.

local assets = require("game.asset_loader")
local scene_bg = require("game.ui.scene_bg")

local M = {}

function M.run()
    assets.clear_cache()
    assert(assets.runtime_path("ui.play_bg") == "assets/runtime/ui/play-bg-v1.png",
        "play background must resolve through the runtime manifest")

    local entry = assets.entry("ui.play_bg")
    assert(entry and entry.status == "runtime", "play background artwork must be promoted")
    assert(entry.master.width == 960 and entry.master.height == 540,
        "play background must preserve a 960x540 master")
    assert(entry.runtime.width == 320 and entry.runtime.height == 180,
        "play background runtime must fill the 320x180 canvas")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

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
        rectangle = function() error("play background must not fall back to primitives") end,
    }

    local drawn = scene_bg.draw("play", {
        texture = function(id)
            assert(id == "ui.play_bg", "play scene must request ui.play_bg")
            return texture
        end,
        graphics = graphics,
    })

    assert(drawn, "runtime play background art must draw")
    assert(#cleared == 1, "play background must clear under transparent Pixel Perfect edges")
    assert(#draws == 1, "play background must draw a single full-canvas texture")
    assert(draws[1][1] == texture and draws[1][2] == 0 and draws[1][3] == 0,
        "play background must start at the canvas origin")

    print("  scene_bg: OK")
end

return M
