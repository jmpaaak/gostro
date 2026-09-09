local M = {}

function M.minimizeWindow(width, height)
    if love.window and love.window.setMode then
        love.window.setMode(width or 1, height or 1, {
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
