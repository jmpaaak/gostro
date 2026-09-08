local card_art = require("game.ui.card_art")

local M = {}

function M.run()
    require("game.tests.asset_loader").run()
    require("game.tests.card_candidate_manifest").run()

    assert(card_art.path("pi") == "assets/runtime/cards/pi.png", "approved pi candidate must return its path")
    assert(card_art.path("hongdan") == "assets/runtime/cards/hongdan.png", "approved card candidates must return their path")
    assert(card_art.path("cheongdan") == "assets/runtime/cards/cheongdan.png", "approved card candidates must return their path")

    print("  card_art: OK")
end

return M
