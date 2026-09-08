-- game/ui/shop.lua
-- Shop UI: 3 gwang joker cards on display, reroll ($5), next round, money.

local terms = require("game.terms")
local pack_art = require("game.ui.pack_art")
local voucher_art = require("game.ui.voucher_art")

local M = {}

local VIEWPORT_W = 320
local VIEWPORT_H = 180

-- Gwang pool with prices
local GWANG_POOL = {
    { identity = "chips",     price = 6 },
    { identity = "mult",      price = 7 },
    { identity = "yaku_mult", price = 8 },
}

local GWANG_NAMES = {
    chips     = "칩 +30",
    mult      = "배수 +4",
    yaku_mult = "족보 ×1.5",
}

local VOUCHER_NAMES = {
    paint_brush = "붓", wasteful = "낭비", grabber = "그래버",
    overstock = "오버스톡", reroll_surplus = "리롤잉여",
    clearance_sale = "세일", seed_money = "시드머니",
    antimatter = "반물질", crystal_ball = "수정구", hone = "연마",
    directors_cut = "디렉터컷", money_tree = "머니트리",
}

M.REROLL_COST = 5

-- Card layout
local CARD_W = 36
local CARD_H = 52
local CARD_GAP = 10
local CARD_Y = 40

-- Buttons
M.BUTTON_W = 60
M.BUTTON_H = 18
M.REROLL_X = math.floor(VIEWPORT_W / 2 - M.BUTTON_W - 6)
M.REROLL_Y = CARD_Y + CARD_H + 14
M.NEXT_X   = math.floor(VIEWPORT_W / 2 + 6)
M.NEXT_Y   = M.REROLL_Y

local function shop_items(s)
    if s and s.slots then return s.slots end
    if s and s.cards then return s.cards end
    return { false, false, false }
end

--- Return centred display positions for every legacy or engine slot.
function M.card_positions(s)
    local count = #shop_items(s)
    local gap = count > 3 and 6 or CARD_GAP
    local width = math.min(CARD_W,
        math.floor((VIEWPORT_W - 16 - gap * math.max(0, count - 1))
            / math.max(1, count)))
    local total_w = count * width + math.max(0, count - 1) * gap
    local start_x = math.floor((VIEWPORT_W - total_w) / 2)
    local positions = {}
    for i = 1, count do
        positions[i] = {
            x = start_x + (i - 1) * (width + gap),
            y = CARD_Y,
            w = width,
            h = CARD_H,
        }
    end
    return positions
end

