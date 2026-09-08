local rng = require("game.rng")

local M = {}

--- Assemble the mutable base state shared by every run configuration.
function M.new(seed_str)
    local plan = rng.plan(seed_str)
    local plaques = {
        owned = {},
        free_rerolls = 0,
        pending_money = 0,
        extra_shop_slots = 0,
        hand_size_bonus = 0,
    }
    local seals = {
        owned = {},
        hand_size = 0,
        discards = 0,
        hands = 0,
        shop_slots = 0,
        reroll_discount = 0,
        shop_discount = 0,
        interest_cap = 5,
        gwang_slots = 0,
        consumable_slots = 0,
        edition_rate = 1,
        boss_rerolls = 0,
        interest_rate = 0,
    }
    return {
        seed = plan.seed,
        rng = {
            shop = plan.shop,
            cards = plan.cards,
            boss = plan.boss,
        },
        ante = 1,
        blind = "small",
        phase = "play",
        round_score = 0,
        gwang = {},
        plaques = plaques,
        tags = plaques, -- legacy save/API alias
        seals = seals,
        vouchers = seals, -- legacy save/runtime alias
        boss_id = nil,
        boss = nil,
        money = 4,
        hands_left = 4,
    }
end

return M
