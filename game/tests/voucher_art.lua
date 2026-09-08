local assets = require("game.asset_loader")
local voucher_art = require("game.ui.voucher_art")

local M = {}

function M.run()
    assets.clear_cache()

    local id = voucher_art.asset_id({ kind = "voucher", identity = "paint_brush" })
    assert(id == "voucher.paint_brush", "calligraphy seal must resolve tracked artwork")

    local entry = assets.entry(id)
    assert(entry and entry.status == "runtime", "calligraphy seal artwork must be promoted")
    assert(entry.master.width == 400 and entry.master.height == 560,
        "calligraphy seal must preserve a 400x560 master")
    assert(entry.runtime.width == 36 and entry.runtime.height == 52,
        "calligraphy seal runtime must fit its shop slot")
    assert(entry.runtime.filter == "nearest")
    assert(assets.runtime_path(id) == "assets/runtime/voucher/paint-brush-v1.png")
    assert(voucher_art.asset_id({ kind = "pack", identity = "paint_brush" }) == nil,
        "non-voucher shop items must not resolve seal artwork")

    local wasteful_id = voucher_art.asset_id({ kind = "voucher", identity = "wasteful" })
    assert(wasteful_id == "voucher.wasteful", "generous seal must resolve tracked artwork")
    local wasteful = assets.entry(wasteful_id)
    assert(wasteful and wasteful.status == "runtime", "generous seal artwork must be promoted")
    assert(wasteful.master.width == 400 and wasteful.master.height == 560,
        "generous seal must preserve a 400x560 master")
    assert(wasteful.runtime.width == 36 and wasteful.runtime.height == 52,
        "generous seal runtime must fit its shop slot")
    assert(wasteful.runtime.filter == "nearest")
    assert(assets.runtime_path(wasteful_id) == "assets/runtime/voucher/wasteful-v1.png")

    local grabber_id = voucher_art.asset_id({ kind = "voucher", identity = "grabber" })
    assert(grabber_id == "voucher.grabber", "rake seal must resolve tracked artwork")
    local grabber = assets.entry(grabber_id)
    assert(grabber and grabber.status == "runtime", "rake seal artwork must be promoted")
    assert(grabber.master.width == 400 and grabber.master.height == 560,
        "rake seal must preserve a 400x560 master")
    assert(grabber.runtime.width == 36 and grabber.runtime.height == 52,
        "rake seal runtime must fit its shop slot")
    assert(grabber.runtime.filter == "nearest")
    assert(assets.runtime_path(grabber_id) == "assets/runtime/voucher/grabber-v1.png")

    local overstock_id = voucher_art.asset_id({ kind = "voucher", identity = "overstock" })
    assert(overstock_id == "voucher.overstock", "general store seal must resolve tracked artwork")
    local overstock = assets.entry(overstock_id)
    assert(overstock and overstock.status == "runtime", "general store seal artwork must be promoted")
    assert(overstock.master.width == 400 and overstock.master.height == 560,
        "general store seal must preserve a 400x560 master")
    assert(overstock.runtime.width == 36 and overstock.runtime.height == 52,
        "general store seal runtime must fit its shop slot")
    assert(overstock.runtime.filter == "nearest")
    assert(assets.runtime_path(overstock_id) == "assets/runtime/voucher/overstock-v1.png")

    assets.clear_cache()
    print("  voucher_art: OK")
end

return M