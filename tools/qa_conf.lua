function love.conf(t)
    t.identity = "gostro-qa"
    t.version = "11.5"
    -- Isolated packages (font-test, build/test, *-qa) do not load the game
    -- conf.lua. Without this file Love opens the default 800x600 window.
    -- Keep a 1x1 hidden window so canvas/font QA still has OpenGL, but do
    -- not advertise a "Gostro QA" title in Dock / Mission Control.
    t.window.title = ""
    t.window.width = 1
    t.window.height = 1
    t.window.borderless = true
    t.window.resizable = false
    t.window.vsync = 0
    t.window.msaa = 0
    t.window.highdpi = false
    t.window.x = -32000
    t.window.y = -32000
    t.window.centered = false
    t.window.hidden = true
    t.modules.audio = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.video = false
end
