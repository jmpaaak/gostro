local M = {}

function M.run()
    local qa = require("game.qa.card_overlap")
    local spec = qa.spec()
    assert(spec.canvas_width == 960 and spec.canvas_height == 540)
    assert(spec.card_width == 72 and spec.card_height == 108)
    assert(spec.step == 30 and spec.top_visible_pixels == 30)
    assert(spec.x == 330 and spec.y == 216)
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
        getDimensions = function() return 360, 108 end,
        setFilter = function(_, min, mag) calls.filter = { min, mag } end,
    }
    qa.draw(graphics, image)
    assert(calls.filter[1] == "nearest" and calls.filter[2] == "nearest")
    assert(#calls.quads == 5 and #calls.draws == 5)
    for index = 1, 5 do
        local quad, draw = calls.quads[index], calls.draws[index]
        assert(quad[1] == (index - 1) * 72 and quad[2] == 0)
        assert(quad[3] == 72 and quad[4] == 108 and quad[5] == 360 and quad[6] == 108)
        assert(draw.x == 330 + (index - 1) * 30 and draw.y == 216)
    end
    print("card_overlap_qa: OK")
end

return M
