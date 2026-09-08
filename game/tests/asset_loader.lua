-- Engine-hosted contract tests for manifest-backed runtime artwork.

local assets = require("game.asset_loader")

local M = {}

function M.run()
    assets.clear_cache()

    local pi = assets.entry("play-card.pi")
    assert(pi and pi.category == "play-card", "manifest entries are indexed by id")
    assert(assets.runtime_path("play-card.pi") == nil,
        "QA-rejected pi candidate must not enter the runtime")
    assert(assets.runtime_path("play-card.hongdan") == nil,
        "play-card candidates stay gated until the five-card overlap QA")
    assert(assets.runtime_path("gwang.chips") == nil, "pending art cannot enter the runtime")
    assert(assets.runtime_path("missing.asset") == nil)

    local play_card_ids = { "pi", "hongdan", "cheongdan", "chodan", "godori" }
    for _, name in ipairs(play_card_ids) do
        local entry = assets.entry("play-card." .. name)
        assert(entry and entry.status == "candidate",
            "the complete five-card visual grammar must remain candidate until overlap approval")
        assert(entry.candidateSheet == "play-card.contact-sheet-v1",
            "every play-card candidate must identify its shared high-resolution master sheet")
        assert(assets.runtime_path("play-card." .. name) == nil,
            "no member of an unapproved candidate sheet may enter runtime")
    end

    assets.clear_cache()
    local calls = { images = 0 }
    local image = {
        setFilter = function(_, min, mag)
            calls.filter = { min, mag }
        end,
    }
    local api = {
        read = function()
            return [[{"assets":[{"id":"approved.test","status":"runtime","runtime":{"path":"assets/runtime/test.png","width":8,"height":8,"filter":"nearest"}}]}]]
        end,
        new_image = function(path)
            calls.images = calls.images + 1
            calls.path = path
            return image
        end,
    }

    local loaded = assets.texture("approved.test", api)
    assert(loaded == image and calls.path == "assets/runtime/test.png")
    assert(calls.filter[1] == "nearest" and calls.filter[2] == "nearest",
        "runtime pixel art always uses nearest filtering")
    assert(assets.texture("approved.test", api) == image and calls.images == 1,
        "textures are cached by manifest runtime path")
    assert(assets.texture("missing.asset", api) == nil and calls.images == 1,
        "pending entries do not attempt image loading")

    assets.clear_cache()
    print("  asset_loader: OK")
end

return M
