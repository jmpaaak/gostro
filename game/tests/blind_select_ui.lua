-- game/tests/blind_select_ui.lua
-- Headless tests for game/ui/blind_select.lua

local blind_select = require("game.ui.blind_select")
local run = require("game.run")

local M = {}

function M.run()
    -- new() returns state with 3 blind entries for the given ante
    local s = blind_select.new(1, "small")
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

    -- Targets match run.blind_target
    local rs = run.new()
    rs.ante = 1
    rs.blind = "small"
    assert(s.blinds[1].target == run.blind_target(rs), "small target matches run")
    rs.blind = "big"
    assert(s.blinds[2].target == run.blind_target(rs), "big target matches run")
    rs.blind = "boss"
    assert(s.blinds[3].target == run.blind_target(rs), "boss target matches run")

    -- Ante 2 gives different targets
    local s2 = blind_select.new(2)
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

    local big = blind_select.new(1, "big")
    assert(big.blinds[2].available == true and big.blinds[1].available == false,
        "big is the only available blind after small")
    blind_select.select_blind(big, 2)
    assert(big.selected == "big", "current big blind can be selected")

    local boss = blind_select.new(1, "boss")
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
    assert(blind_select.display_name("small") == "스몰 블라인드")
    assert(blind_select.display_name("big") == "빅 블라인드")
    assert(blind_select.display_name("boss") == "보스 블라인드")

    print("  blind_select_ui: OK")
end

return M
