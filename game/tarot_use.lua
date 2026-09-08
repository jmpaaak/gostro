-- game/tarot_use.lua
-- Controller for the modal held-tarot use flow. Effect rules stay in tarots;
-- option/target layout stays in ui.tarot_target; scenes only delegate here.

local tarots = require("game.tarots")
local tarot_target_ui = require("game.ui.tarot_target")

local M = {}

local function close(scene)
    scene.tarot_target = nil
    scene.selected_consumable = nil
end

function M.open(scene, slot)
    if scene.state ~= "playing" or not scene.round or not scene.round.hand then
        return false
    end
    local held = scene.run_state.tarots and scene.run_state.tarots[slot]
    if not held then return false end
    scene.selected_consumable = slot
    scene.tarot_target = tarot_target_ui.new(slot, held)
    return true
end

--- Consume pointer input while open. The second return value reports a use so
--- the host scene can refresh presentation from the mutated engine hand.
function M.route_press(scene, x, y)
    local flow = scene.tarot_target
    if not flow then return false, false end

    tarot_target_ui.activate(flow, scene.round.hand, x, y)
    if flow.cancelled then
        close(scene)
        return true, false
    end

    local request = tarot_target_ui.request(flow, scene.round.hand)
    if not request then return true, false end

    tarots.use(scene.run_state, request.slot, scene.round.hand,
        request.index, request.opts)
    close(scene)
    return true, true
end

function M.draw(scene)
    tarot_target_ui.draw(scene.tarot_target,
        scene.round and scene.round.hand or {})
end

function M.close(scene)
    close(scene)
end

return M
