-- Standalone 320x180 New Run setup state, hit testing, and rendering.

local seed_ui = require("game.ui.seed")
local effect_art = require("game.ui.effect_art")
local deck_art = require("game.ui.deck_art")
local stake_art = require("game.ui.stake_art")
local arrow_art = require("game.ui.arrow_art")

local M = {}

M.VIEWPORT_W = 320
M.VIEWPORT_H = 180

local DECKS = {
    {
        id = "hwatu",
        name = "화투패",
        description = "기본 패 구성",
        detail = "단·고도리·피를 고르게 담은 시작 패",
        unlocked = true,
        colors = { { 0.76, 0.13, 0.17 }, { 0.96, 0.74, 0.22 } },
    },
    {
        id = "thin",
        name = "얇은 패",
        description = "피 비중이 적은 구성",
        detail = "단과 고도리를 노리기 좋은 가벼운 패",
        unlocked = true,
        colors = { { 0.09, 0.42, 0.43 }, { 0.82, 0.90, 0.66 } },
    },
    {
        id = "gwang_jackpot",
        name = "광대박패",
        description = "잠긴 패 구성",
        unlocked = false,
        unlock_condition = "한 판에서 광 3장을 모으면 해금",
        colors = { { 0.18, 0.16, 0.25 }, { 0.82, 0.58, 0.18 } },
    },
}

-- Kept as a list so additional stake tiers can be added without changing controls.
local STAKES = {
    { id = "white", label = "흰 인장", name = "기본 난이도", unlocked = true },
    {
        id = "red",
        label = "붉은 인장",
        name = "높은 난이도",
        unlocked = false,
        unlock_condition = "8고를 클리어하면 해금",
    },
    {
        id = "green",
        label = "푸른 인장",
        name = "최고 난이도",
        unlocked = false,
        unlock_condition = "붉은 인장으로 8고를 클리어하면 해금",
    },
}

local LAYOUT = {
    panel = { x = 35, y = 60, w = 250, h = 59 },
    deck_art = { x = 48, y = 66, w = 48, h = 48 },
    deck_info = { x = 104, y = 62, w = 168, h = 54 },
    deck_left = { x = 5, y = 67, w = 30, h = 42 },
    deck_right = { x = 285, y = 67, w = 30, h = 42 },
    dots = { x = 137, y = 116, w = 46, h = 5 },
    stake_left = { x = 10, y = 122, w = 26, h = 18 },
    stake = { x = 40, y = 122, w = 240, h = 18 },
    stake_right = { x = 284, y = 122, w = 26, h = 18 },
    seeded = { x = 39, y = 143, w = 112, h = 14 },
    play = { x = 181, y = 142, w = 100, h = 16 },
}

local function copy_entries(source)
    local result = {}
    for i, entry in ipairs(source) do
        local copy = {}
        for key, value in pairs(entry) do copy[key] = value end
        result[i] = copy
    end
    return result
end

local function contains(rect, x, y)
    return type(x) == "number" and type(y) == "number"
        and x >= rect.x and x < rect.x + rect.w
        and y >= rect.y and y < rect.y + rect.h
end

local function cycle(index, amount, count)
    return ((index - 1 + amount) % count) + 1
end

function M.layout()
    return LAYOUT
end

function M.new(seed_string)
    local seed_state = seed_ui.new(seed_string)
    return {
        decks = copy_entries(DECKS),
        stakes = copy_entries(STAKES),
        deck_index = 1,
        stake_index = 1,
        seeded = false,
        seed = seed_state.seed,
        seed_state = seed_state,
        notice = nil,
    }
end

function M.selected_deck(state)
    return state.decks[state.deck_index]
end

function M.selected_stake(state)
    return state.stakes[state.stake_index]
end

function M.can_play(state)
    local deck = M.selected_deck(state)
    local stake = M.selected_stake(state)
    return deck ~= nil and deck.unlocked == true
        and stake ~= nil and stake.unlocked ~= false
