-- End-of-run presentation and input. The play scene delegates here.

local effect_art = require("game.ui.effect_art")
local panel_art = require("game.ui.panel_art")
local fonts = require("game.fonts")
local gwang_slots = require("game.ui.gwang_slots")

local M = {}

local PANEL = { x = 220, y = 58, w = 520, h = 424 }
local RESTART = { x = 360, y = 410, w = 240, h = 54 }

local function terminal(outcome)
    return outcome == "won" or outcome == "lost"
end

function M.restart_rect()
    return { x = RESTART.x, y = RESTART.y, w = RESTART.w, h = RESTART.h }
end

function M.view(run_state, outcome)
    run_state = run_state or {}
    local labels = {}
    for _, gwang in ipairs(run_state.gwang or {}) do
        labels[#labels + 1] = gwang_slots.display_text(gwang)
    end
    if #labels == 0 then labels[1] = "보유 광 없음" end
    return {
        title = outcome == "won" and "승리!" or "도전 종료",
        subtitle = outcome == "won" and "마지막 대장판을 돌파했습니다" or "목표 점수에 도달하지 못했습니다",
        ante_label = "최종 고 " .. tostring(run_state.ante or 1),
        score_label = "최종 점수 " .. tostring(run_state.round_score or 0),
        seed_label = "시드 " .. tostring(run_state.seed or "-") ,
        gwang_title = "보유 광",
        gwang_labels = labels,
        restart_label = "다시 시작",
    }
end

function M.hit_test(x, y)
    if not x or not y then return nil end
    if x >= RESTART.x and x < RESTART.x + RESTART.w
        and y >= RESTART.y and y < RESTART.y + RESTART.h then
        return "restart"
    end
    return nil
end

function M.mousemoved(scene, x, y)
    if not terminal(scene.state) then return false end
    scene.end_screen_hover = M.hit_test(x, y) == "restart"
    return true
end

function M.mousepressed(scene, x, y, restart)
    if not terminal(scene.state) then return nil end
    local action = M.hit_test(x, y)
    if action == "restart" and restart then restart(scene) end
    return action
end

function M.keypressed(scene, key, restart)
    if not terminal(scene.state) then return nil end
    if key == "return" or key == "kpenter" or key == "space" then
        if restart then restart(scene) end
        return "restart"
    end
    return nil
end

function M.route(scene, event, a, b, restart)
    if not terminal(scene.state) then return false end
    if event == "mousepressed" then
        M.mousepressed(scene, a, b, restart)
    elseif event == "mousemoved" then
        M.mousemoved(scene, a, b)
    elseif event == "keypressed" then
        M.keypressed(scene, a, restart)
    end
    return true
end

function M.draw(scene)
    if not love or not love.graphics or not terminal(scene.state) then return end
    local graphics = love.graphics
    local data = M.view(scene.run_state, scene.state)

    if scene.state == "won" then
        effect_art.draw_win(0, 0)
    else
        effect_art.draw_loss(0, 0)
    end
    graphics.setColor(0.02, 0.025, 0.06, 0.64)
    graphics.rectangle("fill", 0, 0, 960, 540)
    if not panel_art.draw("metal", PANEL) then
        graphics.setColor(0.06, 0.07, 0.12, 0.96)
        graphics.rectangle("fill", PANEL.x, PANEL.y, PANEL.w, PANEL.h, 8, 8)
        graphics.setColor(0.46, 0.52, 0.66, 1)
        graphics.rectangle("line", PANEL.x, PANEL.y, PANEL.w, PANEL.h, 8, 8)
    end

    local title_font = fonts.get(66)
    local body_font = fonts.get(22)
    graphics.setFont(title_font)
    graphics.setColor(scene.state == "won" and 1 or 0.96, scene.state == "won" and 0.86 or 0.38, 0.28, 1)
    graphics.printf(data.title, PANEL.x, 84, PANEL.w, "center")

    graphics.setFont(body_font)
    graphics.setColor(0.88, 0.91, 0.96, 1)
    graphics.printf(data.subtitle, PANEL.x + 20, 158, PANEL.w - 40, "center")
    graphics.print(data.ante_label, 270, 210)
    graphics.print(data.score_label, 270, 246)
    graphics.print(data.seed_label, 270, 282)
    graphics.setColor(1, 0.86, 0.32, 1)
    graphics.print(data.gwang_title, 500, 210)
    graphics.setColor(0.92, 0.93, 0.98, 1)
    for i, label in ipairs(data.gwang_labels) do
        if i > 5 then break end
        graphics.print(label, 500, 210 + i * 28)
    end

    local hovered = scene.end_screen_hover == true
    graphics.setColor(hovered and 0.34 or 0.20, hovered and 0.68 or 0.48, hovered and 1 or 0.82, 1)
    graphics.rectangle("fill", RESTART.x, RESTART.y, RESTART.w, RESTART.h, 7, 7)
    graphics.setColor(hovered and 1 or 0.72, hovered and 0.96 or 0.84, hovered and 0.46 or 0.32, 1)
    graphics.setLineWidth(hovered and 3 or 2)
    graphics.rectangle("line", RESTART.x, RESTART.y, RESTART.w, RESTART.h, 7, 7)
    graphics.setColor(1, 1, 1, 1)
    graphics.printf(data.restart_label, RESTART.x, RESTART.y + 14, RESTART.w, "center")
    graphics.setLineWidth(1)
    graphics.setColor(1, 1, 1, 1)
end

return M
