-- Engine-hosted contract for the manifest-backed score-chip HUD icon.

local assets = require("game.asset_loader")
local art = require("game.ui.score_icon_art")

local M = {}

function M.run()
    assets.clear_cache()
    assert(assets.runtime_path("ui.icon_chip") == "assets/runtime/ui/icon-chip-v1.png",
        "score-chip icon must resolve through the runtime manifest")

    local texture = { getDimensions = function() return 12, 12 end }
    local call
    local drawn = art.draw_chip(7, 9, 12, {
        set_color = function() end,
        draw = function(...) call = { ... } end,
    }, function(id)
        assert(id == "ui.icon_chip", "score HUD must request the chip icon")
        return texture
    end)

    assert(drawn, "runtime score-chip art must draw")
    assert(call and call[1] == texture and call[2] == 7 and call[3] == 9,
        "score-chip art must draw at the requested HUD position")

    assert(assets.runtime_path("ui.icon_mult") == "assets/runtime/ui/icon-mult-v1.png",
        "mult icon must resolve through the runtime manifest")

    local call_mult
    local drawn_mult = art.draw_mult(20, 9, 12, {
        set_color = function() end,
        draw = function(...) call_mult = { ... } end,
    }, function(id)
        assert(id == "ui.icon_mult", "score HUD must request the mult icon")
        return texture
    end)

    assert(drawn_mult, "runtime mult art must draw")
    assert(call_mult and call_mult[1] == texture and call_mult[2] == 20 and call_mult[3] == 9,
        "mult art must draw at the requested HUD position")

    print("  score_icon_art: OK")
end

return M