local main_menu = require("game.ui.main_menu")
local scene_stack = require("game.scene_stack")
local PlayScene = require("game.scenes.play")

local M = {}
M.__index = M

function M.new()
    return setmetatable({ ui = main_menu.new(), stack = nil }, M)
end

function M:bind(stack)
    assert(stack and stack.current == self, "menu must bind to its active scene stack")
    self.stack = stack
    return self
end

function M:draw()
    main_menu.draw(self.ui)
end

function M:mousepressed(x, y, button)
    if button and button ~= 1 then return nil end

    local action = main_menu.activate(self.ui, x, y)
    if action == "new_game" then
        assert(self.stack, "menu scene must be bound before starting a game")
        scene_stack.switch(self.stack, PlayScene.new())
    end
    return action
end

return M
