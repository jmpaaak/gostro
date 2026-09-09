function love.conf(t)
    t.identity = "gostro-qa"
    t.version = "11.5"
    t.window.title = "Gostro QA"
    t.window.width = 1
    t.window.height = 1
    t.window.borderless = true
    t.window.resizable = false
    t.window.vsync = 0
    t.window.msaa = 0
    t.window.highdpi = false
    t.window.x = -32000
    t.window.y = -32000
    t.modules.audio = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.video = false
end
