local M = {}

local PLANET_DEFS = {
    hongdan = { id = "planet_hongdan", name = "주작 기원패", yaku = "hongdan", level_chips = 15, level_mult = 1 },
    cheongdan = { id = "planet_cheongdan", name = "청룡 기원패", yaku = "cheongdan", level_chips = 15, level_mult = 1 },
    chodan = { id = "planet_chodan", name = "백호 기원패", yaku = "chodan", level_chips = 15, level_mult = 1 },
    godori = { id = "planet_godori", name = "현무 기원패", yaku = "godori", level_chips = 30, level_mult = 2 },
    pi = { id = "planet_pi", name = "황룡 기원패", yaku = "pi", level_chips = 10, level_mult = 1 },
}

function M.get_level(state, yaku)
    if not state.hands then
        return 1
    end
    return state.hands[yaku] and state.hands[yaku].level or 1
end

function M.buy(state, yaku)
    if not state.hands then
        state.hands = {}
    end
    if not state.hands[yaku] then
        state.hands[yaku] = { level = 1 }
    end
    state.hands[yaku].level = state.hands[yaku].level + 1
    return PLANET_DEFS[yaku]
end

function M.apply_level_bonus(state, yaku_list, chips, mult)
    if not state.hands then
        return chips, mult
    end
    for i = 1, #yaku_list do
        local y = yaku_list[i]
        local def = PLANET_DEFS[y]
        if def then
            local lvl = M.get_level(state, y)
            if lvl > 1 then
                local extra_levels = lvl - 1
                chips = chips + (def.level_chips * extra_levels)
                mult = mult + (def.level_mult * extra_levels)
            end
        end
    end
    return chips, mult
end

function M.all()
    local list = {}
    for _, def in pairs(PLANET_DEFS) do
        list[#list + 1] = def
    end
    return list
end

return M