end

function M.set_seed(state, seed_string)
    local normalized = seed_ui.set_seed(state.seed_state, seed_string)
    state.seed = normalized
    return normalized
end

function M.hit_test(_, x, y)
    local order = { "deck_left", "deck_right", "stake_left", "stake_right", "seeded", "play" }
    for _, id in ipairs(order) do
        if contains(LAYOUT[id], x, y) then return id end
    end
    return nil
end

local function select_deck(state, amount)
    state.deck_index = cycle(state.deck_index, amount, #state.decks)
    local deck = M.selected_deck(state)
    state.notice = deck.unlocked and nil or deck.unlock_condition
    return "deck_changed"
end

local function select_stake(state, amount)
    state.stake_index = cycle(state.stake_index, amount, #state.stakes)
    local stake = M.selected_stake(state)
    if stake.unlocked == false then
        state.notice = stake.unlock_condition
    elseif M.selected_deck(state).unlocked then
        state.notice = nil
    end
    return "stake_changed"
end

function M.activate(state, x, y)
    local id = M.hit_test(state, x, y)
    if id == "deck_left" then
        return select_deck(state, -1)
    elseif id == "deck_right" then
        return select_deck(state, 1)
    elseif id == "stake_left" then
        return select_stake(state, -1)
    elseif id == "stake_right" then
        return select_stake(state, 1)
    elseif id == "seeded" then
        state.seeded = not state.seeded
        state.seed = state.seed_state.seed
        return state.seeded and "seed_on" or "seed_off"
    elseif id == "play" then
        if M.can_play(state) then
            state.notice = nil
            return "start_run"
        end
        local deck = M.selected_deck(state)
        local stake = M.selected_stake(state)
        if deck.unlocked ~= true then
            state.notice = deck.unlock_condition or "잠긴 패입니다"
        else
            state.notice = (stake and stake.unlock_condition) or "잠긴 난이도입니다"
        end
        return "locked"
    end
    return nil
end

local function set_color(graphics, color, alpha)
    graphics.setColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function draw_shadowed_box(graphics, rect, color, radius)
    radius = radius or 3
    graphics.setColor(0, 0, 0, 0.38)
    graphics.rectangle("fill", rect.x + 2, rect.y + 2, rect.w, rect.h, radius, radius)
    set_color(graphics, color)
    graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, radius, radius)
end

local function draw_arrow(graphics, rect, points_right, enabled)
    local w, h = 26, 18
    local cx, cy = rect.x + math.floor((rect.w - w) / 2), rect.y + math.floor((rect.h - h) / 2)
    local api = {
        set_color = function(...)
            local r, g, b, a = ...
            if not enabled then
                graphics.setColor(r * 0.5, g * 0.5, b * 0.5, a)
            else
                graphics.setColor(...)
            end
        end,
        draw = function(...)
            if graphics.draw then
                return graphics.draw(...)
            end
        end,
    }

    local drawn
    if points_right then
        drawn = arrow_art.draw_right(cx, cy, w, h, api)
    else
        drawn = arrow_art.draw_left(cx, cy, w, h, api)
    end

    if not drawn then
        draw_shadowed_box(graphics, rect, enabled and { 0.72, 0.12, 0.15, 1 } or { 0.31, 0.30, 0.33, 1 }, 4)
        graphics.setColor(1, 0.91, 0.66, enabled and 1 or 0.55)
        local px, py = rect.x + rect.w / 2, rect.y + rect.h / 2
        local direction = points_right and 1 or -1
        graphics.polygon("fill",
            px + 6 * direction, py,
            px - 5 * direction, py - 8,
            px - 5 * direction, py + 8)
    end
end

local function draw_deck_art(graphics, deck)
    local rect = LAYOUT.deck_art
    local api = {
        set_color = function(...) graphics.setColor(...) end,
        draw = function(...)
            if graphics.draw then
                return graphics.draw(...)
            end
        end,
    }
    if deck.id == "hwatu" then
        if deck_art.draw_blue(rect.x, rect.y, rect.w, api) then
            return
        end
    elseif deck.id == "thin" then
        if deck_art.draw_red(rect.x, rect.y, rect.w, api) then
            return
        end
    elseif deck.id == "gwang_jackpot" then
        if deck_art.draw_yellow(rect.x, rect.y, rect.w, api) then
            return
        end
    end
    draw_shadowed_box(graphics, rect, deck.colors[1], 5)
    graphics.setColor(0.96, 0.91, 0.73, 1)
    graphics.rectangle("line", rect.x + 3, rect.y + 3, rect.w - 6, rect.h - 6, 3, 3)
    set_color(graphics, deck.colors[2], deck.unlocked and 1 or 0.42)
    graphics.circle("fill", rect.x + rect.w / 2, rect.y + rect.h / 2, 16)
    graphics.setColor(0.16, 0.12, 0.10, 0.78)
    for i = 0, 4 do
        local angle = i * math.pi * 2 / 5 - math.pi / 2
        graphics.circle("fill", rect.x + rect.w / 2 + math.cos(angle) * 11,
            rect.y + rect.h / 2 + math.sin(angle) * 11, 4)
    end
    graphics.circle("fill", rect.x + rect.w / 2, rect.y + rect.h / 2, 3)
end

local function draw_lock(graphics, x, y)
    local api = {
        set_color = function(...) graphics.setColor(...) end,
        draw = function(...)
            if graphics.draw then
                return graphics.draw(...)
            end
        end,
    }
    if effect_art.draw_lock(x, y, 16, api) then
        return
    end
    graphics.setColor(0.92, 0.75, 0.28, 1)
    if graphics.setLineWidth then graphics.setLineWidth(2) end
    if graphics.arc then
        graphics.arc("line", "open", x + 10, y + 9, 7, math.pi, math.pi * 2)
    end
    graphics.rectangle("fill", x + 3, y + 9, 14, 12, 2, 2)
    if graphics.setLineWidth then graphics.setLineWidth(1) end
end

local function draw_deck_info(graphics, font, state)
    local deck = M.selected_deck(state)
    local rect = LAYOUT.deck_info
    graphics.setColor(0.055, 0.075, 0.10, 0.92)
    graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 4, 4)
    graphics.setColor(0.90, 0.72, 0.25, 0.65)
    graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 4, 4)

    if not deck.unlocked then
        draw_lock(graphics, rect.x + 6, rect.y + 3)
        graphics.setColor(0.96, 0.80, 0.38, 1)
        graphics.print("잠김 · " .. deck.name, rect.x + 31, rect.y + 4)
        graphics.setColor(0.88, 0.88, 0.84, 1)
        graphics.printf("해금 조건 · " .. deck.unlock_condition, rect.x + 6, rect.y + 29, rect.w - 12, "left")
        return
    end

    graphics.setColor(0.98, 0.82, 0.34, 1)
    graphics.print(deck.name, rect.x + 7, rect.y + 4)
    graphics.setColor(1, 1, 1, 1)
    graphics.print(deck.description, rect.x + 7, rect.y + 20)
    graphics.setColor(0.72, 0.80, 0.77, 1)
    graphics.printf(deck.detail, rect.x + 7, rect.y + 35, rect.w - 14, "left")
