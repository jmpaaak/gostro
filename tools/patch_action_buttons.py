from pathlib import Path

content = Path("game/ui/action_buttons.lua").read_text()

replacement = """
    -- Play button
    local play_kind = ab.play_enabled and "primary" or "disabled"
    button_art.draw(play_kind, {x = M.PLAY_X, y = M.BUTTON_Y, w = M.BUTTON_W, h = M.BUTTON_H})

    -- Play text
    local play_txt = M.display_text(ab, "play")
    score_icon_art.draw_hand(M.PLAY_X + 3, M.BUTTON_Y + 3, 12)
    love.graphics.setColor(1, 1, 1, ab.play_enabled and 1 or 0.4)
    love.graphics.print(play_txt,
        M.PLAY_X + 17,
        M.BUTTON_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Discard button
    local dis_kind = ab.discard_enabled and "danger" or "disabled"
    button_art.draw(dis_kind, {x = M.DISCARD_X, y = M.BUTTON_Y, w = M.BUTTON_W, h = M.BUTTON_H})

    -- Discard text
    local dis_txt = M.display_text(ab, "discard")
    score_icon_art.draw_discard(M.DISCARD_X + 3, M.BUTTON_Y + 3, 12)
    love.graphics.setColor(1, 1, 1, ab.discard_enabled and 1 or 0.4)
    love.graphics.print(dis_txt,
        M.DISCARD_X + 17,
        M.BUTTON_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
"""

old_draw = """
    -- Play button (blue)
    local play_bg_r, play_bg_g, play_bg_b = 0.15, 0.35, 0.7
    local dis_bg_r, dis_bg_g, dis_bg_b = 0.7, 0.15, 0.2

    if not ab.play_enabled then
        play_bg_r, play_bg_g, play_bg_b = 0.2, 0.2, 0.3
    end
    love.graphics.setColor(play_bg_r, play_bg_g, play_bg_b, 0.9)
    love.graphics.rectangle("fill", M.PLAY_X, M.BUTTON_Y, M.BUTTON_W, M.BUTTON_H, 3, 3)
    love.graphics.setColor(0.4, 0.6, 1, 0.8)
    love.graphics.rectangle("line", M.PLAY_X, M.BUTTON_Y, M.BUTTON_W, M.BUTTON_H, 3, 3)

    -- Play text
    local play_txt = M.display_text(ab, "play")
    score_icon_art.draw_hand(M.PLAY_X + 3, M.BUTTON_Y + 3, 12)
    love.graphics.setColor(1, 1, 1, ab.play_enabled and 1 or 0.4)
    love.graphics.print(play_txt,
        M.PLAY_X + 17,
        M.BUTTON_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Discard button (red)
    if not ab.discard_enabled then
        dis_bg_r, dis_bg_g, dis_bg_b = 0.3, 0.2, 0.2
    end
    love.graphics.setColor(dis_bg_r, dis_bg_g, dis_bg_b, 0.9)
    love.graphics.rectangle("fill", M.DISCARD_X, M.BUTTON_Y, M.BUTTON_W, M.BUTTON_H, 3, 3)
    love.graphics.setColor(1, 0.4, 0.4, 0.8)
    love.graphics.rectangle("line", M.DISCARD_X, M.BUTTON_Y, M.BUTTON_W, M.BUTTON_H, 3, 3)

    -- Discard text
    local dis_txt = M.display_text(ab, "discard")
    score_icon_art.draw_discard(M.DISCARD_X + 3, M.BUTTON_Y + 3, 12)
    love.graphics.setColor(1, 1, 1, ab.discard_enabled and 1 or 0.4)
    love.graphics.print(dis_txt,
        M.DISCARD_X + 17,
        M.BUTTON_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
"""

content = content.replace(old_draw.strip(), replacement.strip())

if "local button_art =" not in content:
    content = content.replace('local score_icon_art = require("game.ui.score_icon_art")', 
                              'local score_icon_art = require("game.ui.score_icon_art")\nlocal button_art = require("game.ui.button_art")')

Path("game/ui/action_buttons.lua").write_text(content)
