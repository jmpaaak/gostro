local M = {}

function M.run()
    local qa = require("game.qa.card_overlap")
    local spec = qa.spec()
    assert(spec.canvas_width == 320 and spec.canvas_height == 180)
    assert(spec.card_width == 48 and spec.card_height == 72)
    assert(spec.step == 20 and spec.top_visible_pixels == 20)
    assert(spec.x == 80 and spec.y == 54)
    assert(table.concat(spec.card_order, ",") == "pi,hongdan,cheongdan,chodan,godori")

    local calls = { quads = {}, draws = {} }
    local graphics = {
        newQuad = function(x, y, width, height, sheet_width, sheet_height)
            local quad = { x, y, width, height, sheet_width, sheet_height }
            calls.quads[#calls.quads + 1] = quad
            return quad
        end,
        draw = function(_, quad, x, y)
            calls.draws[#calls.draws + 1] = { quad = quad, x = x, y = y }
        end,
    }
    local image = {
        getDimensions = function() return 240, 72 end,
        setFilter = function(_, min, mag) calls.filter = { min, mag } end,
    }
    qa.draw(graphics, image)
    assert(calls.filter[1] == "nearest" and calls.filter[2] == "nearest")
    assert(#calls.quads == 5 and #calls.draws == 5)
    for index = 1, 5 do
        local quad, draw = calls.quads[index], calls.draws[index]
        assert(quad[1] == (index - 1) * 48 and quad[2] == 0)
        assert(quad[3] == 48 and quad[4] == 72 and quad[5] == 240 and quad[6] == 72)
        assert(draw.x == 80 + (index - 1) * 20 and draw.y == 54)
    end
    print("card_overlap_qa: OK")
end

return M
