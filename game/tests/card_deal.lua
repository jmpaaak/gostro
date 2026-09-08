local card_deal = require("game.card_deal")
local run = require("game.run")

local M = {}

function M.run()
    local picks = { 1, 5, 2, 4, 3 }
    local calls = 0
    local state = {
        rng = {
            cards = function(first, last)
                calls = calls + 1
                assert(first == 1 and last == 5, "deal indexes only the five play-card kinds")
                return picks[calls]
            end,
        },
    }

    local kinds = card_deal.deal(state, 5)
    assert(table.concat(kinds, ",") == "hongdan,pi,cheongdan,godori,chodan")
    assert(calls == 5, "one cards-stream draw per dealt card")

    local default_calls = 0
    local default_hand = card_deal.deal({ rng = { cards = function()
        default_calls = default_calls + 1
        return 1
    end } })
    assert(#default_hand == 8 and default_calls == 8, "default hand has eight cards")

    local original_deal = card_deal.deal
    card_deal.deal = function(delegated_state, delegated_count)
        assert(delegated_state == state and delegated_count == 12)
        return { "pi" }
    end
    local delegated = run.deal_kinds(state, 12)
    card_deal.deal = original_deal
    assert(#delegated == 1 and delegated[1] == "pi",
        "run.deal_kinds is a compatibility delegate")

    print("  card_deal: OK")
end

return M
