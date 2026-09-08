local assets = require("game.asset_loader")
local blind_card_art = require("game.ui.blind_card_art")

local M = {}

function M.run()
    assets.clear_cache()
    local id = blind_card_art.asset_id("boss", { id = "hook" })
    assert(id == "boss-blind.hook", "hook boss must resolve its own card artwork")

    local entry = assets.entry(id)
    assert(entry and entry.status == "runtime", "hook boss artwork must be promoted")
    assert(entry.master.width == 400 and entry.master.height == 560,
        "hook boss must preserve a 400x560 master")
    assert(entry.runtime.width == 50 and entry.runtime.height == 70,
        "hook boss runtime must fit its selection card")
    assert(entry.runtime.filter == "nearest")
    assert(assets.runtime_path(id) == "assets/runtime/boss-blind/hook-v1.png")

    assert(blind_card_art.asset_id("boss", { id = "wall" }) == nil,
        "unpromoted bosses must retain the fallback background")
    assets.clear_cache()
    print("  boss_blind_card_art: OK")
end

return M