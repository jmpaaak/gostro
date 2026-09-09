-- Engine-hosted contract for the manifest-backed lock and win effects.

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

    assert(assets.runtime_path("ui.effect_win") == "assets/runtime/ui/effect-win-v1.png",
        "win effect must resolve through the runtime manifest")
    local win_entry = assets.entry("ui.effect_win")
    assert(win_entry and win_entry.status == "runtime", "win effect artwork must be promoted")
    assert(win_entry.master.width == 960 and win_entry.master.height == 540,
        "win effect must preserve a 960x540 master")
    assert(win_entry.runtime.width == 320 and win_entry.runtime.height == 180,
        "win effect runtime must fill the 320x180 canvas")
    assert(win_entry.runtime.filter == "nearest")
    assert(win_entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")

    local win_texture = { getDimensions = function() return 320, 180 end }
    local win_calls = {}
    local win_requested
    local win_drawn = effect_art.draw_win(0, 0, {
        set_color = function(...) win_calls.color = { ... } end,
        draw = function(...) win_calls.draw = { ... } end,
        print = function() error("win overlay must not fall back to text") end,
    }, function(id)
        win_requested = id
        return win_texture
    end)

    assert(win_drawn == true, "runtime win effect must draw")
    assert(win_requested == "ui.effect_win", "won scene must request the win effect")
    assert(win_calls.color[1] == 1 and win_calls.color[4] == 1)
    assert(win_calls.draw[1] == win_texture
        and win_calls.draw[2] == 0
        and win_calls.draw[3] == 0,
        "win effect must draw at the canvas origin")
    assert((win_calls.draw[5] == nil or win_calls.draw[5] == 1)
        and (win_calls.draw[6] == nil or win_calls.draw[6] == 1),
        "win effect must keep integer 1x nearest scale")

    local win_missing = effect_art.draw_win(0, 0, {
        set_color = function() end,
        draw = function() error("missing win texture must not draw") end,
        print = function() end,
    }, function()
        return nil
    end)
    assert(win_missing == false, "missing win texture must report false")

    print("  effect_art: OK")
end

return M
