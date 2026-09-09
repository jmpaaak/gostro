-- game/scenes/play.lua

local run_rules     = require("game.run_rules")
local blind_flow    = require("game.blind_flow")
local round_engine  = require("game.round_engine")
local scoring       = require("game.scoring_pipeline")
local shop_engine   = require("game.shop_engine")
local packs         = require("game.packs")
local planets       = require("game.planets")
local shop_purchases = require("game.shop_purchases")
local hand_ui       = require("game.ui.hand")
local scoreboard_ui = require("game.ui.scoreboard")
local buttons_ui    = require("game.ui.action_buttons")
local shop_ui       = require("game.ui.shop")
local shop_fly      = require("game.ui.shop_fly")
local pack_ui       = require("game.ui.pack")
local round_hud     = require("game.ui.round_hud")
local blind_sel_ui  = require("game.ui.blind_select")
local gwang_sl_ui   = require("game.ui.gwang_slots")
local planets_ui    = require("game.ui.planets_ui")
local seed_ui       = require("game.ui.seed")
local consumables_ui = require("game.ui.consumables")
local tarot_use      = require("game.tarot_use")
local scene_bg       = require("game.ui.scene_bg")
local effect_art     = require("game.ui.effect_art")
local score_anim_ui  = require("game.ui.score_anim")
local play_hand_flow = require("game.scenes.play_hand_flow")

local M = {}
M.__index = M

local function normalize_config(value)
    if type(value) == "table" then
        return {
            starting_deck_id = value.starting_deck_id or value.deck_id or "hwatu",
            stake_id = value.stake_id or "white",
            seeded = value.seeded == true,
            seed = value.seed,
            unlocks = value.unlocks,
        }
    end
    return {
        starting_deck_id = "hwatu",
        stake_id = "white",
        seeded = type(value) == "string" and value ~= "",
        seed = value,
    }
end

local function configured_run(config)
    local state, reason = run_rules.create(config, config.unlocks)
    return assert(state, reason)
end

local function blind_selection_for(state)
    return blind_sel_ui.new(blind_flow.view(state))
end

local function sync_round_ui(scene)
    hand_ui.deal(scene.hand, scene.round.hand)
    scene.buttons.hands_left = scene.round.hands_left
    scene.buttons.discards_left = scene.round.discards_left
    buttons_ui.set_selection(scene.buttons, 0)
    M.sync_preview(scene)
end

local function sync_shop_ui(scene)
    scene.shop.cards = scene.shop.random_offers
    scene.shop.money = scene.run_state.money
    scene.money = scene.run_state.money
    shop_ui.sync_money(scene.shop)
end

--- Create a new play scene. Optional seed string (display + input).
function M.new(seed_or_config)
    local self = setmetatable({}, M)
    self.run_config  = normalize_config(seed_or_config)
    self.run_state   = configured_run(self.run_config)
    self.state       = "blind_select"
    self.money       = self.run_state.money

    self.blind_select = blind_selection_for(self.run_state)
    self.gwang_slots  = gwang_sl_ui.new()
    self.seed         = seed_ui.new(self.run_state.seed)
    self.hand         = nil
    self.scoreboard   = nil
    self.buttons      = nil
    self.shop         = nil
    self.round        = nil
    self.selected_consumable = nil
    self.tarot_target = nil
    return self
end

--- Apply a typed seed: restart the run from that seed string.
function M.apply_seed(scene, seed_str)
    scene.run_config.seeded = true
    scene.run_config.seed = seed_str
    scene.run_state   = configured_run(scene.run_config)
    scene.state       = "blind_select"
    scene.money       = scene.run_state.money
    scene.blind_select = blind_selection_for(scene.run_state)
    scene.gwang_slots  = gwang_sl_ui.new()
    seed_ui.set_seed(scene.seed, scene.run_state.seed)
    scene.hand        = nil
    scene.scoreboard  = nil
    scene.buttons     = nil
    scene.shop        = nil
    scene.round       = nil
    scene.selected_consumable = nil
    scene.tarot_target = nil
    return scene.run_state.seed
end

