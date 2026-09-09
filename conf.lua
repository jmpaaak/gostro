function love.conf(t)
    local headless = os.getenv("GAME_HEADLESS") == "1"
    -- GOSTRO_LOOP covers absolute-path `love` spawned by the autonomous cycle.
    local qa = os.getenv("GAME_QA") == "1" or os.getenv("GOSTRO_LOOP") == "1"
    local scale = math.max(1, math.min(4, math.floor(tonumber(os.getenv("GAME_SCALE")) or 3)))

    t.identity = "gostro"
    t.version = "11.5"
    if headless or qa then
        -- Loop/QA must not create a macOS window at all. 1x1 offscreen still
        -- flashes a Dock icon. Canvas captures that need graphics should run
        -- as a user-invoked Makefile target, not from the autonomous loop.
        t.window = false
        t.modules.audio = false
        t.modules.window = false
        t.modules.graphics = false
        return
    end
    t.window.title = qa and "Gostro QA" or "Gostro"
    t.window.msaa = 0
    if qa then
        t.window.width = 1
        t.window.height = 1
        t.window.borderless = true
        t.window.resizable = false
        t.window.highdpi = false
        t.window.vsync = 0
        t.window.x = -32000
        t.window.y = -32000
        t.modules.audio = false
        return
    end
    t.window.width = 320 * scale
    t.window.height = 180 * scale
    t.window.resizable = true
    t.window.highdpi = true
    t.window.vsync = 1
end
