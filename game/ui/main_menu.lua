-- Pure state, hit testing, and native-pixel rendering for Gostro's main menu.

local M = {}

M.VIEWPORT_W = 320
M.VIEWPORT_H = 180

local LANDING_BUTTON = {
    id = "play", label = "게임 시작", x = 88, y = 102, w = 144, h = 44,
    color = { 0.10, 0.43, 0.70 },
}

local TAB_RECTS = {
    { id = "new_game", label = "새 게임", x = 20, y = 28, w = 92, h = 28 },
    { id = "continue", label = "계속하기", x = 114, y = 28, w = 92, h = 28 },
    { id = "challenges", label = "도전", x = 208, y = 28, w = 92, h = 28 },
}

local BACK_BUTTON = {
    id = "back", label = "뒤로", x = 20, y = 160, w = 280, h = 17,
    color = { 0.22, 0.28, 0.29 },
}

local TAB_CONTENT = {
    continue = {
        status = "empty",
        title = "계속하기 준비 중",
        detail = "저장된 판이 없습니다",
        can_play = false,
    },
    challenges = {
        status = "unavailable",
        title = "도전 과제를 확인합니다",
        detail = "",
        can_play = false,
    },
}

local TAB_ACTIONS = {
    new_game = "select_new_game",
    continue = "select_continue",
    challenges = "select_challenges",
}

local function copy_rect(rect)
    local copy = {}
    for key, value in pairs(rect) do copy[key] = value end
    return copy
end

function M.new()
    return { mode = "landing", selected_tab = "new_game" }
end

function M.tabs(menu)
    local tabs = {}
    for i, rect in ipairs(TAB_RECTS) do
        tabs[i] = copy_rect(rect)
        tabs[i].selected = menu.selected_tab == rect.id
    end
    return tabs
end

function M.back_button()
    return copy_rect(BACK_BUTTON)
end

function M.selected_indicator(menu)
    for _, tab in ipairs(TAB_RECTS) do
        if tab.id == menu.selected_tab then
            return {
                tab_id = tab.id,
                x = tab.x + 18,
                y = tab.y - 5,
                w = tab.w - 36,
                h = 3,
            }
        end
    end
    return nil
end

function M.tab_content(menu)
    local content = TAB_CONTENT[menu.selected_tab]
    if not content then return nil end
    return {
        status = content.status,
        title = content.title,
        detail = content.detail,
        can_play = content.can_play,
    }
end

function M.buttons(menu)
    if menu.mode ~= "play_menu" then return { copy_rect(LANDING_BUTTON) } end

    local buttons = M.tabs(menu)
    buttons[#buttons + 1] = M.back_button(menu)
    return buttons
end

local function contains(rect, x, y)
    return x >= rect.x and x < rect.x + rect.w
        and y >= rect.y and y < rect.y + rect.h
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
        menu.selected_tab = "new_game"
        return "open_play_menu"
    elseif id == "back" then
        menu.mode = "landing"
        menu.selected_tab = "new_game"
        return "back_to_landing"
    elseif TAB_ACTIONS[id] then
        menu.selected_tab = id
        return TAB_ACTIONS[id]
    end
    return nil
end

local function draw_background(graphics)
    graphics.clear(0.025, 0.10, 0.12, 1)
    graphics.setColor(0.04, 0.18, 0.18, 1)
    graphics.rectangle("fill", 0, 0, M.VIEWPORT_W, M.VIEWPORT_H)

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
    graphics.printf(button.label, button.x,
        button.y + math.floor((button.h - font:getHeight()) / 2), button.w, "center")
end

local function draw_play_panel(menu, graphics, font)
    graphics.setColor(0.025, 0.075, 0.085, 0.94)
    graphics.rectangle("fill", 14, 24, 292, 154, 5, 5)
    graphics.setColor(0.76, 0.59, 0.20, 0.7)
    graphics.rectangle("line", 14, 24, 292, 154, 5, 5)

    for _, tab in ipairs(M.tabs(menu)) do
        if tab.selected then
            graphics.setColor(0.13, 0.39, 0.43, 1)
        else
            graphics.setColor(0.08, 0.17, 0.18, 1)
        end
        graphics.rectangle("fill", tab.x, tab.y, tab.w, tab.h, 3, 3)
        graphics.setColor(tab.selected and 1 or 0.68, tab.selected and 0.86 or 0.72,
            tab.selected and 0.42 or 0.70, 1)
        graphics.printf(tab.label, tab.x,
            tab.y + math.floor((tab.h - font:getHeight()) / 2), tab.w, "center")
    end

    local indicator = M.selected_indicator(menu)
    graphics.setColor(0.98, 0.72, 0.20, 1)
    graphics.rectangle("fill", indicator.x, indicator.y, indicator.w, indicator.h)

    local content = M.tab_content(menu)
    if content then
        graphics.setColor(0.72, 0.82, 0.78, 1)
        graphics.printf(content.title, 20, 82, 280, "center")
        graphics.setColor(0.52, 0.64, 0.61, 1)
        graphics.printf(content.detail, 20, 103, 280, "center")
    end
    draw_button(graphics, font, BACK_BUTTON)
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
    if menu.mode == "play_menu" then
        draw_play_panel(menu, graphics, body_font)
    else
        graphics.setColor(0.78, 0.88, 0.82, 1)
        graphics.printf("화투 로그라이크", 0, 39, M.VIEWPORT_W, "center")
        draw_button(graphics, body_font, LANDING_BUTTON)
    end

    graphics.setFont(old_font)
    graphics.setColor(1, 1, 1, 1)
end

return M
