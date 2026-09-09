local fonts = require("game.fonts")

local M = {}

local function fake_graphics()
    local created = {}
    local selected
    local graphics = {}

    function graphics.newFont(path, size)
        local font = {
            path = path,
            size = size,
            getWidth = function(_, text) return #text * size end,
            hasGlyphs = function(_, text) return text ~= "" end,
        }
        created[#created + 1] = font
        return font
    end

    function graphics.setFont(font)
        selected = font
    end

    return graphics, created, function() return selected end
end

function M.run()
    assert(love.filesystem.getInfo("assets/fonts/Galmuri11.ttf", "file"))
    assert(love.filesystem.getInfo("assets/fonts/Galmuri-OFL.txt", "file"))

    local graphics, created, selected = fake_graphics()
    fonts.reset()
    local default = fonts.install(graphics)
    assert(default == selected())
    assert(default.path == "assets/fonts/Galmuri11.ttf")
    assert(default.size == 33)
    assert(fonts.get(33, graphics) == default, "font sizes must be cached")
    assert(fonts.get(22, graphics).size == 22)
    assert(#created == 2)

    for _, text in ipairs({ "상점", "다음 라운드", "광" }) do
        assert(default:getWidth(text) > 0)
        assert(default:hasGlyphs(text))
    end

    print("  fonts: OK")
end

function M.run_actual()
    M.run()
    fonts.reset()
    local font = fonts.install()
    for _, text in ipairs({ "상점", "다음 라운드", "광" }) do
        assert(font:getWidth(text) > 0, text .. " must have a rendered width")
        assert(font:hasGlyphs(text), text .. " glyphs must exist in Galmuri11")
    end
    print("  fonts (Galmuri11 glyphs): OK")
end

return M