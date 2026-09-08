-- game/shop_purchases.lua
local shop_engine = require("game.shop_engine")
local wish_cards = require("game.wish_cards")
local tarots = require("game.tarots")
local packs = require("game.packs")
local run = require("game.run")

local M = {}

--- Attempt to purchase and apply a shop slot item.
-- Performs the transaction through the shop_engine, attempts to apply the item,
-- and rolls back the transaction if the application fails.
function M.buy(shop, slot_or_index)
    local ok, transaction = shop_engine.purchase(shop, slot_or_index)
    if not ok then return false end

    local card_data = transaction.item
    local success = pcall(function()
        if card_data.kind == "wish_card" or card_data.kind == "planet" then
            wish_cards.buy(shop.run_state, card_data.yaku or card_data.identity)
        elseif card_data.kind == "tarot" then
            tarots.gain(shop.run_state, card_data.identity, "shop")
        elseif card_data.kind == "gwang" then
            run.buy_gwang(shop.run_state, card_data)
        elseif card_data.kind == "voucher" then
            run.buy_voucher(shop.run_state, card_data.identity)
        elseif card_data.kind == "pack" then
            packs.open(shop.run_state, card_data.identity)
        else
            error("unsupported shop offer: " .. tostring(card_data.kind))
        end
    end)

    if success then
        return true, transaction
    else
        -- Rollback
        shop.run_state.money = shop.run_state.money + transaction.price
        transaction.slot.sold = false
        return false
    end
end

return M
