local assets = require("game.asset_loader")
local tarot_art = require("game.ui.tarot_art")

local M = {}

function M.run()
    assets.clear_cache()

    local id = tarot_art.asset_id({ kind = "tarot", identity = "the_magician" })
    assert(id == "tarot.the_magician", "둔갑 부적 must resolve tracked artwork")
    assert(tarot_art.asset_id({ kind = "tarot", id = "the_magician" }) == "tarot.the_magician",
        "shop offers keyed by id must resolve 둔갑 부적")

    local entry = assets.entry(id)
    assert(entry and entry.status == "runtime", "둔갑 부적 artwork must be promoted")
    assert(entry.master.width == 400 and entry.master.height == 560,
        "둔갑 부적 must preserve a 400x560 master")
    assert(entry.runtime.width == 36 and entry.runtime.height == 52,
        "둔갑 부적 runtime must fit its shop slot")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(id) == "assets/runtime/tarot/the-magician-v1.png")

    local hanged_id = tarot_art.asset_id({ kind = "tarot", identity = "the_hanged_man" })
    assert(hanged_id == "tarot.the_hanged_man", "소멸 부적 must resolve tracked artwork")
    assert(tarot_art.asset_id({ kind = "tarot", id = "the_hanged_man" }) == "tarot.the_hanged_man",
        "shop offers keyed by id must resolve 소멸 부적")

    local hanged = assets.entry(hanged_id)
    assert(hanged and hanged.status == "runtime", "소멸 부적 artwork must be promoted")
    assert(hanged.master.width == 400 and hanged.master.height == 560,
        "소멸 부적 must preserve a 400x560 master")
    assert(hanged.runtime.width == 36 and hanged.runtime.height == 52,
        "소멸 부적 runtime must fit its shop slot")
    assert(hanged.runtime.filter == "nearest")
    assert(hanged.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(hanged_id) == "assets/runtime/tarot/the-hanged-man-v1.png")
    assert(tarot_art.asset_id({ kind = "planet", identity = "the_magician" }) == nil,
        "non-tarot shop items must not resolve talisman artwork")

    assets.clear_cache()
    print("  tarot_art: OK")
end

return M