--- Select a blind and transition to playing.
function M.select_blind(scene, idx)
    if scene.state ~= "blind_select" then return end
    blind_sel_ui.select_blind(scene.blind_select, idx)
    local kind = scene.blind_select.selected
    local blind = blind_flow.begin(scene.run_state, kind)
    local target = blind.target
    scene.round = round_engine.new(scene.run_state, scene.run_state.deck, {
        target = target,
        discards = blind.discards,
    })

    -- Create playing UI
    scene.hand = hand_ui.new()
    hand_ui.deal(scene.hand, scene.round.hand)

    scene.scoreboard = scoreboard_ui.new()
    scoreboard_ui.set_target(scene.scoreboard, target)

    scene.buttons = buttons_ui.new(scene.round.hands_left, scene.round.discards_left)
    scene.score_anim = score_anim_ui.new()
    play_hand_flow.reset(scene)
    gwang_sl_ui.sync_from_run(scene.gwang_slots, scene.run_state.gwang)
    M.sync_preview(scene)

    scene.state = "playing"
end

--- Prospective chips x mult for the current selection. Safe to call on empty hands.
function M.sync_preview(scene)
    if not scene.scoreboard then return end
    if not scene.hand then
        scoreboard_ui.set_preview(scene.scoreboard, nil)
        return
    end
    scoreboard_ui.set_preview(
        scene.scoreboard,
        scoring.preview(hand_ui.get_selected(scene.hand), scene.run_state))
end

--- Play the selected hand cards through the engine.
function M.play_hand(scene)
    return play_hand_flow.play_hand(scene, M.sync_preview)
end

--- Discard selected cards and redraw after they slide off to the right.
function M.discard_hand(scene)
    return play_hand_flow.discard_hand(scene, M.sync_preview)
end

--- Check if blind is cleared; if so, transition to shop.
function M.check_clear(scene)
    if scene.state ~= "playing" then return end
    local hands_left = scene.round and scene.round.hands_left or nil
    local phase = blind_flow.clear(scene.run_state, hands_left)
    if not phase then return end
    if phase == "won" then
        scene.state = "won"
        return
    end
    scene.shop = shop_engine.new(scene.run_state)
    sync_shop_ui(scene)
    scene.round = nil
    scene.state = "shop"
end

--- Leave the shop and go to next blind select.
function M.leave_shop(scene)
    if scene.state ~= "shop" then return end
    scene.money = scene.run_state.money
    blind_flow.leave_shop(scene.run_state)
    scene.blind_select = blind_selection_for(scene.run_state)
    gwang_sl_ui.sync_from_run(scene.gwang_slots, scene.run_state.gwang)
    scene.state = "blind_select"
end

--- Reroll the live engine shop, including tag/voucher modifiers.
function M.reroll_shop(scene)
    if scene.state ~= "shop" then return false end
    local ok, paid = shop_engine.reroll(scene.shop)
    if ok then sync_shop_ui(scene) end
    return ok, paid
end

--- Buy a card from the shop.
function M.buy_shop_card(scene, idx)
    if scene.state ~= "shop" then return false end
    local views = shop_ui.slot_views(scene.shop)
    local item = views[idx] and views[idx].item
    local kind = item and item.kind
    local ok = shop_purchases.buy(scene.shop, idx)
    if ok then
        gwang_sl_ui.sync_from_run(scene.gwang_slots, scene.run_state.gwang)
        shop_ui.mark_bought(scene.shop, idx)
        local dest = shop_fly.destination(kind, scene.run_state, scene.gwang_slots)
        shop_fly.start(scene.shop, idx, dest)
    end
    sync_shop_ui(scene)
    return ok
end

--- Update (tick animations).
function M:update(dt)
    if self.state == "playing" and self.scoreboard then
        play_hand_flow.tick(self, dt, {
            sync_round_ui = sync_round_ui,
            check_clear = M.check_clear,
            sync_preview = M.sync_preview,
        })
    elseif self.state == "shop" and self.shop then
        shop_ui.update(self.shop, dt)
        shop_fly.update(self.shop, dt)
    end
end

