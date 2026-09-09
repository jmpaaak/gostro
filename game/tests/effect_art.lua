-- Engine-hosted contract for the manifest-backed lock effect.

local assets = require("game.asset_loader")
local effect_art = require("game.ui.effect_art")

local M = {}

function M.run()
    assets.clear_cache()
    assert(assets.runtime_path("ui.effect_lock") == "assets/runtime/ui/effect-lock-v1.png",
        "lock effect must resolve through the runtime manifest")

    local texture = { getDimensions = function() return 16, 20 end }
    local calls = {}
    local requested
    local drawn = effect_art.draw_lock(110, 65, 16, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
    }, function(id)
        requested = id
        return texture
    end)

    assert(drawn == true, "runtime lock effect must draw")
    assert(requested == "ui.effect_lock", "lock HUD must request the lock effect")
    assert(calls.color[1] == 1 and calls.color[4] == 1)
    assert(calls.draw[1] == texture and calls.draw[2] == 110 and calls.draw[3] == 65,
        "lock effect must draw at the requested position")
    assert(calls.draw[5] == 1 and calls.draw[6] == 1,
        "lock effect must keep integer 1x nearest scale")

    local missing = effect_art.draw_lock(0, 0, 16, {
        set_color = function() end,
        draw = function() error("missing lock texture must not draw") end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing lock texture must report false")

    print("  effect_art: OK")
end

return M
