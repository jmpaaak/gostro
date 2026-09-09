-- Engine-hosted contract: automated QA must keep a 1x1 offscreen window.
-- Canvas captures stay at 320x180; the visible Love window must not grow.

local offscreen = require("game.qa.offscreen_window")

local M = {}

function M.run()
    local calls = {
        setMode = {},
        minimized = false,
        position = nil,
    }
    local fake_love = {
        window = {
            setMode = function(width, height, flags)
                calls.setMode[#calls.setMode + 1] = {
                    width = width,
                    height = height,
                    flags = flags,
                }
            end,
            minimize = function()
                calls.minimized = true
            end,
            setPosition = function(x, y)
                calls.position = { x = x, y = y }
            end,
        },
    }
    local previous = love
    love = fake_love
    local ok, err = pcall(function()
        offscreen.minimizeWindow(320, 180)
    end)
    love = previous
    assert(ok, err)

    assert(#calls.setMode == 1, "QA window mode is set once")
    local mode = calls.setMode[1]
    assert(mode.width == 1 and mode.height == 1,
        "QA window must stay 1x1 instead of flashing a 320x180 capture size")
    assert(mode.flags.borderless == true, "QA window is borderless")
    assert(mode.flags.centered == false, "QA window is not recentered on screen")
    assert(mode.flags.x == -32000 and mode.flags.y == -32000,
        "QA window stays offscreen")
    assert(calls.minimized == true, "QA window is minimized after mode set")
    print("  offscreen_window: OK")
end

return M
