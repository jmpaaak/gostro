local M = {}

function M.minimizeWindow(_width, _height)
    -- Capture canvas size is not the visible window. Keep QA at 1x1 offscreen
    -- so setMode never flashes a 320x180 (or other capture) window.
    if love.window and love.window.setMode then
        love.window.setMode(1, 1, {
            fullscreen = false,
            resizable = false,
            vsync = 0,
            borderless = true,
            centered = false,
            display = 1,
            highdpi = false,
            usedpiscale = false,
            x = -32000,
            y = -32000,
            minwidth = 1,
            minheight = 1,
        })
        if love.window.minimize then
            love.window.minimize()
        end
    end
end

return M
