-- Default play window is 960×540 (1× canvas). GAME_SCALE=2 is 1920×1080.

local M = {}

local function load_conf()
    local chunk = love.filesystem.load("conf.lua")
    assert(chunk, "conf.lua must be loadable")
    chunk()
    assert(type(love.conf) == "function", "conf.lua must define love.conf")
    return love.conf
end

local function with_env(overrides, fn)
    local original = os.getenv
    os.getenv = function(name)
        if overrides[name] ~= nil then
            local value = overrides[name]
            if value == false then return nil end
            return value
        end
        return original(name)
    end
    local ok, err = pcall(fn)
    os.getenv = original
    assert(ok, err)
end

local function new_t()
    return {
        window = {},
        modules = {},
    }
end

function M.run()
    local conf = load_conf()

    with_env({
        GAME_HEADLESS = false,
        GAME_QA = false,
        GOSTRO_LOOP = false,
        GAME_SCALE = false,
    }, function()
        local t = new_t()
        conf(t)
        assert(t.window ~= false, "play window is created outside headless/QA")
        assert(t.window.width == 960, "default window width is 960 (1x canvas)")
        assert(t.window.height == 540, "default window height is 540 (1x canvas)")
    end)

    with_env({
        GAME_HEADLESS = false,
        GAME_QA = false,
        GOSTRO_LOOP = false,
        GAME_SCALE = "2",
    }, function()
        local t = new_t()
        conf(t)
        assert(t.window.width == 1920, "GAME_SCALE=2 is integer 2x 1920")
        assert(t.window.height == 1080, "GAME_SCALE=2 is integer 2x 1080")
    end)

    with_env({ GAME_HEADLESS = "1" }, function()
        local t = new_t()
        conf(t)
        assert(t.window == false, "headless must not create a window")
    end)

    print("  window_conf: OK")
end

return M
