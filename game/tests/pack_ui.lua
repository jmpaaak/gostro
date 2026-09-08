-- game/tests/pack_ui.lua
-- Pure overlay contract and play-scene routing for an opened booster pack.

local pack_ui = require("game.ui.pack")
local packs = require("game.packs")
local play = require("game.scenes.play")
local shop_engine = require("game.shop_engine")
local shop_ui = require("game.ui.shop")

local M = {}

local function center(bounds)
    return bounds.x + math.floor(bounds.w / 2), bounds.y + math.floor(bounds.h / 2)
end

function M.run()
    print("  pack_ui:")

    local pending = {
        name = "부적 꾸러미",
        choose = 1,
        choices = {
            { id = "dungap_bu", name = "둔갑부", effect = "변환" },
            { id = "somyeol_bu", name = "소멸부", effect = "파괴" },
            { id = "gwangchae_bu", name = "광채부", effect = "효과 부여" },
        },
    }
    local view = pack_ui.view(pending)
    assert(view.title == "부적 꾸러미" and view.instruction == "1장 선택")
    assert(#view.choices == 3, "all revealed choices are represented")
    for i = 1, 3 do
        local x, y = center(view.choices[i].bounds)
        assert(pack_ui.hit_test(pending, x, y) == i, "choice bounds drive hit-test")
        assert(view.choices[i].name == pending.choices[i].name)
    end
    local skip_x, skip_y = center(view.skip_bounds)
    assert(pack_ui.hit_test(pending, skip_x, skip_y) == "skip")
    assert(pack_ui.hit_test(nil, skip_x, skip_y) == nil)
    assert(pack_ui.hit_test(pending, 0, 0) == nil)

    -- An open pack is modal: choosing or skipping routes through packs.lua,
    -- while underlying shop controls cannot fire.
    local scene = play.new("PACK-UI")
    scene.state = "shop"
    scene.shop = shop_engine.new(scene.run_state)
    local opened = packs.open(scene.run_state, "talisman_bundle")
    local opened_view = pack_ui.view(opened)
    local choice_x, choice_y = center(opened_view.choices[1].bounds)
    scene:mousepressed(choice_x, choice_y)
    assert(scene.run_state.pending_pack == nil, "choice closes the overlay")
    assert(#scene.run_state.talismans == 1
        and scene.run_state.talismans[1].id == opened.choices[1].id,
        "scene choice grants the selected talisman")

    opened = packs.open(scene.run_state, "talisman_bundle")
    local money = scene.run_state.money
    scene:mousepressed(shop_ui.REROLL_X + 2, shop_ui.REROLL_Y + 2)
    assert(scene.run_state.pending_pack == opened and scene.run_state.money == money,
        "overlay blocks underlying shop controls")
    opened_view = pack_ui.view(opened)
    skip_x, skip_y = center(opened_view.skip_bounds)
    scene:mousepressed(skip_x, skip_y)
    assert(scene.run_state.pending_pack == nil and scene.state == "shop",
        "skip closes only the overlay")

    print("  pack_ui: OK")
end

return M
