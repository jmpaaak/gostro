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

    local cheongdan_id = planet_art.asset_id({ kind = "planet", identity = "planet_cheongdan" })
    assert(cheongdan_id == "planet.planet_cheongdan", "청룡 기원패 must resolve tracked artwork")
    assert(planet_art.asset_id({ kind = "planet", identity = "cheongdan" }) == "planet.planet_cheongdan",
        "shop offers keyed by yaku must resolve 청룡 기원패")

    local cheongdan = assets.entry(cheongdan_id)
    assert(cheongdan and cheongdan.status == "runtime", "청룡 기원패 artwork must be promoted")
    assert(cheongdan.master.width == 400 and cheongdan.master.height == 560,
        "청룡 기원패 must preserve a 400x560 master")
    assert(cheongdan.runtime.width == 36 and cheongdan.runtime.height == 52,
        "청룡 기원패 runtime must fit its shop slot")
    assert(cheongdan.runtime.filter == "nearest")
    assert(cheongdan.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(cheongdan_id) == "assets/runtime/planet/cheongdan-v1.png")

    local chodan_id = planet_art.asset_id({ kind = "planet", identity = "planet_chodan" })
    assert(chodan_id == "planet.planet_chodan", "백호 기원패 must resolve tracked artwork")
    assert(planet_art.asset_id({ kind = "planet", identity = "chodan" }) == "planet.planet_chodan",
        "shop offers keyed by yaku must resolve 백호 기원패")

    local chodan = assets.entry(chodan_id)
    assert(chodan and chodan.status == "runtime", "백호 기원패 artwork must be promoted")
    assert(chodan.master.width == 400 and chodan.master.height == 560,
        "백호 기원패 must preserve a 400x560 master")
    assert(chodan.runtime.width == 36 and chodan.runtime.height == 52,
        "백호 기원패 runtime must fit its shop slot")
    assert(chodan.runtime.filter == "nearest")
    assert(chodan.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(chodan_id) == "assets/runtime/planet/chodan-v1.png")

    local godori_id = planet_art.asset_id({ kind = "planet", identity = "planet_godori" })
    assert(godori_id == "planet.planet_godori", "현무 기원패 must resolve tracked artwork")
    assert(planet_art.asset_id({ kind = "planet", identity = "godori" }) == "planet.planet_godori",
        "shop offers keyed by yaku must resolve 현무 기원패")

    local godori = assets.entry(godori_id)
    assert(godori and godori.status == "runtime", "현무 기원패 artwork must be promoted")
    assert(godori.master.width == 400 and godori.master.height == 560,
        "현무 기원패 must preserve a 400x560 master")
    assert(godori.runtime.width == 36 and godori.runtime.height == 52,
        "현무 기원패 runtime must fit its shop slot")
    assert(godori.runtime.filter == "nearest")
    assert(godori.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(godori_id) == "assets/runtime/planet/godori-v1.png")

    local pi_id = planet_art.asset_id({ kind = "planet", identity = "planet_pi" })
    assert(pi_id == "planet.planet_pi", "황룡 기원패 must resolve tracked artwork")
    assert(planet_art.asset_id({ kind = "planet", identity = "pi" }) == "planet.planet_pi",
        "shop offers keyed by yaku must resolve 황룡 기원패")

    local pi = assets.entry(pi_id)
    assert(pi and pi.status == "runtime", "황룡 기원패 artwork must be promoted")
    assert(pi.master.width == 400 and pi.master.height == 560,
        "황룡 기원패 must preserve a 400x560 master")
    assert(pi.runtime.width == 36 and pi.runtime.height == 52,
        "황룡 기원패 runtime must fit its shop slot")
    assert(pi.runtime.filter == "nearest")
    assert(pi.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(pi_id) == "assets/runtime/planet/pi-v1.png")

    assets.clear_cache()
    print("  planet_art: OK")
end

return M
