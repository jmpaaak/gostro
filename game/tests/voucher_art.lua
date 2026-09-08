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

    local reroll_id = voucher_art.asset_id({ kind = "voucher", identity = "reroll_surplus" })
    assert(reroll_id == "voucher.reroll_surplus", "bargain seal must resolve tracked artwork")
    local reroll = assets.entry(reroll_id)
    assert(reroll and reroll.status == "runtime", "bargain seal artwork must be promoted")
    assert(reroll.master.width == 400 and reroll.master.height == 560,
        "bargain seal must preserve a 400x560 master")
    assert(reroll.runtime.width == 36 and reroll.runtime.height == 52,
        "bargain seal runtime must fit its shop slot")
    assert(reroll.runtime.filter == "nearest")
    assert(assets.runtime_path(reroll_id) == "assets/runtime/voucher/reroll-surplus-v1.png")

    local clearance_id = voucher_art.asset_id({ kind = "voucher", identity = "clearance_sale" })
    assert(clearance_id == "voucher.clearance_sale", "clearance sale seal must resolve tracked artwork")
    local clearance = assets.entry(clearance_id)
    assert(clearance and clearance.status == "runtime", "clearance sale seal artwork must be promoted")
    assert(clearance.master.width == 400 and clearance.master.height == 560,
        "clearance sale seal must preserve a 400x560 master")
    assert(clearance.runtime.width == 36 and clearance.runtime.height == 52,
        "clearance sale seal runtime must fit its shop slot")
    assert(clearance.runtime.filter == "nearest")
    assert(assets.runtime_path(clearance_id) == "assets/runtime/voucher/clearance-sale-v1.png")

    local seed_money_id = voucher_art.asset_id({ kind = "voucher", identity = "seed_money" })
    assert(seed_money_id == "voucher.seed_money", "seed money seal must resolve tracked artwork")
    local seed_money = assets.entry(seed_money_id)
    assert(seed_money and seed_money.status == "runtime", "seed money seal artwork must be promoted")
    assert(seed_money.master.width == 400 and seed_money.master.height == 560,
        "seed money seal must preserve a 400x560 master")
    assert(seed_money.runtime.width == 36 and seed_money.runtime.height == 52,
        "seed money seal runtime must fit its shop slot")
    assert(seed_money.runtime.filter == "nearest")
    assert(assets.runtime_path(seed_money_id) == "assets/runtime/voucher/seed-money-v1.png")

    local antimatter_id = voucher_art.asset_id({ kind = "voucher", identity = "antimatter" })
    assert(antimatter_id == "voucher.antimatter", "empty-space seal must resolve tracked artwork")
    local antimatter = assets.entry(antimatter_id)
    assert(antimatter and antimatter.status == "runtime", "empty-space seal artwork must be promoted")
    assert(antimatter.master.width == 400 and antimatter.master.height == 560,
        "empty-space seal must preserve a 400x560 master")
    assert(antimatter.runtime.width == 36 and antimatter.runtime.height == 52,
        "empty-space seal runtime must fit its shop slot")
    assert(antimatter.runtime.filter == "nearest")
    assert(assets.runtime_path(antimatter_id) == "assets/runtime/voucher/antimatter-v1.png")

    local crystal_ball_id = voucher_art.asset_id({ kind = "voucher", identity = "crystal_ball" })
    assert(crystal_ball_id == "voucher.crystal_ball", "clairvoyance seal must resolve tracked artwork")
    local crystal_ball = assets.entry(crystal_ball_id)
    assert(crystal_ball and crystal_ball.status == "runtime", "clairvoyance seal artwork must be promoted")
    assert(crystal_ball.master.width == 400 and crystal_ball.master.height == 560,
        "clairvoyance seal must preserve a 400x560 master")
    assert(crystal_ball.runtime.width == 36 and crystal_ball.runtime.height == 52,
        "clairvoyance seal runtime must fit its shop slot")
    assert(crystal_ball.runtime.filter == "nearest")
    assert(assets.runtime_path(crystal_ball_id) == "assets/runtime/voucher/crystal-ball-v1.png")

    local hone_id = voucher_art.asset_id({ kind = "voucher", identity = "hone" })
    assert(hone_id == "voucher.hone", "forging seal must resolve tracked artwork")
    local hone = assets.entry(hone_id)
    assert(hone and hone.status == "runtime", "forging seal artwork must be promoted")
    assert(hone.master.width == 400 and hone.master.height == 560,
        "forging seal must preserve a 400x560 master")
    assert(hone.runtime.width == 36 and hone.runtime.height == 52,
        "forging seal runtime must fit its shop slot")
    assert(hone.runtime.filter == "nearest")
    assert(assets.runtime_path(hone_id) == "assets/runtime/voucher/hone-v1.png")

    local directors_cut_id = voucher_art.asset_id({ kind = "voucher", identity = "directors_cut" })
    assert(directors_cut_id == "voucher.directors_cut", "boss reroll seal must resolve tracked artwork")
    local directors_cut = assets.entry(directors_cut_id)
    assert(directors_cut and directors_cut.status == "runtime", "boss reroll seal artwork must be promoted")
    assert(directors_cut.master.width == 400 and directors_cut.master.height == 560,
        "boss reroll seal must preserve a 400x560 master")
    assert(directors_cut.runtime.width == 36 and directors_cut.runtime.height == 52,
        "boss reroll seal runtime must fit its shop slot")
    assert(directors_cut.runtime.filter == "nearest")
    assert(assets.runtime_path(directors_cut_id) == "assets/runtime/voucher/directors-cut-v1.png")

    local money_tree_id = voucher_art.asset_id({ kind = "voucher", identity = "money_tree" })
    assert(money_tree_id == "voucher.money_tree", "money tree seal must resolve tracked artwork")
    local money_tree = assets.entry(money_tree_id)
    assert(money_tree and money_tree.status == "runtime", "money tree seal artwork must be promoted")
    assert(money_tree.master.width == 400 and money_tree.master.height == 560,
        "money tree seal must preserve a 400x560 master")
    assert(money_tree.runtime.width == 36 and money_tree.runtime.height == 52,
        "money tree seal runtime must fit its shop slot")
    assert(money_tree.runtime.filter == "nearest")
    assert(assets.runtime_path(money_tree_id) == "assets/runtime/voucher/money-tree-v1.png")

    assets.clear_cache()
    print("  voucher_art: OK")
end

return M