--- Draw current state's UI modules.
function M:draw()
    if not love or not love.graphics then return end
    if self.state == "shop" then
        scene_bg.draw("shop")
    else
        scene_bg.draw("play")
    end

    gwang_sl_ui.draw(self.gwang_slots)
    planets_ui.draw(self.run_state)
    seed_ui.draw(self.seed)
    consumables_ui.draw(self.run_state, self.selected_consumable)

    if self.state == "blind_select" then
        blind_sel_ui.draw(self.blind_select)

    elseif self.state == "playing" then
        hand_ui.draw(self.hand)
        scoreboard_ui.draw(self.scoreboard)
        buttons_ui.draw(self.buttons)
        round_hud.draw(self.run_state, self.round)
        if self.score_anim then
            score_anim_ui.draw(self.score_anim, self.hand and self.hand.cards)
            score_anim_ui.draw_gwang_glow(self.score_anim)
        end

    elseif self.state == "shop" then
        shop_ui.draw(self.shop)
        pack_ui.draw(self.run_state.pending_pack)
        shop_fly.draw(self.shop)

    elseif self.state == "won" then
        if not effect_art.draw_win(0, 0) then
            love.graphics.setColor(1, 0.9, 0.3, 1)
            love.graphics.print("승리!", 130, 80)
            love.graphics.setColor(1, 1, 1, 1)
        end
    elseif self.state == "lost" then
        if not effect_art.draw_loss(0, 0) then
            love.graphics.setColor(0.95, 0.35, 0.35, 1)
            love.graphics.print("패배", 136, 74)
            love.graphics.setColor(0.75, 0.82, 0.84, 1)
            love.graphics.print("목표 점수에 도달하지 못했습니다", 72, 92)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    tarot_use.draw(self)
end

--- Handle mouse/touch press.
function M:mousepressed(px, py)
    if self.state == "shop" and self.run_state.pending_pack then
        local hit = pack_ui.hit_test(self.run_state.pending_pack, px, py)
        if type(hit) == "number" then
            packs.choose(self.run_state, hit)
        elseif hit == "skip" then
            packs.skip(self.run_state)
        end
        return
    end
    local modal, used_tarot = tarot_use.route_press(self, px, py)
    if used_tarot then sync_round_ui(self) end
    if modal then return end
    if consumables_ui.route_press(self, px, py) then
        if self.selected_consumable then
            tarot_use.open(self, self.selected_consumable)
        end
        return
    end
    if seed_ui.hit_test(self.seed, px, py) == "field" then
        seed_ui.focus(self.seed)
        return
    elseif self.seed.focused then
        seed_ui.unfocus(self.seed)
    end

    if self.state == "blind_select" then
        local idx = blind_sel_ui.hit_test(self.blind_select, px, py)
        if idx then
            M.select_blind(self, idx)
        end

    elseif self.state == "playing" then
        local btn = buttons_ui.hit_test(self.buttons, px, py)
        if btn == "play" then
            if M.play_hand(self) then
                M.check_clear(self)
            end
        elseif btn == "discard" then
            M.discard_hand(self)
        else
            local idx = hand_ui.hit_test(self.hand, px, py)
            if idx then
                hand_ui.toggle(self.hand, idx)
                buttons_ui.set_selection(self.buttons, #self.hand.selected_order)
                M.sync_preview(self)
            end
        end

    elseif self.state == "shop" then
        local hit = shop_ui.hit_test(self.shop, px, py)
        if hit == "next" then
            M.leave_shop(self)
        elseif hit == "reroll" then
            M.reroll_shop(self)
        elseif type(hit) == "number" then
            M.buy_shop_card(self, hit)
        end
    end
end

function M:mousemoved(px, py)
    if px == nil or py == nil then
        if self.hand then hand_ui.set_hover(self.hand, nil) end
        if self.shop then shop_ui.set_hover(self.shop, nil) end
        if self.blind_select then self.blind_select.hover = nil end
        if self.gwang_slots then self.gwang_slots.hover = nil end
        if self.buttons then self.buttons.hover = nil end
        if self.run_state and self.run_state.pending_pack then
            self.run_state.pending_pack.hover = nil
        end
        self.consumable_hover = nil
        return
    end
    if self.gwang_slots then
        gwang_sl_ui.set_hover_at(self.gwang_slots, px, py)
    end
    self.consumable_hover = consumables_ui.set_hover_at(self.run_state, px, py)
    if self.state == "playing" then
        if self.hand then hand_ui.set_hover_at(self.hand, px, py) end
        if self.buttons then buttons_ui.set_hover_at(self.buttons, px, py) end
    elseif self.state == "shop" then
        if self.run_state.pending_pack then
            pack_ui.set_hover_at(self.run_state.pending_pack, px, py)
        elseif self.shop then
            shop_ui.set_hover_at(self.shop, px, py)
        end
    elseif self.state == "blind_select" and self.blind_select then
        blind_sel_ui.set_hover_at(self.blind_select, px, py)
    end
end

--- Handle key press.
function M:keypressed(key)
    if self.tarot_target then return end
    if self.seed.focused then
        local applied = seed_ui.keypressed(self.seed, key)
        if applied then
            M.apply_seed(self, applied)
        end
        return
    end
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