end

local function draw_dots(graphics, state)
    local count = #state.decks
    local spacing = 11
    local start_x = 160 - ((count - 1) * spacing) / 2
    for i = 1, count do
        if i == state.deck_index then
            graphics.setColor(0.95, 0.72, 0.20, 1)
            graphics.circle("fill", start_x + (i - 1) * spacing, LAYOUT.dots.y + 3, 3)
        else
            graphics.setColor(0.52, 0.56, 0.57, 1)
            graphics.circle("fill", start_x + (i - 1) * spacing, LAYOUT.dots.y + 3, 2)
        end
    end
end

local function draw_stake(graphics, state)
    local stake = M.selected_stake(state)
    local rect = LAYOUT.stake
    draw_shadowed_box(graphics, rect, { 0.78, 0.80, 0.77, 1 }, 3)
    local api = {
        set_color = function(...) graphics.setColor(...) end,
        draw = function(...)
            if graphics.draw then
                return graphics.draw(...)
            end
        end,
    }
    if stake.id == "white" then
        stake_art.draw_white(rect.x + 4, rect.y + 1, 16, api)
    elseif stake.id == "red" then
        stake_art.draw_red(rect.x + 4, rect.y + 1, 16, api)
    elseif stake.id == "green" then
        stake_art.draw_green(rect.x + 4, rect.y + 1, 16, api)
    end
    graphics.setColor(0.13, 0.15, 0.16, 1)
    graphics.printf(stake.label .. " · " .. stake.name, rect.x, rect.y + 3, rect.w, "center")
    if stake.unlocked == false then
        draw_lock(graphics, rect.x + 22, rect.y + 1)
    end
    draw_arrow(graphics, LAYOUT.stake_left, false, true)
    draw_arrow(graphics, LAYOUT.stake_right, true, true)
