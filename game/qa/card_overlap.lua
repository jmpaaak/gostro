-- Deterministic 960x540 LÖVE render used to review play-card art.
local M = {}

local SPEC = {
    canvas_width = 960,
    canvas_height = 540,
    card_width = 72,
    card_height = 108,
    step = 30,
    top_visible_pixels = 30,
    x = 330,
    y = 216,
    card_order = { "pi", "hongdan", "cheongdan", "chodan", "godori" },
}

function M.spec()
    return SPEC
end

function M.draw(graphics, sheet)
    local sheet_width, sheet_height = sheet:getDimensions()
    assert(sheet_width == 360 and sheet_height == 108,
        "card QA requires the 360x108 Pixel Perfect contact sheet")
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
