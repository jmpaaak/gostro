local scene_stack = require("game.scene_stack")

local M = {}

function M.run()
    local calls = {}
    local scene = {
        mousepressed = function(_, x, y, button, istouch, presses)
            calls[#calls + 1] = { x, y, button, istouch, presses }
        end,
    }
    local stack = scene_stack.new(scene)

    local delivered = scene_stack.screenpressed(stack, 640, 360, 1280, 720, 2, false, 3)
    assert(delivered == true, "inside pointer press is delivered")
    assert(#calls == 1, "inside pointer press reaches current scene once")
    assert(calls[1][1] == 480 and calls[1][2] == 270, "screen coordinates convert to game coordinates")
    assert(calls[1][3] == 2 and calls[1][4] == false and calls[1][5] == 3, "mouse metadata is preserved")

    delivered = scene_stack.screenpressed(stack, 10, 360, 1000, 720, 1, true, 1)
    assert(delivered == false, "letterbox pointer press is ignored")
    assert(#calls == 1, "letterbox pointer press does not reach scene")

    delivered = scene_stack.screenpressed(stack, 500, 360, 1920, 1080, 1, true, 1)
    assert(delivered == true, "touch-style pointer press is delivered")
    assert(#calls == 2 and calls[2][1] == 250 and calls[2][2] == 180, "touch coordinates use the same viewport conversion")
    assert(calls[2][4] == true, "touch marker reaches the scene")

    local moves = {}
    scene.mousemoved = function(_, x, y)
        moves[#moves + 1] = { x, y }
    end
    assert(scene_stack.screenmoved(stack, 640, 360, 1280, 720) == true, "inside pointer move is delivered")
    assert(#moves == 1 and moves[1][1] == 480 and moves[1][2] == 270)
    assert(scene_stack.screenmoved(stack, 10, 360, 1000, 720) == false, "letterbox pointer move is ignored")
    assert(#moves == 2 and moves[2][1] == nil, "leaving the letterbox clears hover")

    local no_handler = scene_stack.new({})
    assert(scene_stack.screenpressed(no_handler, 640, 360, 1280, 720, 1, false, 1) == false,
        "scene without a mouse handler safely declines input")

    print("  input_routing: OK")
end

return M