end

local function draw_seed_toggle(graphics, state)
    local rect = LAYOUT.seeded
    local color = state.seeded and { 0.10, 0.46, 0.43, 1 } or { 0.24, 0.27, 0.29, 1 }
    draw_shadowed_box(graphics, rect, color, 4)
    graphics.setColor(1, 1, 1, 1)
    local label = state.seeded and ("시드 ON  " .. state.seed) or "시드 런 OFF"
    graphics.printf(label, rect.x + 3, rect.y + 2, rect.w - 6, "center")
end

local function draw_play(graphics, state)
    local rect = LAYOUT.play
    local color = M.can_play(state) and { 0.08, 0.43, 0.74, 1 } or { 0.35, 0.36, 0.38, 1 }
    draw_shadowed_box(graphics, rect, color, 5)
    graphics.setColor(1, 1, 1, M.can_play(state) and 1 or 0.52)
    graphics.printf("PLAY", rect.x, rect.y + 2, rect.w, "center")
end

function M.draw(state, graphics, embedded)
    graphics = graphics or (love and love.graphics)
    if not graphics then return end

    local fonts = require("game.fonts")
    local old_font = graphics.getFont()
    local font = fonts.get(11, graphics)
    graphics.setFont(font)

    if not embedded then
        graphics.clear(0.025, 0.075, 0.085, 1)
        graphics.setColor(0.04, 0.15, 0.15, 1)
        graphics.rectangle("fill", 0, 0, M.VIEWPORT_W, M.VIEWPORT_H)
        graphics.setColor(0.96, 0.78, 0.28, 1)
        graphics.printf("새 게임", 0, 3, M.VIEWPORT_W, "center")
    end

    draw_shadowed_box(graphics, LAYOUT.panel, { 0.08, 0.11, 0.13, 1 }, 6)
    draw_deck_art(graphics, M.selected_deck(state))
    draw_deck_info(graphics, font, state)
    draw_arrow(graphics, LAYOUT.deck_left, false, true)
    draw_arrow(graphics, LAYOUT.deck_right, true, true)
    draw_dots(graphics, state)
    draw_stake(graphics, state)
    draw_seed_toggle(graphics, state)
    draw_play(graphics, state)

    if state.notice and not embedded then
        graphics.setColor(1, 0.77, 0.32, 1)
        graphics.printf(state.notice, 0, 175 - font:getHeight(), M.VIEWPORT_W, "center")
    end

    graphics.setFont(old_font)
    graphics.setColor(1, 1, 1, 1)
end

return M
