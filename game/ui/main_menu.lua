-- Pure state, hit testing, and native-pixel rendering for Gostro's main menu.

local M = {}

M.VIEWPORT_W = 320
M.VIEWPORT_H = 180

local LANDING_BUTTONS = {
    { id = "play", label = "게임 시작", x = 88, y = 104, w = 144, h = 42,
      color = { 0.10, 0.43, 0.70 } },
}

local PLAY_MENU_BUTTONS = {
    { id = "new_game", label = "새 게임", x = 92, y = 55, w = 136, h = 30,
      color = { 0.10, 0.43, 0.70 } },
    { id = "continue", label = "계속하기", x = 92, y = 91, w = 136, h = 30,
      color = { 0.70, 0.20, 0.24 } },
    { id = "challenges", label = "도전", x = 92, y = 127, w = 136, h = 30,
      color = { 0.88, 0.48, 0.12 } },
}

function M.new()
    return { mode = "landing", notice = nil }
end

function M.buttons(menu)
    if menu.mode == "play_menu" then return PLAY_MENU_BUTTONS end
    return LANDING_BUTTONS
end

local function contains(button, x, y)
    return x >= button.x and x < button.x + button.w
        and y >= button.y and y < button.y + button.h
end

function M.hit_test(menu, x, y)
    for _, button in ipairs(M.buttons(menu)) do
        if contains(button, x, y) then return button.id end
    end
    return nil
end

function M.activate(menu, x, y)
    local id = M.hit_test(menu, x, y)
    if id == "play" then
        menu.mode = "play_menu"
        menu.notice = nil
        return "open_play_menu"
    elseif id == "new_game" then
        menu.notice = nil
        return "new_game"
    elseif id == "continue" then
        menu.notice = "계속하기 · 준비 중"
        return "continue_unavailable"
    elseif id == "challenges" then
        menu.notice = "도전 · 준비 중"
        return "challenges_unavailable"
    end
    return nil
end

local function draw_background(graphics)
    graphics.clear(0.025, 0.10, 0.12, 1)
    graphics.setColor(0.04, 0.18, 0.18, 1)
    graphics.rectangle("fill", 0, 0, M.VIEWPORT_W, M.VIEWPORT_H)

    -- A simple hwatu-flower seal keeps the screen culturally specific without assets.
    graphics.setColor(0.72, 0.12, 0.16, 0.28)
    graphics.circle("fill", 30, 27, 16)
    graphics.circle("fill", 290, 153, 19)
    graphics.setColor(0.94, 0.72, 0.22, 0.34)
    for i = 0, 4 do
        local angle = i * math.pi * 2 / 5
        graphics.circle("fill", 30 + math.cos(angle) * 8, 27 + math.sin(angle) * 8, 4)
    end
    graphics.circle("fill", 30, 27, 3)
end

local function draw_button(graphics, font, button)
    graphics.setColor(0, 0, 0, 0.45)
    graphics.rectangle("fill", button.x + 3, button.y + 4, button.w, button.h, 5, 5)
    graphics.setColor(button.color[1], button.color[2], button.color[3], 1)
    graphics.rectangle("fill", button.x, button.y, button.w, button.h, 5, 5)
    graphics.setColor(1, 0.90, 0.58, 0.75)
    graphics.rectangle("line", button.x, button.y, button.w, button.h, 5, 5)
    graphics.setColor(1, 1, 1, 1)
    graphics.printf(button.label, button.x, button.y + math.floor((button.h - font:getHeight()) / 2), button.w, "center")
end

function M.draw(menu, graphics)
    graphics = graphics or (love and love.graphics)
    if not graphics then return end

    local fonts = require("game.fonts")
    local old_font = graphics.getFont()
    local body_font = fonts.get(11, graphics)
    local title_font = fonts.get(22, graphics)

    draw_background(graphics)
    graphics.setFont(title_font)
    graphics.setColor(0.97, 0.82, 0.34, 1)
    graphics.printf("고스트로", 0, 15, M.VIEWPORT_W, "center")
    graphics.setFont(body_font)
    graphics.setColor(0.78, 0.88, 0.82, 1)
    graphics.printf("화투 로그라이크", 0, 39, M.VIEWPORT_W, "center")

    for _, button in ipairs(M.buttons(menu)) do
        draw_button(graphics, body_font, button)
    end

    if menu.notice then
        graphics.setColor(1, 0.84, 0.48, 1)
        graphics.printf(menu.notice, 0, 164, M.VIEWPORT_W, "center")
    end

    graphics.setFont(old_font)
    graphics.setColor(1, 1, 1, 1)
end

return M
