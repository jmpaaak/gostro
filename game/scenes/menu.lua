local main_menu = require("game.ui.main_menu")
local run_setup = require("game.ui.run_setup")
local scene_stack = require("game.scene_stack")
local PlayScene = require("game.scenes.play")

local M = {}
M.__index = M

function M.new(seed_string)
    return setmetatable({
        ui = main_menu.new(),
        setup = run_setup.new(seed_string),
        stack = nil,
    }, M)
end

function M:bind(stack)
    assert(stack and stack.current == self, "menu must bind to its active scene stack")
    self.stack = stack
    return self
end

function M:draw()
    main_menu.draw(self.ui)
    if self.ui.mode == "play_menu" and self.ui.selected_tab == "new_game" then
        run_setup.draw(self.setup, nil, true)
    end
end

local function begin_run(scene)
    assert(scene.stack, "menu scene must be bound before starting a game")
    local deck = run_setup.selected_deck(scene.setup)
    local stake = run_setup.selected_stake(scene.setup)
    local seed_string = scene.setup.seeded and scene.setup.seed or nil
    local play_scene = PlayScene.new({
        starting_deck_id = deck.id,
        stake_id = stake.id,
        seeded = scene.setup.seeded,
        seed = seed_string,
    })
    scene_stack.switch(scene.stack, play_scene)
end

function M:mousepressed(x, y, button)
    if button and button ~= 1 then return nil end

    if main_menu.hit_test(self.ui, x, y) then
        return main_menu.activate(self.ui, x, y)
    end

    if self.ui.mode == "play_menu" and self.ui.selected_tab == "new_game" then
        local action = run_setup.activate(self.setup, x, y)
        if action == "start_run" then begin_run(self) end
        return action
    end
    return nil
end

return M
