-- game/tests/blind_select_ui.lua
-- Headless tests for game/ui/blind_select.lua

local blind_select = require("game.ui.blind_select")
local run = require("game.run")

local M = {}

function M.run()
    -- new() returns state with 3 blind entries for the given ante
    local s = blind_select.new(1)
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

    -- select_blind sets selected
    blind_select.select_blind(s, 2)
    assert(s.selected == "big", "selected big blind")

    blind_select.select_blind(s, 1)
    assert(s.selected == "small", "selected small blind")

    blind_select.select_blind(s, 3)
    assert(s.selected == "boss", "selected boss blind")

    -- select_blind rejects out-of-range
    local ok = pcall(blind_select.select_blind, s, 0)
    assert(not ok, "reject index 0")
    ok = pcall(blind_select.select_blind, s, 4)
    assert(not ok, "reject index 4")

    -- hit_test: card positions
    local positions = blind_select.card_positions()
    assert(#positions == 3, "3 card positions")
    for i = 1, 3 do
        local p = positions[i]
        local hit = blind_select.hit_test(s, p.x + 2, p.y + 2)
        assert(hit == i, "hit card " .. i .. ", got " .. tostring(hit))
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
