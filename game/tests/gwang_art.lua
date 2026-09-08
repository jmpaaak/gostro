-- Engine-hosted tests for optional catalog image data URLs in gwang slots.

local art = require("game.ui.gwang_art")

local M = {}

local DATA_URL = "data:image/png;base64,aW1hZ2UtYnl0ZXM="
local REAL_PNG = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg=="

local function fake_api()
    local calls = { decode = 0, file = 0, image = 0, draw = 0, scissors = {} }
    local texture = {
        getWidth = function() return 100 end,
        getHeight = function() return 200 end,
        setFilter = function(_, min, mag)
            calls.filter = { min, mag }
        end,
    }
    local api = {
        decode_base64 = function(payload)
            calls.decode = calls.decode + 1
            calls.payload = payload
            return "decoded-bytes"
        end,
        new_file_data = function(bytes, filename)
            calls.file = calls.file + 1
            calls.file_args = { bytes, filename }
            return "file-data"
        end,
        new_image = function(file_data)
            calls.image = calls.image + 1
            calls.image_arg = file_data
            return texture
        end,
        get_scissor = function()
            return 1, 2, 3, 4
        end,
        set_scissor = function(...)
            calls.scissors[#calls.scissors + 1] = { ... }
        end,
        draw = function(...)
            calls.draw = calls.draw + 1
            calls.draw_args = { ... }
        end,
    }
    return api, calls, texture
end

function M.run()
    art.clear_cache()
    local api, calls, texture = fake_api()
    local lookup = function(id)
        assert(id == "custom")
        return { id = id, image = DATA_URL }
    end

    local loaded = art.texture_for({ identity = "custom" }, api, lookup)
    assert(loaded == texture, "data URL becomes a LÖVE image")
    assert(calls.decode == 1 and calls.payload == "aW1hZ2UtYnl0ZXM=")
    assert(calls.file_args[1] == "decoded-bytes")
    assert(calls.file_args[2]:match("%.png$"), "FileData keeps the image extension")
    assert(calls.image_arg == "file-data")
    assert(calls.filter[1] == "linear" and calls.filter[2] == "linear")

    local cached = art.texture_for({ identity = "custom" }, api, lookup)
    assert(cached == texture and calls.decode == 1, "textures are cached by data URL")

    local missing = art.texture_for({ identity = "plain" }, api, function()
        return { id = "plain" }
    end)
    assert(missing == nil and calls.decode == 1, "catalog entries without image keep the fallback")

    local invalid = art.texture_for({ identity = "bad" }, api, function()
        return { id = "bad", image = "https://example.invalid/card.png" }
    end)
    assert(invalid == nil and calls.decode == 1, "only embedded image data URLs are decoded")

    local drawn = art.draw({ identity = "custom" }, { x = 10, y = 20, w = 40, h = 20 }, api, lookup)
    assert(drawn == true and calls.draw == 1)
    local args = calls.draw_args
    assert(args[1] == texture)
    assert(args[2] == 10 and args[3] == -10, "portrait art is center-cropped in the slot")
    assert(args[5] == 0.4 and args[6] == 0.4, "cover scale preserves aspect ratio")
    assert(#calls.scissors == 2)
    assert(calls.scissors[1][1] == 10 and calls.scissors[1][2] == 20)
    assert(calls.scissors[1][3] == 40 and calls.scissors[1][4] == 20)
    assert(calls.scissors[2][1] == 1 and calls.scissors[2][4] == 4, "previous scissor is restored")

    -- Exercise LÖVE's real base64 -> FileData -> image decode pipeline. Headless
    -- verification disables the GPU graphics module, so ImageData stands in here.
    art.clear_cache()
    local real_api = {
        decode_base64 = function(payload)
            return love.data.decode("string", "base64", payload)
        end,
        new_file_data = function(bytes, filename)
            return love.filesystem.newFileData(bytes, filename)
        end,
        new_image = function(file_data)
            return love.image.newImageData(file_data)
        end,
    }
    local real = art.texture_for({ identity = "real" }, real_api, function()
        return { id = "real", image = REAL_PNG }
    end)
    assert(real and real:typeOf("ImageData"), "real LÖVE APIs decode embedded PNG artwork")
    assert(real:getWidth() == 1 and real:getHeight() == 1)

    print("  gwang_art: OK")
end

return M