--- Pick a random item from the pool.
local function random_item()
    if math.random() < 0.3 then
        local planets = require("game.planets").all()
        local p = planets[math.random(1, #planets)]
        return {
            kind = "planet",
            yaku = p.yaku,
            identity = p.id,
            name = "행성: " .. (p.name or "Unknown"),
            price = 3,
            sold = false,
        }
    end
    
    local entry = GWANG_POOL[math.random(1, #GWANG_POOL)]
    return {
        kind     = "gwang",
        identity = entry.identity,
        price    = entry.price,
        sold     = false,
    }
end

--- Generate 3 fresh shop cards.
local function generate_cards()
    local cards = {}
    for i = 1, 3 do
        cards[i] = random_item()
    end
    return cards
end

--- Create a new shop state.
-- @param money  number  player's current money
function M.new(money)
    return {
        money = money or 0,
        cards = generate_cards(),
    }
end

--- Buy a card at index (1-3). Returns ok, card_data.
function M.buy_card(s, idx)
    if idx < 1 or idx > 3 then return false, nil end
    local card = s.cards[idx]
    if not card or card.sold then return false, nil end
    if s.money < card.price then return false, nil end
    s.money = s.money - card.price
    card.sold = true
    return true, { kind = card.kind, identity = card.identity, yaku = card.yaku }
end

--- Reroll: replace unsold cards, cost $5. Returns true on success.
function M.reroll(s)
    if s.money < M.REROLL_COST then return false end
    s.money = s.money - M.REROLL_COST
    for i = 1, 3 do
        if not s.cards[i].sold then
            s.cards[i] = random_item()
        end
    end
    return true
end

--- Can the player afford a reroll?
function M.can_reroll(s)
    local money = s.run_state and s.run_state.money or s.money
    return money >= M.reroll_cost(s)
end

function M.reroll_cost(s)
    if s.run_state then
        return require("game.shop_engine").reroll_cost(s)
    end
    return M.REROLL_COST
end

--- Money display text.
function M.money_text(s)
    local money = s.run_state and s.run_state.money or s.money
    return "$" .. tostring(money or 0)
end

local function item_label(item)
    if item.name then return item.name end
    if item.kind == "voucher" then
        return VOUCHER_NAMES[item.identity] or terms.domain.voucher
    end
    if item.kind == "pack" then return "카드 팩" end
    if item.kind == "tarot" then return terms.domain.tarot end
    if item.kind == "planet" then return terms.domain.planet end
    return GWANG_NAMES[item.identity] or "광"
end

--- Pure render model shared by drawing and hit-testing.
function M.slot_views(s)
    local items = shop_items(s)
    local positions = M.card_positions(s)
    local views = {}
    for i = 1, #items do
        views[i] = {
            index = i,
            item = items[i],
            bounds = positions[i],
            slot_type = items[i].slot_type or "random",
            label = item_label(items[i]),
        }
    end
    return views
end

--- Hit-test: returns "reroll", "next", card index (1-3), or nil.
function M.hit_test(s, px, py)
    -- Reroll button
    if px >= M.REROLL_X and px < M.REROLL_X + M.BUTTON_W
       and py >= M.REROLL_Y and py < M.REROLL_Y + M.BUTTON_H then
        return "reroll"
    end
    -- Next round button
    if px >= M.NEXT_X and px < M.NEXT_X + M.BUTTON_W
       and py >= M.NEXT_Y and py < M.NEXT_Y + M.BUTTON_H then
        return "next"
    end
    -- Item slots
    local views = M.slot_views(s)
    for i = 1, #views do
        local p = views[i].bounds
        if px >= p.x and px < p.x + p.w
           and py >= p.y and py < p.y + p.h then
            return i
        end
    end
    return nil
end

--- Draw shop UI (requires love.graphics).
function M.draw(s)
    if not love or not love.graphics then return end
    local font = love.graphics.getFont()
    local fh = font:getHeight()
    local views = M.slot_views(s)

    -- Title
    love.graphics.setColor(1, 0.9, 0.3, 1)
    local title = "상점"
    love.graphics.print(title,
        math.floor(VIEWPORT_W / 2 - font:getWidth(title) / 2), CARD_Y - 18)

    -- Money display (top right area)
    love.graphics.setColor(0.3, 1, 0.4, 1)
    local mtxt = M.money_text(s)
    love.graphics.print(mtxt, VIEWPORT_W - font:getWidth(mtxt) - 8, 6)

    -- Items
    for i = 1, #views do
        local view = views[i]
        local p = view.bounds
        local card = view.item

        if card and not card.sold then
            if card.kind == "planet" or card.kind == "tarot" then
                love.graphics.setColor(0.3, 0.4, 0.7, 1)
                love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 3, 3)
                love.graphics.setColor(0.5, 0.6, 1.0, 1)
                love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 3, 3)

                love.graphics.setColor(1, 1, 1, 1)
                local sym = "●"
                local sw = font:getWidth(sym)
                love.graphics.print(sym, p.x + math.floor((p.w - sw) / 2), p.y + 6)
                
                local nw = font:getWidth(view.label)
                love.graphics.setColor(0.9, 0.9, 1, 1)
                local scale = math.min(1, (p.w - 4) / math.max(1, nw))
                love.graphics.print(view.label,
                    p.x + math.floor((p.w - nw * scale) / 2),
                    p.y + 6 + fh + 2, 0, scale, scale)
            elseif card.kind == "pack" or card.kind == "voucher" then
                local is_voucher = card.kind == "voucher"
                local has_art = is_voucher
                    and voucher_art.draw(card, p.x, p.y, p.w, p.h)
                    or (not is_voucher and pack_art.draw(card, p.x, p.y, p.w, p.h))
                if has_art then
                    -- Manifest-backed shop art fills the complete offer.
                elseif is_voucher then
                    love.graphics.setColor(0.55, 0.2, 0.65, 1)
                else
                    love.graphics.setColor(0.5, 0.2, 0.25, 1)
                end
                if not has_art then
                    love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 3, 3)
                    love.graphics.setColor(0.9, 0.55, 1, 1)
                    love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 3, 3)
                    local nw = font:getWidth(view.label)
                    local scale = math.min(1, (p.w - 4) / math.max(1, nw))
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.print(view.label,
                        p.x + math.floor((p.w - nw * scale) / 2),
                        p.y + 12, 0, scale, scale)
                end
            else
                -- Card background (gwang gold)
                love.graphics.setColor(0.85, 0.7, 0.15, 1)
                love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 3, 3)
                love.graphics.setColor(1, 0.85, 0.2, 1)
                love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 3, 3)

                -- Star symbol
                love.graphics.setColor(1, 1, 1, 1)
                local sym = "★"
                local sw = font:getWidth(sym)
                love.graphics.print(sym,
                    p.x + math.floor((p.w - sw) / 2), p.y + 6)

                -- Name/effect
                local name = view.label
                local nw = font:getWidth(name)
                local scale = math.min(1, (p.w - 4) / math.max(1, nw))
                love.graphics.setColor(0.1, 0.05, 0, 1)
                love.graphics.print(name,
                    p.x + math.floor((p.w - nw * scale) / 2),
                    p.y + 6 + fh + 2, 0, scale, scale)
            end

            -- Price tag at bottom
            local ptxt = "$" .. tostring(card.price)
            local pw = font:getWidth(ptxt)
            love.graphics.setColor(0.2, 0.8, 0.3, 1)
            love.graphics.print(ptxt,
                p.x + math.floor((p.w - pw) / 2), p.y + p.h - fh - 4)
        else
            -- Sold / empty slot
            love.graphics.setColor(0.3, 0.3, 0.3, 0.4)
            love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 3, 3)
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
            local sold_txt = "SOLD"
            love.graphics.print(sold_txt,
                p.x + math.floor((p.w - font:getWidth(sold_txt)) / 2),
                p.y + math.floor((p.h - fh) / 2))
        end
    end

    -- Reroll button
    local can_rr = M.can_reroll(s)
    if can_rr then
        love.graphics.setColor(0.2, 0.5, 0.2, 0.9)
    else
        love.graphics.setColor(0.25, 0.25, 0.25, 0.9)
    end
    love.graphics.rectangle("fill", M.REROLL_X, M.REROLL_Y,
        M.BUTTON_W, M.BUTTON_H, 3, 3)
    love.graphics.setColor(0.4, 0.8, 0.4, 0.8)
    love.graphics.rectangle("line", M.REROLL_X, M.REROLL_Y,
        M.BUTTON_W, M.BUTTON_H, 3, 3)
    local rr_txt = "리롤 ($" .. tostring(M.reroll_cost(s)) .. ")"
    local rr_w = font:getWidth(rr_txt)
    love.graphics.setColor(1, 1, 1, can_rr and 1 or 0.4)
    love.graphics.print(rr_txt,
        M.REROLL_X + math.floor((M.BUTTON_W - rr_w) / 2),
        M.REROLL_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Next round button
    love.graphics.setColor(0.15, 0.35, 0.7, 0.9)
    love.graphics.rectangle("fill", M.NEXT_X, M.NEXT_Y,
        M.BUTTON_W, M.BUTTON_H, 3, 3)
    love.graphics.setColor(0.4, 0.6, 1, 0.8)
    love.graphics.rectangle("line", M.NEXT_X, M.NEXT_Y,
        M.BUTTON_W, M.BUTTON_H, 3, 3)
    local nx_txt = "다음 라운드"
    local nx_w = font:getWidth(nx_txt)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(nx_txt,
        M.NEXT_X + math.floor((M.BUTTON_W - nx_w) / 2),
        M.NEXT_Y + math.floor((M.BUTTON_H - fh) / 2))

    -- Reset colour
    love.graphics.setColor(1, 1, 1, 1)
end

return M
