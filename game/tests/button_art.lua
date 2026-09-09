local assets = require("game.asset_loader")
local button_art = require("game.ui.button_art")

local M = {}

function M.run()
    local ok = button_art.draw("primary", {x = 0, y = 0, w = 60, h = 20})
    if not ok then
        assert(type(ok) == "boolean", "draw should return a boolean")
    end
end

return M
