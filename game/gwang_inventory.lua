local M = {}

M.MAX_SLOTS = 5

local PLAY_CARDS = {
    hongdan = true,
    cheongdan = true,
    chodan = true,
    godori = true,
    pi = true,
}

function M.max_slots(state)
    local extra = 0
    local upgrades = state.seals or state.vouchers
    if upgrades then
        extra = upgrades.gwang_slots or 0
    end
    return M.MAX_SLOTS + extra
end

function M.buy(state, card)
    if state.phase ~= "shop" then
        error("buy gwang only in the shop")
    end
    if type(card) ~= "table" then
        error("gwang must be a table")
    end
    if card.kind ~= nil and card.kind ~= "gwang" then
        error("gwang slots reject play cards")
    end
    if PLAY_CARDS[card.kind] then
        error("gwang slots reject play cards")
    end
    if card.identity == nil or card.identity == "" then
        error("each gwang has one identity")
    end
    if #state.gwang >= M.max_slots(state) then
        error("max gwang joker slots reached")
    end

    local inserted = {
        kind = "gwang",
        identity = card.identity,
    }
    state.gwang[#state.gwang + 1] = inserted
    return inserted
end

return M