-- Engine-hosted contract tests for manifest-backed runtime artwork.

local assets = require("game.asset_loader")

local M = {}

function M.run()
    assets.clear_cache()

    local play_card_ids = { "pi", "hongdan", "cheongdan", "chodan", "godori" }
    for _, name in ipairs(play_card_ids) do
        local entry = assets.entry("play-card." .. name)
        if assets.runtime_path("play-card." .. name) == nil then
            error("Failed on: " .. name .. " runtime path is nil. entry.runtime=" .. tostring(entry.runtime))
        end
    end

    assets.clear_cache()
    print("  asset_loader: OK")
end

return M
