local M = {}

local planets = require("game.planets")
local hwatu = require("game.hwatu")
local run = require("game.run")

function M.run()
    local state = run.new()
    
    -- initial level is 1
    local lvl = planets.get_level(state, "hongdan")
    assert(lvl == 1)
    
    local p = planets.buy(state, "hongdan")
    assert(p.id == "planet_hongdan")
    assert(planets.get_level(state, "hongdan") == 2)
    
    -- evaluate hand with hongdan
    local hand = {
        hwatu.card("hongdan"),
        hwatu.card("hongdan"),
        hwatu.card("hongdan"),
        hwatu.card("pi"),
        hwatu.card("pi")
    }
    
    local res = hwatu.evaluate(hand, state)
    -- Base: 3 hongdan cards (3*10 = 30) + 2 pi cards (2*1 = 2) = 32 chips
    -- mult = 2
    -- planet lvl 2 hongdan: +15 chips, +1 mult
    -- total chips: 32 + 15 = 47
    -- total mult: 2 + 1 = 3
    
    assert(res.chips == 47, "expected 47 chips, got " .. res.chips)
    assert(res.mult == 3, "expected 3 mult, got " .. res.mult)
    assert(res.score == 47 * 3)
end

return M
