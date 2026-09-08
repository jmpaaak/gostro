local card_art = require("game.ui.card_art")

local M = {}

function M.run()
    require("game.tests.asset_loader").run()

    assert(card_art.path("pi") == nil, "QA-rejected pi candidate must keep its fallback")
    assert(card_art.path("hongdan") == nil, "unapproved card candidates must keep their fallback")
    assert(card_art.path("cheongdan") == nil, "unconverted cards must keep their fallback")

    assert(card_art.load("pi") == nil)
    assert(card_art.load("hongdan") == nil)
    assert(card_art.load("cheongdan") == nil)
    print("  card_art: OK")
end

return M