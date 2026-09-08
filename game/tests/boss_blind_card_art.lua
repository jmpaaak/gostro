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

    local mark_id = blind_card_art.asset_id("boss", { id = "mark" })
    assert(mark_id == "boss-blind.mark", "mark boss must resolve its own card artwork")
    local mark = assets.entry(mark_id)
    assert(mark and mark.status == "runtime", "mark boss artwork must be promoted")
    assert(mark.master.width == 400 and mark.master.height == 560,
        "mark boss must preserve a 400x560 master")
    assert(mark.runtime.width == 50 and mark.runtime.height == 70,
        "mark boss runtime must fit its selection card")
    assert(mark.runtime.filter == "nearest")
    assert(assets.runtime_path(mark_id) == "assets/runtime/boss-blind/mark-v1.png")

    local fish_id = blind_card_art.asset_id("boss", { id = "fish" })
    assert(fish_id == "boss-blind.fish", "fish boss must resolve its own card artwork")
    local fish = assets.entry(fish_id)
    assert(fish and fish.status == "runtime", "fish boss artwork must be promoted")
    assert(fish.master.width == 400 and fish.master.height == 560,
        "fish boss must preserve a 400x560 master")
    assert(fish.runtime.width == 50 and fish.runtime.height == 70,
        "fish boss runtime must fit its selection card")
    assert(fish.runtime.filter == "nearest")
    assert(assets.runtime_path(fish_id) == "assets/runtime/boss-blind/fish-v1.png")

    local psychic_id = blind_card_art.asset_id("boss", { id = "psychic" })
    assert(psychic_id == "boss-blind.psychic", "psychic boss must resolve its own card artwork")
    local psychic = assets.entry(psychic_id)
    assert(psychic and psychic.status == "runtime", "psychic boss artwork must be promoted")
    assert(psychic.master.width == 400 and psychic.master.height == 560,
        "psychic boss must preserve a 400x560 master")
    assert(psychic.runtime.width == 50 and psychic.runtime.height == 70,
        "psychic boss runtime must fit its selection card")
    assert(psychic.runtime.filter == "nearest")
    assert(assets.runtime_path(psychic_id) == "assets/runtime/boss-blind/psychic-v1.png")

    local goad_id = blind_card_art.asset_id("boss", { id = "goad" })
    assert(goad_id == "boss-blind.goad", "goad boss must resolve its own card artwork")
    local goad = assets.entry(goad_id)
    assert(goad and goad.status == "runtime", "goad boss artwork must be promoted")
    assert(goad.master.width == 400 and goad.master.height == 560,
        "goad boss must preserve a 400x560 master")
    assert(goad.runtime.width == 50 and goad.runtime.height == 70,
        "goad boss runtime must fit its selection card")
    assert(goad.runtime.filter == "nearest")
    assert(assets.runtime_path(goad_id) == "assets/runtime/boss-blind/goad-v1.png")

    local plant_id = blind_card_art.asset_id("boss", { id = "plant" })
    assert(plant_id == "boss-blind.plant", "plant boss must resolve its own card artwork")
    local plant = assets.entry(plant_id)
    assert(plant and plant.status == "runtime", "plant boss artwork must be promoted")
    assert(plant.master.width == 400 and plant.master.height == 560,
        "plant boss must preserve a 400x560 master")
    assert(plant.runtime.width == 50 and plant.runtime.height == 70,
        "plant boss runtime must fit its selection card")
    assert(plant.runtime.filter == "nearest")
    assert(assets.runtime_path(plant_id) == "assets/runtime/boss-blind/plant-v1.png")

    assets.clear_cache()
    print("  boss_blind_card_art: OK")
end

return M