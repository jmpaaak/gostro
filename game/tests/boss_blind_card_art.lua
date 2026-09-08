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

    local wall_id = blind_card_art.asset_id("boss", { id = "wall" })
    assert(wall_id == "boss-blind.wall", "wall boss must resolve its own card artwork")
    local wall = assets.entry(wall_id)
    assert(wall and wall.status == "runtime", "wall boss artwork must be promoted")
    assert(wall.master.width == 400 and wall.master.height == 560,
        "wall boss must preserve a 400x560 master")
    assert(wall.runtime.width == 50 and wall.runtime.height == 70,
        "wall boss runtime must fit its selection card")
    assert(wall.runtime.filter == "nearest")
    assert(assets.runtime_path(wall_id) == "assets/runtime/boss-blind/wall-v1.png")

    local flint_id = blind_card_art.asset_id("boss", { id = "flint" })
    assert(flint_id == "boss-blind.flint", "flint boss must resolve its own card artwork")
    local flint = assets.entry(flint_id)
    assert(flint and flint.status == "runtime", "flint boss artwork must be promoted")
    assert(flint.master.width == 400 and flint.master.height == 560,
        "flint boss must preserve a 400x560 master")
    assert(flint.runtime.width == 50 and flint.runtime.height == 70,
        "flint boss runtime must fit its selection card")
    assert(flint.runtime.filter == "nearest")
    assert(assets.runtime_path(flint_id) == "assets/runtime/boss-blind/flint-v1.png")
    assets.clear_cache()
    print("  boss_blind_card_art: OK")
end

return M