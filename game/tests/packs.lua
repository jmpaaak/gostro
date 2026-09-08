local packs = require("game.packs")
local rng = require("game.rng")

local M = {}

local function state(seed)
    return {
        rng = { shop = rng.plan(seed or "PACKS").shop },
        tarots = {},
        vouchers = {},
    }
end

function M.run()
    print("  packs:")

    local a = state("SAMEPACK")
    local opened = packs.open(a, "arcana_pack")
    assert(opened == a.pending_pack and opened.choose == 1)
    assert(#opened.choices == 3)
    for i = 1, #opened.choices do
        assert(type(opened.choices[i].id) == "string")
        assert(type(opened.choices[i].name) == "string")
    end

    local b = state("SAMEPACK")
    local repeated = packs.open(b, "arcana_pack")
    for i = 1, 3 do
        assert(opened.choices[i].id == repeated.choices[i].id, "same seed reproduces choices")
    end

    local ok = pcall(packs.open, a, "arcana_pack")
    assert(not ok, "only one pack may be pending")

    local chosen = packs.choose(a, 2)
    assert(chosen.id == opened.choices[2].id)
    assert(#a.tarots == 1 and a.tarots[1].source == "shop")
    assert(a.pending_pack == nil, "choosing closes the pack")

    local skipped = packs.open(a, "arcana_pack")
    assert(packs.skip(a) == skipped)
    assert(a.pending_pack == nil, "skip closes the pack")

    print("  packs: OK")
end

return M