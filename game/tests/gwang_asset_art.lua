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

    local mult_add = assets.entry("gwang.always_mult_small")
    assert(mult_add and mult_add.status == "runtime",
        "small additive mult gwang must have tracked runtime artwork")
    assert(mult_add.master.width == 448 and mult_add.master.height == 256,
        "small additive mult gwang must preserve its high-resolution slot master")
    assert(mult_add.runtime.width == 56 and mult_add.runtime.height == 32,
        "small additive mult runtime must scale exactly into a 28x16 slot")
    assert(mult_add.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.always_mult_small") ==
        "assets/runtime/gwang/always-mult-small-v1.png")

    local chips_add = assets.entry("gwang.always_chips_small")
    assert(chips_add and chips_add.status == "runtime",
        "small additive chips gwang must have tracked runtime artwork")
    assert(chips_add.master.width == 448 and chips_add.master.height == 256,
        "small additive chips gwang must preserve its high-resolution slot master")
    assert(chips_add.runtime.width == 56 and chips_add.runtime.height == 32,
        "small additive chips runtime must scale exactly into a 28x16 slot")
    assert(chips_add.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.always_chips_small") ==
        "assets/runtime/gwang/always-chips-small-v1.png")

    local chips_mid = assets.entry("gwang.always_chips_mid")
    assert(chips_mid and chips_mid.status == "runtime",
        "mid additive chips gwang must have tracked runtime artwork")
    assert(chips_mid.master.width == 448 and chips_mid.master.height == 256,
        "mid additive chips gwang must preserve its high-resolution slot master")
    assert(chips_mid.runtime.width == 56 and chips_mid.runtime.height == 32,
        "mid additive chips runtime must scale exactly into a 28x16 slot")
    assert(chips_mid.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.always_chips_mid") ==
        "assets/runtime/gwang/always-chips-mid-v1.png")

    local mult_mid = assets.entry("gwang.always_mult_mid")
    assert(mult_mid and mult_mid.status == "runtime",
        "mid additive mult gwang must have tracked runtime artwork")
    assert(mult_mid.master.width == 448 and mult_mid.master.height == 256,
        "mid additive mult gwang must preserve its high-resolution slot master")
    assert(mult_mid.runtime.width == 56 and mult_mid.runtime.height == 32,
        "mid additive mult runtime must scale exactly into a 28x16 slot")
    assert(mult_mid.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.always_mult_mid") ==
        "assets/runtime/gwang/always-mult-mid-v1.png")

    local hongdan = assets.entry("gwang.hongdan_x2")
    assert(hongdan and hongdan.status == "runtime",
        "hongdan flag gwang must have tracked runtime artwork")
    assert(hongdan.master.width == 448 and hongdan.master.height == 256,
        "hongdan flag gwang must preserve its high-resolution slot master")
    assert(hongdan.runtime.width == 56 and hongdan.runtime.height == 32,
        "hongdan flag runtime must scale exactly into a 28x16 slot")
    assert(hongdan.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.hongdan_x2") ==
        "assets/runtime/gwang/hongdan-x2-v1.png")

    local cheongdan = assets.entry("gwang.cheongdan_x2")
    assert(cheongdan and cheongdan.status == "runtime",
        "cheongdan flag gwang must have tracked runtime artwork")
    assert(cheongdan.master.width == 448 and cheongdan.master.height == 256,
        "cheongdan flag gwang must preserve its high-resolution slot master")
    assert(cheongdan.runtime.width == 56 and cheongdan.runtime.height == 32,
        "cheongdan flag runtime must scale exactly into a 28x16 slot")
    assert(cheongdan.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.cheongdan_x2") ==
        "assets/runtime/gwang/cheongdan-x2-v1.png")

    local chodan = assets.entry("gwang.chodan_x2")
    assert(chodan and chodan.status == "runtime",
        "chodan flag gwang must have tracked runtime artwork")
    assert(chodan.master.width == 448 and chodan.master.height == 256,
        "chodan flag gwang must preserve its high-resolution slot master")
    assert(chodan.runtime.width == 56 and chodan.runtime.height == 32,
        "chodan flag runtime must scale exactly into a 28x16 slot")
    assert(chodan.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.chodan_x2") ==
        "assets/runtime/gwang/chodan-x2-v1.png")

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