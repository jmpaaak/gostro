-- game/tests/blind_select_ui.lua
-- Headless tests for game/ui/blind_select.lua

local blind_select = require("game.ui.blind_select")

local M = {}

local function model(ante, current)
    ante = ante or 1
    current = current or "small"
    local kinds = { "small", "big", "boss" }
    local base_targets = { 300, 450, 600 }
    local current_index = ({ small = 1, big = 2, boss = 3 })[current]
    local blinds = {}
    for i, kind in ipairs(kinds) do
        blinds[i] = {
            kind = kind,
            target = base_targets[i] * ante,
            playable = i == current_index,
            status = i < current_index and "completed"
                or (i == current_index and "current" or "upcoming"),
        }
    end
    return { ante = ante, current = current, phase = "play", blinds = blinds }
end

function M.run()
    require("game.tests.blind_card_art").run()

    -- new() returns state with 3 blind entries for the given ante
    local s = blind_select.new(model(1, "small"))
    assert(s.ante == 1, "ante stored")
    assert(#s.blinds == 3, "3 blinds (small/big/boss)")
    assert(s.blinds[1].kind == "small", "first is small")
    assert(s.blinds[2].kind == "big", "second is big")
    assert(s.blinds[3].kind == "boss", "third is boss")
    assert(s.selected == nil, "nothing selected initially")

    -- Each blind has target_score and reward/penalty text
    for i, b in ipairs(s.blinds) do
        assert(type(b.target) == "number" and b.target > 0,
            "blind " .. i .. " has positive target")
        assert(type(b.reward) == "string" and #b.reward > 0,
            "blind " .. i .. " has reward text")
    end

    assert(s.blinds[1].target == 300 and s.blinds[2].target == 450
        and s.blinds[3].target == 600,
        "UI preserves gameplay-projected targets")

    -- Ante 2 gives different targets
    local s2 = blind_select.new(model(2))
    assert(s2.blinds[1].target > s.blinds[1].target,
        "ante 2 small > ante 1 small")

    assert(s.current == "small", "current blind is stored")
    assert(s.blinds[1].available == true, "current small blind is available")
    assert(s.blinds[2].available == false and s.blinds[3].available == false,
        "future blinds are previews, not shortcuts")

    -- Only the current sequential blind can be selected.
    local ok = pcall(blind_select.select_blind, s, 2)
    assert(not ok and s.selected == nil, "cannot jump from small to big")
    blind_select.select_blind(s, 1)
    assert(s.selected == "small", "selected small blind")

    local big = blind_select.new(model(1, "big"))
    assert(big.blinds[2].available == true and big.blinds[1].available == false,
        "big is the only available blind after small")
    blind_select.select_blind(big, 2)
    assert(big.selected == "big", "current big blind can be selected")

    local boss = blind_select.new(model(1, "boss"))
    assert(boss.blinds[3].available == true and boss.blinds[2].available == false,
        "boss is the only available blind after big")
    blind_select.select_blind(boss, 3)
    assert(boss.selected == "boss", "current boss blind can be selected")

    -- select_blind rejects out-of-range
    ok = pcall(blind_select.select_blind, s, 0)
    assert(not ok, "reject index 0")
    ok = pcall(blind_select.select_blind, s, 4)
    assert(not ok, "reject index 4")

    -- hit_test: card positions
    local positions = blind_select.card_positions()
    assert(#positions == 3, "3 card positions")
    local current = positions[1]
    assert(blind_select.hit_test(s, current.x + 2, current.y + 2) == 1,
        "current blind card can be hit")
    for i = 2, 3 do
        local p = positions[i]
        assert(blind_select.hit_test(s, p.x + 2, p.y + 2) == nil,
            "future blind card " .. i .. " is not actionable")
    end

    -- hit_test: miss
    local miss = blind_select.hit_test(s, 0, 0)
    assert(miss == nil, "miss returns nil")

    -- display_name
    assert(blind_select.display_name("small") == "첫판")
    assert(blind_select.display_name("big") == "큰판")
    assert(blind_select.display_name("boss") == "대장판")

    print("  blind_select_ui: OK")
end

return M
