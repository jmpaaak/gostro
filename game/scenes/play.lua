-- game/scenes/play.lua
-- Play scene: state machine delegating to UI modules + engine.
-- States: blind_select → playing → scoring → shop → (next blind_select)
-- Keeps under 800 lines — pure delegation.

local run           = require("game.run")
local hwatu         = require("game.hwatu")
local hand_ui       = require("game.ui.hand")
local scoreboard_ui = require("game.ui.scoreboard")
local buttons_ui    = require("game.ui.action_buttons")
local shop_ui       = require("game.ui.shop")
local blind_sel_ui  = require("game.ui.blind_select")
local gwang_sl_ui   = require("game.ui.gwang_slots")
local planets_ui    = require("game.ui.planets_ui")

local M = {}
M.__index = M

-- Card kinds for dealing a random hand of 8
local PLAY_KINDS = { "hongdan", "cheongdan", "chodan", "godori", "pi" }

local function random_hand_kinds(n)
    local kinds = {}
    for i = 1, n do
        kinds[i] = PLAY_KINDS[math.random(1, #PLAY_KINDS)]
    end
    return kinds
end

--- Create a new play scene.
function M.new()
    local self = setmetatable({}, M)
    self.run_state   = run.new()
    self.state       = "blind_select"
    self.money       = 4  -- starting money

    -- UI modules (created on demand per state)
    self.blind_select = blind_sel_ui.new(self.run_state.ante)
    self.gwang_slots  = gwang_sl_ui.new()
    self.hand         = nil
    self.scoreboard   = nil
    self.buttons      = nil
    self.shop         = nil

    return self
end

--- Select a blind and transition to playing.
function M.select_blind(scene, idx)
    if scene.state ~= "blind_select" then return end
    blind_sel_ui.select_blind(scene.blind_select, idx)
    local kind = scene.blind_select.selected
    -- Sync run_state blind (it may already be correct from leave_shop)
    scene.run_state.blind = kind
    scene.run_state.phase = "play"
    scene.run_state.round_score = 0

    -- Create playing UI
    scene.hand = hand_ui.new()
    hand_ui.deal(scene.hand, random_hand_kinds(8))

    scene.scoreboard = scoreboard_ui.new()
    scoreboard_ui.set_target(scene.scoreboard, run.blind_target(scene.run_state))

    scene.buttons = buttons_ui.new()
    gwang_sl_ui.sync_from_run(scene.gwang_slots, scene.run_state.gwang)

    scene.state = "playing"
end

--- Play the selected hand cards through the engine.
function M.play_hand(scene)
    if scene.state ~= "playing" then return false end
    local selected = hand_ui.get_selected(scene.hand)
    if #selected == 0 then return false end
    if not buttons_ui.use_hand(scene.buttons) then return false end

    -- Build card list for hwatu evaluator
    local cards = {}
    for i, c in ipairs(selected) do
        cards[i] = hwatu.card(c.kind)
    end

    local result = hwatu.evaluate(cards)

    -- Apply gwang joker bonuses
    local bonus_chips = 0
    local bonus_mult  = 0
    for _, g in ipairs(scene.run_state.gwang) do
        if g.identity == "chips" then
            bonus_chips = bonus_chips + 30
        elseif g.identity == "mult" then
            bonus_mult = bonus_mult + 4
        elseif g.identity == "yaku_mult" and #result.yaku > 0 then
            result.mult = result.mult * 1.5
        end
    end

    local final_chips = result.chips + bonus_chips
    local final_mult  = result.mult + bonus_mult
    local score = math.floor(final_chips * final_mult)

    run.add_score(scene.run_state, score)
    scoreboard_ui.set_hand_result(scene.scoreboard, final_chips, final_mult)

    -- Remove played cards from hand and redeal into gaps
    local indices = {}
    for _, idx in ipairs(scene.hand.selected_order) do
        indices[idx] = true
    end
    local remaining = {}
    for i, c in ipairs(scene.hand.cards) do
        if not indices[i] then
            remaining[#remaining + 1] = c.kind
        end
    end
    -- Fill back to 8
    while #remaining < 8 do
        remaining[#remaining + 1] = PLAY_KINDS[math.random(1, #PLAY_KINDS)]
    end
    hand_ui.deal(scene.hand, remaining)

    return true
end

--- Discard selected cards and redraw.
function M.discard_hand(scene)
    if scene.state ~= "playing" then return false end
    local selected = hand_ui.get_selected(scene.hand)
    if #selected == 0 then return false end
    if not buttons_ui.use_discard(scene.buttons) then return false end

    -- Remove discarded cards and redeal
    local indices = {}
    for _, idx in ipairs(scene.hand.selected_order) do
        indices[idx] = true
    end
    local remaining = {}
    for i, c in ipairs(scene.hand.cards) do
        if not indices[i] then
            remaining[#remaining + 1] = c.kind
        end
    end
    while #remaining < 8 do
        remaining[#remaining + 1] = PLAY_KINDS[math.random(1, #PLAY_KINDS)]
    end
    hand_ui.deal(scene.hand, remaining)

    return true
end

--- Check if blind is cleared; if so, transition to shop.
function M.check_clear(scene)
    if scene.state ~= "playing" then return end
    local target = run.blind_target(scene.run_state)
    if scene.run_state.round_score >= target then
        if scene.buttons then
            scene.run_state.hands_left = scene.buttons.hands_left
        end
        run.clear_blind(scene.run_state)
        if scene.run_state.phase == "won" then
            scene.state = "won"
            return
        end
        scene.money = scene.run_state.money
        scene.shop = shop_ui.new(scene.money)
        scene.state = "shop"
    end
end

--- Leave the shop and go to next blind select.
function M.leave_shop(scene)
    if scene.state ~= "shop" then return end
    scene.money = scene.shop.money
    scene.run_state.money = scene.money
    run.leave_shop(scene.run_state)
    scene.blind_select = blind_sel_ui.new(scene.run_state.ante)
    gwang_sl_ui.sync_from_run(scene.gwang_slots, scene.run_state.gwang)
    scene.state = "blind_select"
end

--- Buy a card from the shop.
function M.buy_shop_card(scene, idx)
    if scene.state ~= "shop" then return false end
    local ok, card_data = shop_ui.buy_card(scene.shop, idx)
    if not ok then return false end
    
    if card_data.kind == "planet" then
        local planets = require("game.planets")
        planets.buy(scene.run_state, card_data.yaku)
        return true
    end

    -- Add to run state (gwang)
    local success = pcall(run.buy_gwang, scene.run_state, card_data)
    if success then
        gwang_sl_ui.sync_from_run(scene.gwang_slots, scene.run_state.gwang)
    else
        -- revert
        scene.shop.money = scene.shop.money + (card_data.price or 0)
        scene.shop.cards[idx].sold = false
        return false
    end
    return true
end

--- Update (tick animations).
function M:update(dt)
    if self.state == "playing" and self.scoreboard then
        scoreboard_ui.update(self.scoreboard, dt)
        -- Update button enabled state based on selection
        buttons_ui.set_selection(self.buttons, #self.hand.selected_order)
    end
end

--- Draw current state's UI modules.
function M:draw()
    if not love or not love.graphics then return end
    love.graphics.clear(0.025, 0.035, 0.08)

    -- Gwang slots always visible at top
    gwang_sl_ui.draw(self.gwang_slots)
    planets_ui.draw(self.run_state)

    if self.state == "blind_select" then
        blind_sel_ui.draw(self.blind_select)

    elseif self.state == "playing" then
        hand_ui.draw(self.hand)
        scoreboard_ui.draw(self.scoreboard)
        buttons_ui.draw(self.buttons)

    elseif self.state == "shop" then
        shop_ui.draw(self.shop)

    elseif self.state == "won" then
        love.graphics.setColor(1, 0.9, 0.3, 1)
        love.graphics.print("승리!", 130, 80)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

--- Handle mouse/touch press.
function M:mousepressed(px, py)
    if self.state == "blind_select" then
        local idx = blind_sel_ui.hit_test(self.blind_select, px, py)
        if idx then
            M.select_blind(self, idx)
        end

    elseif self.state == "playing" then
        -- Check action buttons first
        local btn = buttons_ui.hit_test(self.buttons, px, py)
        if btn == "play" then
            if M.play_hand(self) then
                M.check_clear(self)
            end
        elseif btn == "discard" then
            M.discard_hand(self)
        else
            -- Check hand cards
            local idx = hand_ui.hit_test(self.hand, px, py)
            if idx then
                hand_ui.toggle(self.hand, idx)
                buttons_ui.set_selection(self.buttons, #self.hand.selected_order)
            end
        end

    elseif self.state == "shop" then
        local hit = shop_ui.hit_test(self.shop, px, py)
        if hit == "next" then
            M.leave_shop(self)
        elseif hit == "reroll" then
            shop_ui.reroll(self.shop)
        elseif type(hit) == "number" then
            M.buy_shop_card(self, hit)
        end
    end
end

--- Handle key press.
function M:keypressed(key)
    if self.state == "playing" then
        local action = buttons_ui.keypressed(self.buttons, key)
        if action == "play" then
            if M.play_hand(self) then
                M.check_clear(self)
            end
        elseif action == "discard" then
            M.discard_hand(self)
        end
    end
end

return M
