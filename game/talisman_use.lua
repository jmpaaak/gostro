-- game/talisman_use.lua
-- Controller for the modal held-talisman flow. Effect rules stay in talismans;
-- option/target layout stays in ui.talisman_target; scenes only delegate here.

local talismans = require("game.talismans")
local talisman_target_ui = require("game.ui.talisman_target")

local M = {}

local function close(scene)
    scene.talisman_target = nil
    scene.tarot_target = nil
    scene.selected_consumable = nil
end

function M.open(scene, slot)
    if scene.state ~= "playing" or not scene.round or not scene.round.hand then
        return false
    end
    local held = talismans.ensure(scene.run_state)[slot]
    if not held then return false end
    scene.selected_consumable = slot
    scene.talisman_target = talisman_target_ui.new(slot, held)
    scene.tarot_target = scene.talisman_target
    return true
end

--- Consume pointer input while open. The second return value reports a use so
--- the host scene can refresh presentation from the mutated engine hand.
function M.route_press(scene, x, y)
    local flow = scene.talisman_target or scene.tarot_target
    if not flow then return false, false end

    talisman_target_ui.activate(flow, scene.round.hand, x, y)
    if flow.cancelled then
        close(scene)
        return true, false
    end

    local request = talisman_target_ui.request(flow, scene.round.hand)
    if not request then return true, false end

    talismans.use(scene.run_state, request.slot, scene.round.hand,
        request.index, request.opts)
    close(scene)
    return true, true
end

function M.draw(scene)
    talisman_target_ui.draw(scene.talisman_target or scene.tarot_target,
        scene.round and scene.round.hand or {})
end

function M.close(scene)
    close(scene)
end

return M
