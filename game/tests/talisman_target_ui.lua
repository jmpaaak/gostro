-- game/tests/talisman_target_ui.lua
-- Pure option/target selection contract. This slice must not execute a talisman.

local talisman_target = require("game.ui.talisman_target")
local talismans = require("game.talismans")

local M = {}

local function center(bounds)
    return bounds.x + math.floor(bounds.w / 2),
        bounds.y + math.floor(bounds.h / 2)
end

local function press(flow, cards, item)
    local x, y = center(item.bounds or item)
    return talisman_target.activate(flow, cards, x, y)
end

function M.run()
    print("  talisman_target_ui:")
    local cards = {
        talismans.make_card("hongdan"),
        talismans.make_card("godori"),
        talismans.make_card("pi"),
    }

    local convert = talisman_target.new(2, talismans.by_id("dungap_bu"))
    local view = talisman_target.view(convert, cards)
    assert(convert.slot == 2 and convert.effect == "convert")
    assert(#view.options == 5 and #view.targets == 3)
    assert(view.options[1].value == "hongdan")
    assert(view.can_select_target == false,
        "conversion requires a kind before a target")
    local tx, ty = center(view.targets[1].bounds)
    assert(talisman_target.hit_test(convert, cards, tx, ty) == nil,
        "target hit testing is gated until an option is selected")
    assert(press(convert, cards, view.options[2]) == "option")
    assert(convert.option == "cheongdan")
    view = talisman_target.view(convert, cards)
    assert(view.options[2].selected and view.can_select_target)
    assert(press(convert, cards, view.targets[3]) == "target")
    local request = talisman_target.request(convert, cards)
    assert(request.slot == 2 and request.index == 3)
    assert(request.opts.kind == "cheongdan")

    local enhance = talisman_target.new(1, talismans.by_id("gwangchae_bu"))
    view = talisman_target.view(enhance, cards)
    assert(#view.options == 3 and view.options[1].value == "foil")
    press(enhance, cards, view.options[3])
    view = talisman_target.view(enhance, cards)
    press(enhance, cards, view.targets[2])
    request = talisman_target.request(enhance, cards)
    assert(request.opts.effect == "polychrome" and request.index == 2)

    for _, id in ipairs({ "somyeol_bu", "bunsin_bu" }) do
        local flow = talisman_target.new(1, talismans.by_id(id))
        view = talisman_target.view(flow, cards)
        assert(#view.options == 0 and view.can_select_target,
            "destroy and copy go directly to target selection")
        press(flow, cards, view.targets[1])
        request = talisman_target.request(flow, cards)
        assert(request.index == 1 and request.opts == nil)
    end

    -- Toggling and cancel stay inside UI state and never call talismans.use.
    assert(#cards == 3)
    view = talisman_target.view(convert, cards)
    assert(press(convert, cards, view.targets[3]) == "target")
    assert(convert.target_index == nil, "selected target toggles off")
    assert(press(convert, cards, view.cancel_bounds) == "cancel")
    assert(convert.cancelled and talisman_target.request(convert, cards) == nil)
    assert(#cards == 3, "UI selection cannot mutate target cards")

    local ok = pcall(talisman_target.new, 1, { effect = "unknown" })
    assert(not ok, "unknown talisman effects are rejected")
    print("  talisman_target_ui: OK")
end

return M