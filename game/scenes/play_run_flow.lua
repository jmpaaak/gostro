-- Run lifecycle helpers shared by play-scene entry points.

local M = {}

function M.restart(scene, create_scene)
    local replacement = create_scene(scene.run_config)
    local keys = {}
    for key in pairs(scene) do keys[#keys + 1] = key end
    for _, key in ipairs(keys) do scene[key] = nil end
    for key, value in pairs(replacement) do scene[key] = value end
    return scene
end

return M
