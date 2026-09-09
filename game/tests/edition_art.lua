-- Engine-hosted contract for the manifest-backed foil edition overlay.

local assets = require("game.asset_loader")
local edition_art = require("game.ui.edition_art")

local M = {}

function M.run()
    assets.clear_cache()

    assert(edition_art.asset_id("foil") == "effect.foil",
        "foil overlay must resolve tracked artwork")
    assert(edition_art.asset_id("gold") == nil, "unknown editions must not resolve artwork")
    assert(edition_art.asset_id(nil) == nil)

    local entry = assets.entry("effect.foil")
    assert(entry and entry.status == "runtime", "foil overlay artwork must be promoted")
    assert(entry.master.width == 192 and entry.master.height == 288,
        "foil overlay must preserve a 192x288 master matching play-card cells")
    assert(entry.runtime.width == 24 and entry.runtime.height == 36,
        "foil overlay runtime must cover a 24x36 play card at 1x")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path("effect.foil") == "assets/runtime/effect/foil-v1.png")

    local texture = { getDimensions = function() return 24, 36 end }
    local calls = {}
    local requested
    local drawn = edition_art.draw("foil", 40, 70, 24, 36, 0.2, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
        rectangle = function() error("foil overlay must not fall back to primitive fill") end,
    }, function(id)
        requested = id
        return texture
    end)

    assert(drawn == true, "runtime foil overlay must draw")
    assert(requested == "effect.foil", "foil overlay must request effect.foil")
    assert(calls.color[1] == 1 and calls.color[2] == 1 and calls.color[3] == 1)
    assert(calls.color[4] > 0.4 and calls.color[4] <= 1, "foil overlay alpha must remain visible")
    assert(calls.draw[1] == texture and calls.draw[2] == 40 and calls.draw[3] == 70,
        "foil overlay must draw at the card origin")
    assert((calls.draw[5] == nil or calls.draw[5] == 1)
        and (calls.draw[6] == nil or calls.draw[6] == 1),
        "foil overlay must keep integer 1x nearest scale")

    local missing = edition_art.draw("foil", 0, 0, 24, 36, 0, {
        set_color = function() end,
        draw = function() error("missing foil texture must not draw") end,
        rectangle = function() error("missing foil texture must not fall back to primitives") end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing foil texture must report false")

    print("  edition_art: OK")
end

return M
