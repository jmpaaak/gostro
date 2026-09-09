local card_art = require("game.ui.card_art")

local M = {}

function M.run()
    require("game.tests.asset_loader").run()
    require("game.tests.card_candidate_manifest").run()

    local sheet_path = "assets/runtime/cards/play-card-contact-sheet-v1.png"
    assert(card_art.path("pi") == sheet_path, "approved pi candidate must resolve its shared sheet")
    assert(card_art.path("hongdan") == sheet_path, "approved card candidates must resolve their shared sheet")
    assert(card_art.path("cheongdan") == sheet_path, "approved card candidates must resolve their shared sheet")

    print("  card_art: OK")
end

return M
