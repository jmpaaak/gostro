local assets = require("game.asset_loader")

local M = {}

local CARD_NAMES = { "pi", "hongdan", "cheongdan", "chodan", "godori" }

local function assert_region(actual, x, width, height, label)
    assert(actual and #actual == 4, label .. " region is required")
    assert(actual[1] == x and actual[2] == 0 and actual[3] == width and actual[4] == height,
        label .. " region must identify its cell in the shared sheet")
end

function M.run()
    assets.clear_cache()

    for index, name in ipairs(CARD_NAMES) do
        local entry = assert(assets.entry("play-card." .. name))
        assert(entry.status == "runtime" and entry.candidateSheet == "play-card.contact-sheet-v1")

        local cell = assert(entry.candidateCell, name .. " candidate cell metadata is required")
        assert(cell.index == index, name .. " must retain the candidate sheet order")
        assert_region(cell.masterRegion, (index - 1) * 192, 192, 288, name .. " master")
        assert_region(cell.runtimeRegion, (index - 1) * 48, 48, 72, name .. " runtime")
        assert(cell.alphaBounds and cell.alphaBounds[1] == 0 and cell.alphaBounds[2] == 0
            and cell.alphaBounds[3] == 47 and cell.alphaBounds[4] == 71,
            name .. " alpha bounds must cover its 48x72 runtime cell")
    end

    print("  card_candidate_manifest: OK")
end

return M