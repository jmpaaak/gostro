local run_setup = require("game.ui.run_setup")

local M = {}

local function center(rect)
    return rect.x + rect.w / 2, rect.y + rect.h / 2
end

local function activate_rect(state, rect)
    local x, y = center(rect)
    return run_setup.activate(state, x, y)
end

function M.run()
    local state = run_setup.new(" gostro-01 ")
    assert(run_setup.VIEWPORT_W == 960 and run_setup.VIEWPORT_H == 540,
        "run setup targets the native 960x540 viewport")
    assert(#state.decks >= 3, "at least three starter deck variants are available")
    assert(state.deck_index == 1, "the first deck is selected by default")
    assert(state.decks[1].name == "화투패" and state.decks[1].description == "기본 패 구성",
        "the default unlocked hwatu deck has Gostro-specific copy")
    assert(state.decks[1].unlocked == true, "the default deck is unlocked")
    assert(state.decks[2].name == "얇은 패" and state.decks[2].description == "피 비중이 적은 구성",
        "the thin deck is an unlocked thematic variant")
    assert(state.decks[2].unlocked == true, "the thin deck is unlocked")
    assert(state.decks[3].name == "광대박패" and state.decks[3].unlocked == false,
        "the gwang jackpot deck starts locked")
    assert(type(state.decks[3].unlock_condition) == "string" and #state.decks[3].unlock_condition > 0,
        "a locked deck exposes an explicit unlock condition")
    assert(#state.stakes >= 1 and state.stakes[1].name == "기본 난이도",
        "stake selection starts at base difficulty")
    assert(state.stake_index == 1, "the base stake is initially selected")
    assert(state.seeded == false, "seeded run is initially disabled")
    assert(state.seed == "GOSTRO01", "seed input uses game.ui.seed normalization")
    assert(run_setup.can_play(state) == true, "the default setup can be played")

    local rects = run_setup.layout()
    local expected_hits = {
        deck_left = rects.deck_left,
        deck_right = rects.deck_right,
        stake_left = rects.stake_left,
        stake_right = rects.stake_right,
        seeded = rects.seeded,
        play = rects.play,
    }
    for id, rect in pairs(expected_hits) do
        assert(run_setup.hit_test(state, rect.x, rect.y) == id,
            id .. " includes its top-left edge")
        assert(run_setup.hit_test(state, rect.x + rect.w - 1, rect.y + rect.h - 1) == id,
            id .. " includes its inner bottom-right pixel")
    end
    assert(run_setup.hit_test(state, -1, -1) == nil, "outside coordinates miss")
    assert(run_setup.hit_test(state, 160, 3) == nil, "non-control panel space is inert")

    assert(activate_rect(state, rects.deck_left) == "deck_changed", "left deck arrow cycles")
    assert(state.deck_index == #state.decks, "left deck arrow wraps first to last")
    assert(run_setup.selected_deck(state).id == "gwang_jackpot", "wrapped deck is selected")
    assert(state.notice == state.decks[3].unlock_condition, "selecting a lock exposes its condition")

    assert(activate_rect(state, rects.play) == "locked", "locked play returns explicit feedback")
    assert(run_setup.can_play(state) == false, "play is disabled for a locked deck")
    assert(state.notice:find(state.decks[3].unlock_condition, 1, true),
        "locked play keeps the explicit unlock condition visible")

    assert(activate_rect(state, rects.deck_right) == "deck_changed", "right deck arrow cycles")
    assert(state.deck_index == 1, "right deck arrow wraps last to first")
    assert(run_setup.can_play(state) == true, "play re-enables on an unlocked deck")
    assert(state.notice == nil, "unlock selection clears lock feedback")

    assert(activate_rect(state, rects.stake_left) == "stake_changed", "stake arrows are active")
    assert(state.stake_index == #state.stakes, "stake model supports reverse wrap")
    assert(run_setup.selected_stake(state).id == "green", "wrapped stake is the locked green chip")
    assert(state.notice == state.stakes[3].unlock_condition, "selecting a locked stake exposes its condition")
    assert(run_setup.can_play(state) == false, "play is disabled for a locked stake")
    assert(activate_rect(state, rects.play) == "locked", "locked green stake play returns explicit feedback")
    assert(activate_rect(state, rects.stake_right) == "stake_changed", "stake forward arrow is active")
    assert(state.stake_index == 1, "stake forward wrap returns to the base chip")
    assert(run_setup.can_play(state) == true, "play re-enables on the unlocked base stake")

    assert(activate_rect(state, rects.seeded) == "seed_on", "seed toggle reports enabled state")
    assert(state.seeded == true and type(state.seed) == "string" and #state.seed > 0,
        "enabled seeded run exposes a valid seed string")
    assert(state.seed_state.seed == state.seed, "run setup and seed UI states stay synchronized")
    assert(run_setup.set_seed(state, " new-seed ") == "NEWSEED", "set_seed normalizes via seed UI")
    assert(state.seed == "NEWSEED" and state.seed_state.seed == "NEWSEED",
        "normalized seed is exposed by both state representations")
    assert(activate_rect(state, rects.seeded) == "seed_off", "seed toggle reports disabled state")
    assert(state.seeded == false, "seeded run can be disabled")
    assert(state.seed == "NEWSEED", "disabling preserves the entered seed for later reuse")

    assert(activate_rect(state, rects.play) == "start_run", "valid play starts the run")
    assert(run_setup.activate(state, 0, 0) == nil, "activating empty space does nothing")

    -- Rendering is dependency-injected and can be exercised without a window or hover state.
    local font = { getHeight = function() return 11 end }
    local calls = { rectangles = 0, prints = 0 }
    local graphics = {
        clear = function() end,
        setColor = function() end,
        rectangle = function() calls.rectangles = calls.rectangles + 1 end,
        circle = function() end,
        polygon = function() end,
        arc = function() end,
        setLineWidth = function() end,
        print = function() calls.prints = calls.prints + 1 end,
        printf = function() calls.prints = calls.prints + 1 end,
        getFont = function() return font end,
        setFont = function() end,
        draw = function() calls.draws = (calls.draws or 0) + 1 end,
    }
    local old_fonts = package.loaded["game.fonts"]
    package.loaded["game.fonts"] = { get = function() return font end }
    run_setup.draw(state, graphics)
    activate_rect(state, rects.deck_left) -- locked variant
    run_setup.draw(state, graphics)
    package.loaded["game.fonts"] = old_fonts
    assert(calls.rectangles > 0 and calls.prints > 0,
        "unlocked and locked setup states render through injected graphics")

    print("  run_setup_ui: OK")
end

return M
