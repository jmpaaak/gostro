-- Engine-hosted contract tests for manifest-backed runtime artwork.

local assets = require("game.asset_loader")

local M = {}

function M.run()
    assets.clear_cache()

    local play_card_ids = { "pi", "hongdan", "cheongdan", "chodan", "godori" }
    for _, name in ipairs(play_card_ids) do
        assert(assets.runtime_path("play-card." .. name)
                == "assets/runtime/cards/play-card-contact-sheet-v1.png",
            name .. " must resolve through the approved shared sheet")
    end

    assets.clear_cache()
    print("  asset_loader: OK")
end

return M
