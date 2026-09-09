function love.conf(t)
    local headless = os.getenv("GAME_HEADLESS") == "1"
    -- GOSTRO_LOOP covers absolute-path `love` spawned by the autonomous cycle.
    local qa = os.getenv("GAME_QA") == "1" or os.getenv("GOSTRO_LOOP") == "1"
    local scale = math.max(1, math.min(4, math.floor(tonumber(os.getenv("GAME_SCALE")) or 3)))

    t.identity = "gostro"
    t.version = "11.5"
    if headless or qa then
        -- Loop/QA must not create a macOS window at all. 1x1 offscreen still
        -- flashes a Dock icon. Isolated font/capture packages use tools/qa_conf.lua
        -- (1x1 offscreen with graphics) because they need an OpenGL context.
        t.window = false
        t.modules.audio = false
        t.modules.window = false
        t.modules.graphics = false
        return
    end
    t.window.title = "Gostro"
    t.window.msaa = 0
    t.window.width = 320 * scale
    t.window.height = 180 * scale
    t.window.resizable = true
    t.window.highdpi = true
    t.window.vsync = 1
end
