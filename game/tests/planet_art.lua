local assets = require("game.asset_loader")
local planet_art = require("game.ui.planet_art")

local M = {}

function M.run()
    assets.clear_cache()

    local id = planet_art.asset_id({ kind = "planet", identity = "planet_hongdan" })
    assert(id == "planet.planet_hongdan", "주작 기원패 must resolve tracked artwork")
    assert(planet_art.asset_id({ kind = "planet", identity = "hongdan" }) == "planet.planet_hongdan",
        "shop offers keyed by yaku must resolve 주작 기원패")

    local entry = assets.entry(id)
    assert(entry and entry.status == "runtime", "주작 기원패 artwork must be promoted")
    assert(entry.master.width == 400 and entry.master.height == 560,
        "주작 기원패 must preserve a 400x560 master")
    assert(entry.runtime.width == 36 and entry.runtime.height == 52,
        "주작 기원패 runtime must fit its shop slot")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(id) == "assets/runtime/planet/hongdan-v1.png")
    assert(planet_art.asset_id({ kind = "tarot", identity = "planet_hongdan" }) == nil,
        "non-planet shop items must not resolve wish-card artwork")
    assert(planet_art.asset_id({ kind = "planet", identity = "planet_cheongdan" }) == nil,
        "other wish cards stay pending until their own slice")

    assets.clear_cache()
    print("  planet_art: OK")
end

return M
