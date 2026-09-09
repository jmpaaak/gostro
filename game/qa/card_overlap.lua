-- Deterministic 320x180 LÖVE render used to review candidate play-card art.
local M = {}

local SPEC = {
    canvas_width = 320,
    canvas_height = 180,
    card_width = 48,
    card_height = 72,
    step = 20,
    top_visible_pixels = 20,
    x = 80,
    y = 54,
    card_order = { "pi", "hongdan", "cheongdan", "chodan", "godori" },
}

function M.spec()
    return SPEC
end

function M.draw(graphics, sheet)
    local sheet_width, sheet_height = sheet:getDimensions()
    assert(sheet_width == 240 and sheet_height == 72,
        "card QA requires the 240x72 Pixel Perfect contact sheet")
    sheet:setFilter("nearest", "nearest")
    for index = 1, #SPEC.card_order do
        local quad = graphics.newQuad(
            (index - 1) * SPEC.card_width, 0,
            SPEC.card_width, SPEC.card_height,
            sheet_width, sheet_height
        )
        graphics.draw(sheet, quad, SPEC.x + (index - 1) * SPEC.step, SPEC.y)
    end
end

return M
