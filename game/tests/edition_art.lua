-- Engine-hosted contract for manifest-backed play-card edition overlays.

local assets = require("game.asset_loader")
local edition_art = require("game.ui.edition_art")

local M = {}

local function assert_overlay(name, asset_id, path)
    assert(edition_art.asset_id(name) == asset_id,
        name .. " overlay must resolve tracked artwork")
    local entry = assets.entry(asset_id)
    assert(entry and entry.status == "runtime", name .. " overlay artwork must be promoted")
    assert(entry.master.width == 192 and entry.master.height == 288,
        name .. " overlay must preserve a 192x288 master matching play-card cells")
    assert(entry.runtime.width == 24 and entry.runtime.height == 36,
        name .. " overlay runtime must cover a 24x36 play card at 1x")
    assert(entry.runtime.filter == "nearest")
    assert(entry.conversion.endpoint == "http://127.0.0.1:4176/api/pixel-perfect")
    assert(assets.runtime_path(asset_id) == path)

    local texture = { getDimensions = function() return 24, 36 end }
    local calls, requested = {}
    local drawn = edition_art.draw(name, 40, 70, 24, 36, 0.2, {
        set_color = function(...) calls.color = { ... } end,
        draw = function(...) calls.draw = { ... } end,
        rectangle = function() error(name .. " overlay must not fall back to primitive fill") end,
    }, function(id)
        requested = id
        return texture
    end)
    assert(drawn == true, "runtime " .. name .. " overlay must draw")
    assert(requested == asset_id, name .. " overlay must request " .. asset_id)
    assert(calls.color[1] == 1 and calls.color[2] == 1 and calls.color[3] == 1)
    assert(calls.color[4] > 0.3 and calls.color[4] <= 1, name .. " overlay alpha must remain visible")
    assert(calls.draw[1] == texture and calls.draw[2] == 40 and calls.draw[3] == 70,
        name .. " overlay must draw at the card origin")
    assert((calls.draw[5] == nil or calls.draw[5] == 1)
        and (calls.draw[6] == nil or calls.draw[6] == 1),
        name .. " overlay must keep integer 1x nearest scale")

    local missing = edition_art.draw(name, 0, 0, 24, 36, 0, {
        set_color = function() end,
        draw = function() error("missing " .. name .. " texture must not draw") end,
        rectangle = function() error("missing " .. name .. " texture must not fall back to primitives") end,
    }, function()
        return nil
    end)
    assert(missing == false, "missing " .. name .. " texture must report false")
end

function M.run()
    assets.clear_cache()
    assert(edition_art.asset_id("gold") == nil, "unknown editions must not resolve artwork")
    assert(edition_art.asset_id(nil) == nil)
    assert_overlay("foil", "effect.foil", "assets/runtime/effect/foil-v1.png")
    assert_overlay("hologram", "effect.hologram", "assets/runtime/effect/hologram-v1.png")
    assert_overlay("polychrome", "effect.polychrome", "assets/runtime/effect/polychrome-v1.png")
    print("  edition_art: OK")
end

return M
