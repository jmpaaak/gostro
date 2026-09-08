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

    local godori = assets.entry("gwang.godori_x2")
    assert(godori and godori.status == "runtime",
        "godori flag gwang must have tracked runtime artwork")
    assert(godori.master.width == 448 and godori.master.height == 256,
        "godori flag gwang must preserve its high-resolution slot master")
    assert(godori.runtime.width == 56 and godori.runtime.height == 32,
        "godori flag runtime must scale exactly into a 28x16 slot")
    assert(godori.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.godori_x2") ==
        "assets/runtime/gwang/godori-x2-v1.png")

    local pi_chips = assets.entry("gwang.pi_chips_kind")
    assert(pi_chips and pi_chips.status == "runtime",
        "pi chips gwang must have tracked runtime artwork")
    assert(pi_chips.master.width == 448 and pi_chips.master.height == 256,
        "pi chips gwang must preserve its high-resolution slot master")
    assert(pi_chips.runtime.width == 56 and pi_chips.runtime.height == 32,
        "pi chips gwang runtime must scale exactly into a 28x16 slot")
    assert(pi_chips.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.pi_chips_kind") ==
        "assets/runtime/gwang/pi-chips-kind-v1.png")

    local godori_chips = assets.entry("gwang.godori_chips")
    assert(godori_chips and godori_chips.status == "runtime",
        "godori chips gwang must have tracked runtime artwork")
    assert(godori_chips.master.width == 448 and godori_chips.master.height == 256,
        "godori chips gwang must preserve its high-resolution slot master")
    assert(godori_chips.runtime.width == 56 and godori_chips.runtime.height == 32,
        "godori chips gwang runtime must scale exactly into a 28x16 slot")
    assert(godori_chips.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.godori_chips") ==
        "assets/runtime/gwang/godori-chips-v1.png")

    local hongdan_chips = assets.entry("gwang.hongdan_chips")
    assert(hongdan_chips and hongdan_chips.status == "runtime",
        "hongdan chips gwang must have tracked runtime artwork")
    assert(hongdan_chips.master.width == 448 and hongdan_chips.master.height == 256,
        "hongdan chips gwang must preserve its high-resolution slot master")
    assert(hongdan_chips.runtime.width == 56 and hongdan_chips.runtime.height == 32,
        "hongdan chips gwang runtime must scale exactly into a 28x16 slot")
    assert(hongdan_chips.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.hongdan_chips") ==
        "assets/runtime/gwang/hongdan-chips-v1.png")

    local cheongdan_chips = assets.entry("gwang.cheongdan_chips")
    assert(cheongdan_chips and cheongdan_chips.status == "runtime",
        "cheongdan chips gwang must have tracked runtime artwork")
    assert(cheongdan_chips.master.width == 448 and cheongdan_chips.master.height == 256,
        "cheongdan chips gwang must preserve its high-resolution slot master")
    assert(cheongdan_chips.runtime.width == 56 and cheongdan_chips.runtime.height == 32,
        "cheongdan chips gwang runtime must scale exactly into a 28x16 slot")
    assert(cheongdan_chips.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.cheongdan_chips") ==
        "assets/runtime/gwang/cheongdan-chips-v1.png")

    local chodan_chips = assets.entry("gwang.chodan_chips")
    assert(chodan_chips and chodan_chips.status == "runtime",
        "chodan chips gwang must have tracked runtime artwork")
    assert(chodan_chips.master.width == 448 and chodan_chips.master.height == 256,
        "chodan chips gwang must preserve its high-resolution slot master")
    assert(chodan_chips.runtime.width == 56 and chodan_chips.runtime.height == 32,
        "chodan chips gwang runtime must scale exactly into a 28x16 slot")
    assert(chodan_chips.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.chodan_chips") ==
        "assets/runtime/gwang/chodan-chips-v1.png")

    local pi_yaku = assets.entry("gwang.pi_yaku_mult")
    assert(pi_yaku and pi_yaku.status == "runtime",
        "pi yaku gwang must have tracked runtime artwork")
    assert(pi_yaku.master.width == 448 and pi_yaku.master.height == 256,
        "pi yaku gwang must preserve its high-resolution slot master")
    assert(pi_yaku.runtime.width == 56 and pi_yaku.runtime.height == 32,
        "pi yaku gwang runtime must scale exactly into a 28x16 slot")
    assert(pi_yaku.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.pi_yaku_mult") ==
        "assets/runtime/gwang/pi-yaku-mult-v1.png")

    local thin_deck = assets.entry("gwang.thin_deck_x3")
    assert(thin_deck and thin_deck.status == "runtime",
        "thin deck gwang must have tracked runtime artwork")
    assert(thin_deck.master.width == 448 and thin_deck.master.height == 256,
        "thin deck gwang must preserve its high-resolution slot master")
    assert(thin_deck.runtime.width == 56 and thin_deck.runtime.height == 32,
        "thin deck gwang runtime must scale exactly into a 28x16 slot")
    assert(thin_deck.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.thin_deck_x3") ==
        "assets/runtime/gwang/thin-deck-x3-v1.png")

    local tiny_deck = assets.entry("gwang.tiny_deck_chips")
    assert(tiny_deck and tiny_deck.status == "runtime",
        "tiny deck gwang must have tracked runtime artwork")
    assert(tiny_deck.master.width == 448 and tiny_deck.master.height == 256,
        "tiny deck gwang must preserve its high-resolution slot master")
    assert(tiny_deck.runtime.width == 56 and tiny_deck.runtime.height == 32,
        "tiny deck gwang runtime must scale exactly into a 28x16 slot")
    assert(tiny_deck.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.tiny_deck_chips") ==
        "assets/runtime/gwang/tiny-deck-chips-v1.png")

    local lean_deck = assets.entry("gwang.lean_deck_mult")
    assert(lean_deck and lean_deck.status == "runtime",
        "lean deck gwang must have tracked runtime artwork")
    assert(lean_deck.master.width == 448 and lean_deck.master.height == 256,
        "lean deck gwang must preserve its high-resolution slot master")
    assert(lean_deck.runtime.width == 56 and lean_deck.runtime.height == 32,
        "lean deck gwang runtime must scale exactly into a 28x16 slot")
    assert(lean_deck.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.lean_deck_mult") ==
        "assets/runtime/gwang/lean-deck-mult-v1.png")

    local rich = assets.entry("gwang.rich_mult")
    assert(rich and rich.status == "runtime",
        "rich gwang must have tracked runtime artwork")
    assert(rich.master.width == 448 and rich.master.height == 256,
        "rich gwang must preserve its high-resolution slot master")
    assert(rich.runtime.width == 56 and rich.runtime.height == 32,
        "rich gwang runtime must scale exactly into a 28x16 slot")
    assert(rich.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.rich_mult") ==
        "assets/runtime/gwang/rich-mult-v1.png")

    local loaded = assets.entry("gwang.loaded_chips")
    assert(loaded and loaded.status == "runtime",
        "loaded gwang must have tracked runtime artwork")
    assert(loaded.master.width == 448 and loaded.master.height == 256,
        "loaded gwang must preserve its high-resolution slot master")
    assert(loaded.runtime.width == 56 and loaded.runtime.height == 32,
        "loaded gwang runtime must scale exactly into a 28x16 slot")
    assert(loaded.runtime.filter == "nearest")
    assert(assets.runtime_path("gwang.loaded_chips") ==
        "assets/runtime/gwang/loaded-chips-v1.png")

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