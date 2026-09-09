-- Blind-select cards show target, reward, and current-판 copy.

local blind_select = require("game.ui.blind_select")

local M = {}

local function model()
    return {
        ante = 1,
        current = "small",
        phase = "play",
        blinds = {
            { kind = "small", target = 300, playable = true, status = "current" },
            { kind = "big", target = 450, playable = false, status = "upcoming" },
            { kind = "boss", target = 600, playable = false, status = "upcoming" },
        },
    }
end

function M.run()
    local s = blind_select.new(model())
    local current = blind_select.card_copy(s.blinds[1])
    assert(current.name == "첫판")
    assert(current.target_label == "목표 300")
    assert(current.reward_label == "보상 +$3")
    assert(current.status == "지금 도전")

    local waiting = blind_select.card_copy(s.blinds[2])
    assert(waiting.status == "대기")
    assert(waiting.target_label == "목표 450")

    local pos = blind_select.card_positions()[1]
    blind_select.set_hover_at(s, pos.x + 2, pos.y + 2)
    assert(s.hover == 1, "current 판 lifts on hover")
    local future = blind_select.card_positions()[2]
    blind_select.set_hover_at(s, future.x + 2, future.y + 2)
    assert(s.hover == nil, "future 판 is not hoverable")

    print("  blind_copy: OK")
end

return M
