local assets = require("game.asset_loader")
local blind_card_art = require("game.ui.blind_card_art")

local M = {}

function M.run()
    assets.clear_cache()
    assert(blind_card_art.asset_id("small") == "ui.blind_small")
    assert(blind_card_art.asset_id("big") == "ui.blind_big")
    assert(blind_card_art.asset_id("boss", nil) == nil,
        "boss artwork belongs to the separate boss-blind category")

    for _, kind in ipairs({ "small", "big" }) do
        local id = blind_card_art.asset_id(kind)
        local entry = assets.entry(id)
        assert(entry and entry.status == "runtime", id .. " must be promoted")
        assert(entry.master.width == 400 and entry.master.height == 560,
            id .. " must preserve a 400x560 master")
        assert(entry.runtime.width == 50 and entry.runtime.height == 70,
            id .. " must fit the blind selection card exactly")
        assert(entry.runtime.filter == "nearest")
        assert(assets.runtime_path(id) ~= nil, id .. " must resolve through the loader")
    end

    assets.clear_cache()
    print("  blind_card_art: OK")
end

return M