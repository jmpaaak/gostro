local M = {}

local ORDER = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

local WISH_CARD_DEFS = {
    hongdan = {
        id = "wish_card_hongdan", legacy_id = "planet_hongdan",
        name = "붉은 띠의 기원", symbol = "홍", yaku = "hongdan",
        level_chips = 15, level_mult = 1,
    },
    cheongdan = {
        id = "wish_card_cheongdan", legacy_id = "planet_cheongdan",
        name = "푸른 띠의 기원", symbol = "청", yaku = "cheongdan",
        level_chips = 15, level_mult = 1,
    },
    chodan = {
        id = "wish_card_chodan", legacy_id = "planet_chodan",
        name = "풀빛 띠의 기원", symbol = "초", yaku = "chodan",
        level_chips = 15, level_mult = 1,
    },
    godori = {
        id = "wish_card_godori", legacy_id = "planet_godori",
        name = "세 새의 기원", symbol = "새", yaku = "godori",
        level_chips = 30, level_mult = 2,
    },
    pi = {
        id = "wish_card_pi", legacy_id = "planet_pi",
        name = "피 모으기의 기원", symbol = "피", yaku = "pi",
        level_chips = 10, level_mult = 1,
    },
}

local function resolve_yaku(value)
    if WISH_CARD_DEFS[value] then return value end
    for _, yaku in ipairs(ORDER) do
        local definition = WISH_CARD_DEFS[yaku]
        if value == definition.id or value == definition.legacy_id then
            return yaku
        end
    end
    return value
end

function M.get_level(state, yaku)
    yaku = resolve_yaku(yaku)
    if not state.hands then
        return 1
    end
    return state.hands[yaku] and state.hands[yaku].level or 1
end

function M.buy(state, yaku)
    yaku = resolve_yaku(yaku)
    local definition = WISH_CARD_DEFS[yaku]
    if not definition then
        error("unknown wish card: " .. tostring(yaku))
    end
    if not state.hands then
        state.hands = {}
    end
    if not state.hands[yaku] then
        state.hands[yaku] = { level = 1 }
    end
    state.hands[yaku].level = state.hands[yaku].level + 1
    return definition
end

function M.apply_level_bonus(state, yaku_list, chips, mult)
    if not state.hands then
        return chips, mult
    end
    for i = 1, #yaku_list do
        local yaku = resolve_yaku(yaku_list[i])
        local definition = WISH_CARD_DEFS[yaku]
        if definition then
            local level = M.get_level(state, yaku)
            if level > 1 then
                local extra_levels = level - 1
                chips = chips + (definition.level_chips * extra_levels)
                mult = mult + (definition.level_mult * extra_levels)
            end
        end
    end
    return chips, mult
end

function M.by_id(id)
    local yaku = resolve_yaku(id)
    return WISH_CARD_DEFS[yaku]
end

function M.all()
    local list = {}
    for _, yaku in ipairs(ORDER) do
        list[#list + 1] = WISH_CARD_DEFS[yaku]
    end
    return list
end

return M
