local assets = require("game.asset_loader")
local pack_art = require("game.ui.pack_art")

local M = {}

function M.run()
    assets.clear_cache()

    local id = pack_art.asset_id({ kind = "pack", identity = "arcana_pack" })
    assert(id == "pack.arcana_pack", "talisman bundle must resolve its tracked artwork")

    local entry = assets.entry(id)
    assert(entry and entry.status == "runtime", "talisman bundle artwork must be promoted")
    assert(entry.master.width == 400 and entry.master.height == 560,
        "talisman bundle must preserve a 400x560 master")
    assert(entry.runtime.width == 36 and entry.runtime.height == 52,
        "talisman bundle runtime must fit its shop slot")
    assert(entry.runtime.filter == "nearest")
    assert(assets.runtime_path(id) == "assets/runtime/pack/talisman-bundle-v1.png")
    assert(pack_art.asset_id({ kind = "voucher", identity = "arcana_pack" }) == nil,
        "non-pack shop items must not resolve pack artwork")

    assets.clear_cache()
    print("  pack_art: OK")
end

return M