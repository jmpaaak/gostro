local assets = require("game.asset_loader")
local art = require("game.ui.gwang_asset_art")

local M = {}

function M.run()
    assets.clear_cache()
    assert(art.asset_id({ identity = "chips" }) == "gwang.chips")
    assert(art.asset_id({}) == nil)

    local entry = assets.entry("gwang.chips")
    assert(entry and entry.status == "runtime", "chip gwang must have tracked runtime artwork")
    assert(entry.master.width == 448 and entry.master.height == 256,
        "chip gwang must preserve its high-resolution slot master")
    assert(entry.runtime.width == 56 and entry.runtime.height == 32,
        "chip gwang runtime must scale exactly into a 28x16 slot")
    assert(entry.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.chips") == "assets/runtime/gwang/chips-v1.png")

    local calls = {}
    local texture = {
        getWidth = function() return 56 end,
        getHeight = function() return 32 end,
    }
    local api = {
        get_scissor = function() return nil end,
        set_scissor = function(...) calls.scissor = { ... } end,
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
    }
    local drawn = art.draw({ identity = "chips" }, { x = 10, y = 4, w = 28, h = 16 }, api,
        function(id)
            assert(id == "gwang.chips")
            return texture
        end)
    assert(drawn and calls.draw[1] == texture)
    assert(calls.draw[2] == 10 and calls.draw[3] == 4)
    assert(calls.draw[5] == 0.5 and calls.draw[6] == 0.5,
        "runtime art must use exact nearest-neighbor half scale")

    assets.clear_cache()
    print("  gwang_asset_art: OK")
end

return M