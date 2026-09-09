local assets = require("game.asset_loader")
local tag_art = require("game.ui.tag_art")

local M = {}

function M.run()
    assets.clear_cache()

    local coupon_id = tag_art.asset_id({ kind = "tag", identity = "coupon" })
    assert(coupon_id == "tag.coupon", "단골 패찰 must resolve tracked artwork")
    assert(tag_art.asset_id({ kind = "tag", id = "coupon" }) == "tag.coupon",
        "skip offers keyed by id must resolve 단골 패찰")

    local coupon = assets.entry(coupon_id)
    assert(coupon and coupon.status == "runtime", "단골 패찰 artwork must be promoted")
    assert(coupon.master.width == 256 and coupon.master.height == 384,
        "단골 패찰 must preserve a 256x384 master")
    assert(coupon.runtime.width == 32 and coupon.runtime.height == 48,
        "단골 패찰 runtime must fit its skip-tag slot")
    assert(coupon.runtime.filter == "nearest")
    assert(assets.runtime_path(coupon_id) == "assets/runtime/tag/coupon-v1.png")

    local investment_id = tag_art.asset_id({ kind = "tag", identity = "investment" })
    assert(investment_id == "tag.investment", "거상 패찰 must resolve tracked artwork")
    assert(tag_art.asset_id({ kind = "tag", id = "investment" }) == "tag.investment",
        "skip offers keyed by id must resolve 거상 패찰")

    local investment = assets.entry(investment_id)
    assert(investment and investment.status == "runtime", "거상 패찰 artwork must be promoted")
    assert(investment.master.width == 256 and investment.master.height == 384,
        "거상 패찰 must preserve a 256x384 master")
    assert(investment.runtime.width == 32 and investment.runtime.height == 48,
        "거상 패찰 runtime must fit its skip-tag slot")
    assert(investment.runtime.filter == "nearest")
    assert(investment.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(investment_id) == "assets/runtime/tag/investment-v1.png")
    assert(tag_art.asset_id({ kind = "planet", identity = "investment" }) == nil,
        "non-tag shop items must not resolve plaque artwork")

    local handy_id = tag_art.asset_id({ kind = "tag", identity = "handy" })
    assert(handy_id == "tag.handy", "재주꾼 패찰 must resolve tracked artwork")
    assert(tag_art.asset_id({ kind = "tag", id = "handy" }) == "tag.handy",
        "skip offers keyed by id must resolve 재주꾼 패찰")

    local handy = assets.entry(handy_id)
    assert(handy and handy.status == "runtime", "재주꾼 패찰 artwork must be promoted")
    assert(handy.master.width == 256 and handy.master.height == 384,
        "재주꾼 패찰 must preserve a 256x384 master")
    assert(handy.runtime.width == 32 and handy.runtime.height == 48,
        "재주꾼 패찰 runtime must fit its skip-tag slot")
    assert(handy.runtime.filter == "nearest")
    assert(handy.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(handy_id) == "assets/runtime/tag/handy-v1.png")
    assert(tag_art.asset_id({ kind = "planet", identity = "handy" }) == nil,
        "non-tag shop items must not resolve plaque artwork")

    local economy_id = tag_art.asset_id({ kind = "tag", identity = "economy" })
    assert(economy_id == "tag.economy", "알뜰 패찰 must resolve tracked artwork")
    assert(tag_art.asset_id({ kind = "tag", id = "economy" }) == "tag.economy",
        "skip offers keyed by id must resolve 알뜰 패찰")

    local economy = assets.entry(economy_id)
    assert(economy and economy.status == "runtime", "알뜰 패찰 artwork must be promoted")
    assert(economy.master.width == 256 and economy.master.height == 384,
        "알뜰 패찰 must preserve a 256x384 master")
    assert(economy.runtime.width == 32 and economy.runtime.height == 48,
        "알뜰 패찰 runtime must fit its skip-tag slot")
    assert(economy.runtime.filter == "nearest")
    assert(economy.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(economy_id) == "assets/runtime/tag/economy-v1.png")
    assert(tag_art.asset_id({ kind = "planet", identity = "economy" }) == nil,
        "non-tag shop items must not resolve plaque artwork")

    local mega_id = tag_art.asset_id({ kind = "tag", identity = "mega" })
    assert(mega_id == "tag.mega", "대풍년 패찰 must resolve tracked artwork")
    assert(tag_art.asset_id({ kind = "tag", id = "mega" }) == "tag.mega",
        "skip offers keyed by id must resolve 대풍년 패찰")

    local mega = assets.entry(mega_id)
    assert(mega and mega.status == "runtime", "대풍년 패찰 artwork must be promoted")
    assert(mega.master.width == 256 and mega.master.height == 384,
        "대풍년 패찰 must preserve a 256x384 master")
    assert(mega.runtime.width == 32 and mega.runtime.height == 48,
        "대풍년 패찰 runtime must fit its skip-tag slot")
    assert(mega.runtime.filter == "nearest")
    assert(mega.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(mega_id) == "assets/runtime/tag/mega-v1.png")
    assert(tag_art.asset_id({ kind = "planet", identity = "mega" }) == nil,
        "non-tag shop items must not resolve plaque artwork")

    local foil_id = tag_art.asset_id({ kind = "tag", identity = "foil" })
    assert(foil_id == "tag.foil", "은박 패찰 must resolve tracked artwork")
    assert(tag_art.asset_id({ kind = "tag", id = "foil" }) == "tag.foil",
        "skip offers keyed by id must resolve 은박 패찰")

    local foil = assets.entry(foil_id)
    assert(foil and foil.status == "runtime", "은박 패찰 artwork must be promoted")
    assert(foil.master.width == 256 and foil.master.height == 384,
        "은박 패찰 must preserve a 256x384 master")
    assert(foil.runtime.width == 32 and foil.runtime.height == 48,
        "은박 패찰 runtime must fit its skip-tag slot")
    assert(foil.runtime.filter == "nearest")
    assert(foil.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(foil_id) == "assets/runtime/tag/foil-v1.png")
    assert(tag_art.asset_id({ kind = "planet", identity = "foil" }) == nil,
        "non-tag shop items must not resolve plaque artwork")

    assets.clear_cache()
    print("  tag_art: OK")
end

return M
