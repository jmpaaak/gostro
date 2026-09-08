local run = require("game.run")

local M = {}

local function beat_current_blind(state)
    run.add_score(state, run.blind_target(state))
    run.clear_blind(state)
end

function M.run()
    require("game.tests.card_deal").run()
    require("game.tests.gwang_inventory").run()

    local state = run.new()
    assert(state.ante == 1)
    assert(state.blind == "small")
    assert(state.phase == "play")
    assert(state.round_score == 0)
    assert(#state.gwang == 0)
    assert(run.MAX_GWANG == 5)
    assert(run.FINAL_ANTE == 8)

    assert(run.blind_target(state) == 300)
    state.blind = "big"
    assert(run.blind_target(state) == 450)
    state.blind = "boss"
    assert(run.blind_target(state) == 600)
    state.ante = 2
    state.blind = "small"
    assert(run.blind_target(state) == 800)
    state.ante = 8
    state.blind = "boss"
    assert(run.blind_target(state) == 100000)

    state = run.new()
    local too_low = pcall(run.clear_blind, state)
    assert(not too_low, "cannot clear below the blind")

    run.add_score(state, 299)
    assert(state.round_score == 299)
    too_low = pcall(run.clear_blind, state)
    assert(not too_low)

    run.add_score(state, 1)
    run.clear_blind(state)
    assert(state.phase == "shop")
    assert(state.ante == 1)
    assert(state.blind == "small")

    local not_shop = pcall(run.buy_gwang, run.new(), { identity = "chips" })
    assert(not not_shop, "buy gwang only in the shop")

    local play_card = pcall(run.buy_gwang, state, { kind = "hongdan", identity = "chips" })
    assert(not play_card, "gwang slots reject play cards")

    local no_id = pcall(run.buy_gwang, state, { kind = "gwang" })
    assert(not no_id, "each gwang has one identity")

    run.buy_gwang(state, { kind = "gwang", identity = "chips" })
    run.buy_gwang(state, { identity = "mult" })
    assert(#state.gwang == 2)
    assert(state.gwang[1].identity == "chips")
    assert(state.gwang[2].identity == "mult")
    assert(state.gwang[1].kind == "gwang")
    assert(state.gwang[2].kind == "gwang")

    run.buy_gwang(state, { identity = "yaku_mult" })
    run.buy_gwang(state, { identity = "chips" })
    run.buy_gwang(state, { identity = "mult" })
    assert(#state.gwang == 5)
    local sixth = pcall(run.buy_gwang, state, { identity = "chips" })
    assert(not sixth, "max 5 gwang joker slots")

    run.leave_shop(state)
    assert(state.phase == "play")
    assert(state.ante == 1)
    assert(state.blind == "big")
    assert(state.round_score == 0)

    beat_current_blind(state)
    run.leave_shop(state)
    assert(state.blind == "boss")

    beat_current_blind(state)
    run.leave_shop(state)
    assert(state.ante == 2)
    assert(state.blind == "small")
    assert(state.phase == "play")
    assert(#state.gwang == 5)

    state.ante = 8
    state.blind = "boss"
    state.phase = "play"
    state.round_score = 0
    beat_current_blind(state)
    assert(state.phase == "won")
    local after_win = pcall(run.leave_shop, state)
    assert(not after_win)

    local blob = table.concat({
        tostring(state.phase),
        state.gwang[1].kind,
        state.gwang[1].identity,
    }, ",")
    assert(not blob:find("고수패", 1, true))
    assert(not blob:find("mae", 1, true))
end

return M
