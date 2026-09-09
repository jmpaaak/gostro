local effects = require("game.ui.card_effects")

local M = {}

M.GWANG_BASE = 1

local PLAY_KINDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

local CHIPS = {
    hongdan = 10,
    cheongdan = 10,
    chodan = 10,
    godori = 20,
    pi = 1,
}

local NAMED_YAKU = { "hongdan", "cheongdan", "chodan", "godori" }

local YAKU_LABELS = {
    hongdan = "홍단",
    cheongdan = "청단",
    chodan = "초단",
    godori = "고도리",
    pi = "피",
}

function M.yaku_label(yaku)
    if type(yaku) ~= "table" or #yaku == 0 then
        return "바닥"
    end
    local parts = {}
    for i = 1, #yaku do
        parts[i] = YAKU_LABELS[yaku[i]] or yaku[i]
    end
    return table.concat(parts, "·")
end

function M.card(kind, extra)
    if kind == "gwang" then
        error("gwang is a joker slot, not a play card")
    end
    local effect = nil
    if extra ~= nil then
        if type(extra) ~= "table" then
            error("card extra must be a table")
        end
        if extra.month ~= nil or extra.month_name ~= nil then
            error("play cards have no month numbers or names")
        end
        if extra.effect ~= nil then
            if not effects.is_known(extra.effect) then
                error("unknown card effect: " .. tostring(extra.effect))
            end
            effect = extra.effect
        end
    end
    if not PLAY_KINDS[kind] then
        error("unknown play card kind: " .. tostring(kind))
    end
    return { kind = kind, effect = effect }
end

local function chips_for(hand)
    local chips = 0
    for i = 1, #hand do
        local card = hand[i]
        local kind = card.kind
        if kind == "gwang" then
            error("gwang is a joker slot, not a play card")
        end
        if not PLAY_KINDS[kind] then
            error("unknown play card kind: " .. tostring(kind))
        end
        if card.month ~= nil or card.month_name ~= nil then
            error("play cards have no month numbers or names")
        end
        chips = chips + CHIPS[kind]
    end
    return chips
end

function M.evaluate(hand, state)
    if type(hand) ~= "table" then
        error("hand must be a table")
    end
    if #hand > 5 then
        error("play at most 5 cards")
    end
    local counts = { hongdan = 0, cheongdan = 0, chodan = 0, godori = 0, pi = 0 }
    for i = 1, #hand do
        counts[hand[i].kind] = (counts[hand[i].kind] or 0) + 1
    end
    local chips = chips_for(hand)
    local yaku = {}
    local mult = 1
    for i = 1, #NAMED_YAKU do
        local kind = NAMED_YAKU[i]
        if counts[kind] >= 3 then
            yaku[#yaku + 1] = kind
            mult = 2
        end
    end
    if counts.pi >= 5 then
        yaku[#yaku + 1] = "pi"
    end
    
    if state then
        local planets = require("game.planets")
        chips, mult = planets.apply_level_bonus(state, yaku, chips, mult)
    end
    
    local extras
    chips, mult, extras = effects.apply_bonuses(hand, chips, mult)
    local gwang_triggers
    if state then
        local catalog = require("game.gwang_catalog")
        chips, mult, gwang_triggers = catalog.apply({
            chips = chips,
            mult = mult,
            yaku = yaku,
            hand = hand,
            state = state,
        })
    end
    return {
        yaku = yaku,
        chips = chips,
        mult = mult,
        score = chips * mult,
        effect_chips = extras.effect_chips,
        effect_mult_add = extras.effect_mult_add,
        effect_mult_mul = extras.effect_mult_mul,
        gwang_triggers = gwang_triggers,
    }
end

return M
