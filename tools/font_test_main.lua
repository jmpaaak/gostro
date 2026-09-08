function love.load()
    require("game.tests.fonts").run_actual()
    print("GOSTRO_FONT_OK")
    love.event.quit(0)
end