LOVE ?= love
ZIP ?= zip
BUILD_DIR ?= build
LOVE_PACKAGE ?= $(BUILD_DIR)/game.love
HEADLESS_ENV = GAME_HEADLESS=1 SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
LOVE_QA = LOVE_BIN="$(LOVE)" "$(CURDIR)/tools/run_love_qa.sh"

.PHONY: test status-test asset-inventory-test font-test card-overlap-qa blind-card-qa shop-pack-qa pack-panel-qa glass-panel-qa play-bg-qa shop-bg-qa gwang-slot-qa score-icon-qa score-effect-qa lock-effect-qa win-effect-qa loss-effect-qa end-screen-qa deck-blue-qa deck-red-qa deck-yellow-qa stake-white-qa stake-red-qa stake-green-qa tag-qa foil-effect-qa hologram-effect-qa polychrome-effect-qa smoke love verify clean

test:
	$(HEADLESS_ENV) GAME_UNIT=1 $(LOVE_QA) .

status-test:
	python3 -m unittest -v scripts.test_compact_status

asset-inventory-test:
	python3 tools/asset_pipeline/make_checklist.py --check

font-test:
	@rm -rf "$(BUILD_DIR)/font-test"
	@mkdir -p "$(BUILD_DIR)/font-test/assets/fonts" "$(BUILD_DIR)/font-test/game/tests"
	@cp assets/fonts/Galmuri11.ttf assets/fonts/Galmuri-OFL.txt "$(BUILD_DIR)/font-test/assets/fonts/"
	@cp game/fonts.lua "$(BUILD_DIR)/font-test/game/fonts.lua"
	@cp game/tests/fonts.lua "$(BUILD_DIR)/font-test/game/tests/fonts.lua"
	@cp tools/font_test_main.lua "$(BUILD_DIR)/font-test/main.lua"
	$(LOVE_QA) "$(BUILD_DIR)/font-test"

card-overlap-qa:
	@rm -rf "$(BUILD_DIR)/card-overlap-qa"
	@mkdir -p "$(BUILD_DIR)/card-overlap-qa/game/tests" \
		"$(BUILD_DIR)/card-overlap-qa/game/qa" \
		"$(BUILD_DIR)/card-overlap-qa/assets/runtime/cards"
	@cp tools/card_overlap_qa_main.lua "$(BUILD_DIR)/card-overlap-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/card-overlap-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/card-overlap-qa/game/qa/"
	@cp game/tests/card_overlap_qa.lua "$(BUILD_DIR)/card-overlap-qa/game/tests/"
	@cp game/qa/card_overlap.lua "$(BUILD_DIR)/card-overlap-qa/game/qa/"
	@cp assets/runtime/cards/play-card-contact-sheet-v1.png \
		"$(BUILD_DIR)/card-overlap-qa/assets/runtime/cards/"
	CARD_OVERLAP_QA_OUTPUT="$(CURDIR)/assets/runtime/cards/play-card-overlap-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/card-overlap-qa"

blind-card-qa:
	@rm -rf "$(BUILD_DIR)/blind-card-qa"
	@mkdir -p "$(BUILD_DIR)/blind-card-qa/game/ui" \
		"$(BUILD_DIR)/blind-card-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/blind-card-qa/assets/fonts"
	@cp tools/blind_card_qa_main.lua "$(BUILD_DIR)/blind-card-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/blind-card-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/blind-card-qa/game/qa/"
	@cp game/ui/blind_select.lua game/ui/blind_card_art.lua "$(BUILD_DIR)/blind-card-qa/game/ui/"
	@cp game/asset_loader.lua game/terms.lua "$(BUILD_DIR)/blind-card-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/blind-card-qa/assets/"
	@cp assets/runtime/ui/blind-small-v1.png assets/runtime/ui/blind-big-v1.png \
		"$(BUILD_DIR)/blind-card-qa/assets/runtime/ui/"
	@mkdir -p "$(BUILD_DIR)/blind-card-qa/assets/runtime/boss-blind"
	@cp assets/runtime/boss-blind/hook-v1.png assets/runtime/boss-blind/wall-v1.png \
		assets/runtime/boss-blind/flint-v1.png assets/runtime/boss-blind/mark-v1.png \
		assets/runtime/boss-blind/fish-v1.png assets/runtime/boss-blind/psychic-v1.png \
		assets/runtime/boss-blind/goad-v1.png assets/runtime/boss-blind/plant-v1.png \
		"$(BUILD_DIR)/blind-card-qa/assets/runtime/boss-blind/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/blind-card-qa/assets/fonts/"
	BLIND_CARD_QA_OUTDIR="$(CURDIR)/assets/runtime/ui" \
		$(LOVE_QA) "$(BUILD_DIR)/blind-card-qa"

shop-pack-qa:
	@rm -rf "$(BUILD_DIR)/shop-pack-qa"
	@mkdir -p "$(BUILD_DIR)/shop-pack-qa/game/ui" \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/pack" \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/voucher" \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/planet" \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/tarot" \
		"$(BUILD_DIR)/shop-pack-qa/assets/fonts"
	@cp tools/shop_pack_qa_main.lua "$(BUILD_DIR)/shop-pack-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/shop-pack-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/shop-pack-qa/game/qa/"
	@cp game/ui/shop.lua game/ui/pack_art.lua game/ui/voucher_art.lua game/ui/planet_art.lua game/ui/tarot_art.lua game/ui/score_icon_art.lua "$(BUILD_DIR)/shop-pack-qa/game/ui/"
	@cp game/asset_loader.lua game/terms.lua "$(BUILD_DIR)/shop-pack-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/shop-pack-qa/assets/"
	@cp assets/runtime/pack/talisman-bundle-v1.png \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/pack/"
	@cp assets/runtime/voucher/paint-brush-v1.png assets/runtime/voucher/wasteful-v1.png \
		assets/runtime/voucher/grabber-v1.png assets/runtime/voucher/overstock-v1.png \
		assets/runtime/voucher/reroll-surplus-v1.png assets/runtime/voucher/clearance-sale-v1.png \
		assets/runtime/voucher/seed-money-v1.png assets/runtime/voucher/antimatter-v1.png \
		assets/runtime/voucher/crystal-ball-v1.png assets/runtime/voucher/hone-v1.png \
		assets/runtime/voucher/directors-cut-v1.png \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/voucher/"
	@cp assets/runtime/planet/hongdan-v1.png assets/runtime/planet/cheongdan-v1.png \
		assets/runtime/planet/chodan-v1.png assets/runtime/planet/godori-v1.png \
		assets/runtime/planet/pi-v1.png \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/planet/"
	@cp assets/runtime/tarot/the-magician-v1.png assets/runtime/tarot/the-hanged-man-v1.png assets/runtime/tarot/the-chariot-v1.png assets/runtime/tarot/the-lovers-v1.png \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/tarot/"
	@mkdir -p "$(BUILD_DIR)/shop-pack-qa/assets/runtime/ui"
	@cp assets/runtime/ui/icon-money-v1.png "$(BUILD_DIR)/shop-pack-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/shop-pack-qa/assets/fonts/"
	SHOP_PACK_QA_OUTDIR="$(CURDIR)/assets/runtime/ui" \
		$(LOVE_QA) "$(BUILD_DIR)/shop-pack-qa"

pack-panel-qa:
	@rm -rf "$(BUILD_DIR)/pack-panel-qa"
	@mkdir -p "$(BUILD_DIR)/pack-panel-qa/game/ui" \
		"$(BUILD_DIR)/pack-panel-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/pack-panel-qa/assets/fonts"
	@cp tools/pack_panel_qa_main.lua "$(BUILD_DIR)/pack-panel-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/pack-panel-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/pack-panel-qa/game/qa/"
	@cp game/ui/pack.lua game/ui/panel_art.lua "$(BUILD_DIR)/pack-panel-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/pack-panel-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/pack-panel-qa/assets/"
	@cp assets/runtime/ui/panel-wood-v1.png "$(BUILD_DIR)/pack-panel-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/pack-panel-qa/assets/fonts/"
	PACK_PANEL_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/pack-panel-wood-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/pack-panel-qa"

glass-panel-qa:
	@rm -rf "$(BUILD_DIR)/glass-panel-qa"
	@mkdir -p "$(BUILD_DIR)/glass-panel-qa/game/ui" \
		"$(BUILD_DIR)/glass-panel-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/glass-panel-qa/assets/fonts"
	@cp tools/glass_panel_qa_main.lua "$(BUILD_DIR)/glass-panel-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/glass-panel-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/glass-panel-qa/game/qa/"
	@cp game/ui/tarot_target.lua game/ui/panel_art.lua "$(BUILD_DIR)/glass-panel-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/glass-panel-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/glass-panel-qa/assets/"
	@cp assets/runtime/ui/panel-glass-v1.png "$(BUILD_DIR)/glass-panel-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/glass-panel-qa/assets/fonts/"
	GLASS_PANEL_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/pack-panel-glass-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/glass-panel-qa"

play-bg-qa:
	@rm -rf "$(BUILD_DIR)/play-bg-qa"
	@mkdir -p "$(BUILD_DIR)/play-bg-qa/game/ui" \
		"$(BUILD_DIR)/play-bg-qa/assets/runtime/ui"
	@cp tools/play_bg_qa_main.lua "$(BUILD_DIR)/play-bg-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/play-bg-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/play-bg-qa/game/qa/"
	@cp game/ui/scene_bg.lua "$(BUILD_DIR)/play-bg-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/play-bg-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/play-bg-qa/assets/"
	@cp assets/runtime/ui/play-bg-v1.png "$(BUILD_DIR)/play-bg-qa/assets/runtime/ui/"
	PLAY_BG_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/play-bg-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/play-bg-qa"

shop-bg-qa:
	@rm -rf "$(BUILD_DIR)/shop-bg-qa"
	@mkdir -p "$(BUILD_DIR)/shop-bg-qa/game/ui" \
		"$(BUILD_DIR)/shop-bg-qa/assets/runtime/ui"
	@cp tools/shop_bg_qa_main.lua "$(BUILD_DIR)/shop-bg-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/shop-bg-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/shop-bg-qa/game/qa/"
	@cp game/ui/scene_bg.lua "$(BUILD_DIR)/shop-bg-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/shop-bg-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/shop-bg-qa/assets/"
	@cp assets/runtime/ui/shop-bg-v1.png "$(BUILD_DIR)/shop-bg-qa/assets/runtime/ui/"
	SHOP_BG_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-bg-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/shop-bg-qa"

gwang-slot-qa:
	@rm -rf "$(BUILD_DIR)/gwang-slot-qa"
	@mkdir -p "$(BUILD_DIR)/gwang-slot-qa/game/ui" \
		"$(BUILD_DIR)/gwang-slot-qa/game/data" \
		"$(BUILD_DIR)/gwang-slot-qa/assets/runtime/gwang"
	@cp tools/gwang_slot_qa_main.lua "$(BUILD_DIR)/gwang-slot-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/gwang-slot-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/gwang-slot-qa/game/qa/"
	@cp game/ui/gwang_slots.lua game/ui/gwang_art.lua game/ui/gwang_asset_art.lua \
		"$(BUILD_DIR)/gwang-slot-qa/game/ui/"
	@cp game/asset_loader.lua game/gwang_catalog.lua "$(BUILD_DIR)/gwang-slot-qa/game/"
	@cp game/data/gwang_jokers.json "$(BUILD_DIR)/gwang-slot-qa/game/data/"
	@cp assets/manifest.json "$(BUILD_DIR)/gwang-slot-qa/assets/"
	@cp assets/runtime/gwang/chips-v1.png "$(BUILD_DIR)/gwang-slot-qa/assets/runtime/gwang/"
	@cp assets/runtime/gwang/mult-v1.png assets/runtime/gwang/always-mult-small-v1.png \
		assets/runtime/gwang/always-chips-small-v1.png assets/runtime/gwang/always-chips-mid-v1.png \
		assets/runtime/gwang/always-mult-mid-v1.png assets/runtime/gwang/hongdan-x2-v1.png \
		assets/runtime/gwang/cheongdan-x2-v1.png assets/runtime/gwang/chodan-x2-v1.png \
		assets/runtime/gwang/godori-x2-v1.png assets/runtime/gwang/pi-chips-kind-v1.png \
		assets/runtime/gwang/godori-chips-v1.png assets/runtime/gwang/hongdan-chips-v1.png \
		assets/runtime/gwang/cheongdan-chips-v1.png assets/runtime/gwang/chodan-chips-v1.png \
		assets/runtime/gwang/pi-yaku-mult-v1.png assets/runtime/gwang/thin-deck-x3-v1.png \
		assets/runtime/gwang/tiny-deck-chips-v1.png assets/runtime/gwang/lean-deck-mult-v1.png \
		assets/runtime/gwang/rich-mult-v1.png assets/runtime/gwang/loaded-chips-v1.png \
		assets/runtime/gwang/wealthy-x2-v1.png assets/runtime/gwang/boss-x2-v1.png \
		assets/runtime/gwang/boss-chips-v1.png assets/runtime/gwang/small-chips-v1.png \
		assets/runtime/gwang/big-mult-v1.png \
		assets/runtime/gwang/once-x20-v1.png assets/runtime/gwang/once-chips-v1.png \
		assets/runtime/gwang/compound-v1.png \
		"$(BUILD_DIR)/gwang-slot-qa/assets/runtime/gwang/"
	GWANG_SLOT_QA_OUTDIR="$(CURDIR)/assets/runtime/ui" \
		$(LOVE_QA) "$(BUILD_DIR)/gwang-slot-qa"

score-icon-qa:
	@rm -rf "$(BUILD_DIR)/score-icon-qa"
	@mkdir -p "$(BUILD_DIR)/score-icon-qa/game/ui" \
		"$(BUILD_DIR)/score-icon-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/score-icon-qa/assets/fonts"
	@cp tools/score_icon_qa_main.lua "$(BUILD_DIR)/score-icon-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/score-icon-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/score-icon-qa/game/qa/"
	@cp game/ui/scoreboard.lua game/ui/score_icon_art.lua game/ui/action_buttons.lua \
		game/ui/panel_art.lua \
		"$(BUILD_DIR)/score-icon-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/score-icon-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/score-icon-qa/assets/"
	@cp assets/runtime/ui/icon-chip-v1.png assets/runtime/ui/icon-mult-v1.png \
		assets/runtime/ui/icon-money-v1.png assets/runtime/ui/icon-deck-v1.png \
		assets/runtime/ui/icon-discard-v1.png assets/runtime/ui/icon-hand-v1.png \
		assets/runtime/ui/panel-metal-v1.png \
		"$(BUILD_DIR)/score-icon-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/score-icon-qa/assets/fonts/"
	SCORE_ICON_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/score-icon-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/score-icon-qa"

score-effect-qa:
	@rm -rf "$(BUILD_DIR)/score-effect-qa"
	@mkdir -p "$(BUILD_DIR)/score-effect-qa/game/ui" \
		"$(BUILD_DIR)/score-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/score-effect-qa/assets/fonts"
	@cp tools/score_effect_qa_main.lua "$(BUILD_DIR)/score-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/score-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/score-effect-qa/game/qa/"
	@cp game/ui/score_anim.lua game/ui/effect_art.lua "$(BUILD_DIR)/score-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/score-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/score-effect-qa/assets/"
	@cp assets/runtime/ui/effect-score-v1.png "$(BUILD_DIR)/score-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/score-effect-qa/assets/fonts/"
	SCORE_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-score-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/score-effect-qa"

lock-effect-qa:
	@rm -rf "$(BUILD_DIR)/lock-effect-qa"
	@mkdir -p "$(BUILD_DIR)/lock-effect-qa/game/ui" \
		"$(BUILD_DIR)/lock-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/lock-effect-qa/assets/fonts"
	@cp tools/lock_effect_qa_main.lua "$(BUILD_DIR)/lock-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/lock-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/lock-effect-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/lock-effect-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/lock-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/lock-effect-qa/assets/"
	@cp assets/runtime/ui/effect-lock-v1.png assets/runtime/ui/deck-yellow-v1.png \
		"$(BUILD_DIR)/lock-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/lock-effect-qa/assets/fonts/"
	LOCK_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-lock-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/lock-effect-qa"

win-effect-qa:
	@rm -rf "$(BUILD_DIR)/win-effect-qa"
	@mkdir -p "$(BUILD_DIR)/win-effect-qa/game/ui" \
		"$(BUILD_DIR)/win-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/win-effect-qa/assets/fonts"
	@cp tools/win_effect_qa_main.lua "$(BUILD_DIR)/win-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/win-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/win-effect-qa/game/qa/"
	@cp game/ui/effect_art.lua game/ui/scene_bg.lua \
		"$(BUILD_DIR)/win-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/win-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/win-effect-qa/assets/"
	@cp assets/runtime/ui/effect-win-v1.png assets/runtime/ui/play-bg-v1.png \
		"$(BUILD_DIR)/win-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/win-effect-qa/assets/fonts/"
	WIN_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-win-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/win-effect-qa"

loss-effect-qa:
	@rm -rf "$(BUILD_DIR)/loss-effect-qa"
	@mkdir -p "$(BUILD_DIR)/loss-effect-qa/game/ui" \
		"$(BUILD_DIR)/loss-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/loss-effect-qa/assets/fonts"
	@cp tools/loss_effect_qa_main.lua "$(BUILD_DIR)/loss-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/loss-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/loss-effect-qa/game/qa/"
	@cp game/ui/effect_art.lua game/ui/scene_bg.lua \
		"$(BUILD_DIR)/loss-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/loss-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/loss-effect-qa/assets/"
	@cp assets/runtime/ui/effect-loss-v1.png assets/runtime/ui/play-bg-v1.png \
		"$(BUILD_DIR)/loss-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/loss-effect-qa/assets/fonts/"
	LOSS_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-loss-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/loss-effect-qa"

deck-blue-qa:
	@rm -rf "$(BUILD_DIR)/deck-blue-qa"
	@mkdir -p "$(BUILD_DIR)/deck-blue-qa/game/ui" \
		"$(BUILD_DIR)/deck-blue-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/deck-blue-qa/assets/fonts"
	@cp tools/deck_blue_qa_main.lua "$(BUILD_DIR)/deck-blue-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/deck-blue-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/deck-blue-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/deck-blue-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/deck-blue-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/deck-blue-qa/assets/"
	@cp assets/runtime/ui/deck-blue-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/deck-blue-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/deck-blue-qa/assets/fonts/"
	DECK_BLUE_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/deck-blue-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/deck-blue-qa"

deck-red-qa:
	@rm -rf "$(BUILD_DIR)/deck-red-qa"
	@mkdir -p "$(BUILD_DIR)/deck-red-qa/game/ui" \
		"$(BUILD_DIR)/deck-red-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/deck-red-qa/assets/fonts"
	@cp tools/deck_red_qa_main.lua "$(BUILD_DIR)/deck-red-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/deck-red-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/deck-red-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/deck-red-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/deck-red-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/deck-red-qa/assets/"
	@cp assets/runtime/ui/deck-red-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/deck-red-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/deck-red-qa/assets/fonts/"
	DECK_RED_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/deck-red-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/deck-red-qa"

deck-yellow-qa:
	@rm -rf "$(BUILD_DIR)/deck-yellow-qa"
	@mkdir -p "$(BUILD_DIR)/deck-yellow-qa/game/ui" \
		"$(BUILD_DIR)/deck-yellow-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/deck-yellow-qa/assets/fonts"
	@cp tools/deck_yellow_qa_main.lua "$(BUILD_DIR)/deck-yellow-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/deck-yellow-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/deck-yellow-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/deck-yellow-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/deck-yellow-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/deck-yellow-qa/assets/"
	@cp assets/runtime/ui/deck-yellow-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/deck-yellow-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/deck-yellow-qa/assets/fonts/"
	DECK_YELLOW_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/deck-yellow-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/deck-yellow-qa"

stake-white-qa:
	@rm -rf "$(BUILD_DIR)/stake-white-qa"
	@mkdir -p "$(BUILD_DIR)/stake-white-qa/game/ui" \
		"$(BUILD_DIR)/stake-white-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/stake-white-qa/assets/fonts"
	@cp tools/stake_white_qa_main.lua "$(BUILD_DIR)/stake-white-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/stake-white-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/stake-white-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/stake-white-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/stake-white-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/stake-white-qa/assets/"
	@cp assets/runtime/ui/stake-white-v1.png assets/runtime/ui/deck-blue-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/stake-white-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/stake-white-qa/assets/fonts/"
	STAKE_WHITE_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/stake-white-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/stake-white-qa"

stake-red-qa:
	@rm -rf "$(BUILD_DIR)/stake-red-qa"
	@mkdir -p "$(BUILD_DIR)/stake-red-qa/game/ui" \
		"$(BUILD_DIR)/stake-red-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/stake-red-qa/assets/fonts"
	@cp tools/stake_red_qa_main.lua "$(BUILD_DIR)/stake-red-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/stake-red-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/stake-red-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/stake-red-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/stake-red-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/stake-red-qa/assets/"
	@cp assets/runtime/ui/stake-red-v1.png assets/runtime/ui/stake-white-v1.png assets/runtime/ui/deck-blue-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/stake-red-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/stake-red-qa/assets/fonts/"
	STAKE_RED_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/stake-red-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/stake-red-qa"

stake-green-qa:
	@rm -rf "$(BUILD_DIR)/stake-green-qa"
	@mkdir -p "$(BUILD_DIR)/stake-green-qa/game/ui" \
		"$(BUILD_DIR)/stake-green-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/stake-green-qa/assets/fonts"
	@cp tools/stake_green_qa_main.lua "$(BUILD_DIR)/stake-green-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/stake-green-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/stake-green-qa/game/qa/"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua game/ui/stake_art.lua \
		"$(BUILD_DIR)/stake-green-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/stake-green-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/stake-green-qa/assets/"
	@cp assets/runtime/ui/stake-green-v1.png assets/runtime/ui/stake-red-v1.png assets/runtime/ui/stake-white-v1.png assets/runtime/ui/deck-blue-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/stake-green-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/stake-green-qa/assets/fonts/"
	STAKE_GREEN_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/stake-green-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/stake-green-qa"

tag-qa:
	@rm -rf "$(BUILD_DIR)/tag-qa"
	@mkdir -p "$(BUILD_DIR)/tag-qa/game/ui" \
		"$(BUILD_DIR)/tag-qa/assets/runtime/tag" \
		"$(BUILD_DIR)/tag-qa/assets/fonts"
	@cp tools/tag_qa_main.lua "$(BUILD_DIR)/tag-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/tag-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/tag-qa/game/qa/"
	@cp game/ui/tag_art.lua "$(BUILD_DIR)/tag-qa/game/ui/"
	@cp game/asset_loader.lua game/terms.lua game/rng.lua "$(BUILD_DIR)/tag-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/tag-qa/assets/"
	@cp assets/runtime/tag/coupon-v1.png assets/runtime/tag/investment-v1.png assets/runtime/tag/handy-v1.png assets/runtime/tag/economy-v1.png assets/runtime/tag/mega-v1.png assets/runtime/tag/foil-v1.png assets/runtime/tag/hologram-v1.png assets/runtime/tag/polychrome-v1.png assets/runtime/tag/charm-v1.png assets/runtime/tag/uncommon-v1.png assets/runtime/tag/juggle-v1.png assets/runtime/tag/d6-v1.png "$(BUILD_DIR)/tag-qa/assets/runtime/tag/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/tag-qa/assets/fonts/"
	TAG_QA_OUTDIR="$(CURDIR)/assets/runtime/ui" \
		$(LOVE_QA) "$(BUILD_DIR)/tag-qa"

foil-effect-qa:
	@rm -rf "$(BUILD_DIR)/foil-effect-qa"
	@mkdir -p "$(BUILD_DIR)/foil-effect-qa/game/ui" \
		"$(BUILD_DIR)/foil-effect-qa/assets/runtime/cards" \
		"$(BUILD_DIR)/foil-effect-qa/assets/runtime/effect" \
		"$(BUILD_DIR)/foil-effect-qa/assets/fonts"
	@cp tools/foil_effect_qa_main.lua "$(BUILD_DIR)/foil-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/foil-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/foil-effect-qa/game/qa/"
	@cp game/ui/card.lua game/ui/card_art.lua game/ui/edition_art.lua \
		"$(BUILD_DIR)/foil-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/foil-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/foil-effect-qa/assets/"
	@cp assets/runtime/cards/play-card-contact-sheet-v1.png \
		"$(BUILD_DIR)/foil-effect-qa/assets/runtime/cards/"
	@cp assets/runtime/effect/foil-v1.png \
		"$(BUILD_DIR)/foil-effect-qa/assets/runtime/effect/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/foil-effect-qa/assets/fonts/"
	FOIL_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-foil-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/foil-effect-qa"

hologram-effect-qa:
	@rm -rf "$(BUILD_DIR)/hologram-effect-qa"
	@mkdir -p "$(BUILD_DIR)/hologram-effect-qa/game/ui" \
		"$(BUILD_DIR)/hologram-effect-qa/assets/runtime/cards" \
		"$(BUILD_DIR)/hologram-effect-qa/assets/runtime/effect" \
		"$(BUILD_DIR)/hologram-effect-qa/assets/fonts"
	@cp tools/hologram_effect_qa_main.lua "$(BUILD_DIR)/hologram-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/hologram-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/hologram-effect-qa/game/qa/"
	@cp game/ui/card.lua game/ui/card_art.lua game/ui/edition_art.lua \
		"$(BUILD_DIR)/hologram-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/hologram-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/hologram-effect-qa/assets/"
	@cp assets/runtime/cards/play-card-contact-sheet-v1.png \
		"$(BUILD_DIR)/hologram-effect-qa/assets/runtime/cards/"
	@cp assets/runtime/effect/hologram-v1.png \
		"$(BUILD_DIR)/hologram-effect-qa/assets/runtime/effect/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/hologram-effect-qa/assets/fonts/"
	HOLOGRAM_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-hologram-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/hologram-effect-qa"

polychrome-effect-qa:
	@rm -rf "$(BUILD_DIR)/polychrome-effect-qa"
	@mkdir -p "$(BUILD_DIR)/polychrome-effect-qa/game/ui" \
		"$(BUILD_DIR)/polychrome-effect-qa/assets/runtime/cards" \
		"$(BUILD_DIR)/polychrome-effect-qa/assets/runtime/effect" \
		"$(BUILD_DIR)/polychrome-effect-qa/assets/fonts"
	@cp tools/polychrome_effect_qa_main.lua "$(BUILD_DIR)/polychrome-effect-qa/main.lua"
	@mkdir -p "$(BUILD_DIR)/polychrome-effect-qa/game/qa"
	@cp game/qa/offscreen_window.lua "$(BUILD_DIR)/polychrome-effect-qa/game/qa/"
	@cp game/ui/card.lua game/ui/card_art.lua game/ui/edition_art.lua \
		"$(BUILD_DIR)/polychrome-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/polychrome-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/polychrome-effect-qa/assets/"
	@cp assets/runtime/cards/play-card-contact-sheet-v1.png \
		"$(BUILD_DIR)/polychrome-effect-qa/assets/runtime/cards/"
	@cp assets/runtime/effect/polychrome-v1.png \
		"$(BUILD_DIR)/polychrome-effect-qa/assets/runtime/effect/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/polychrome-effect-qa/assets/fonts/"
	POLYCHROME_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-polychrome-love-v1.png" \
		$(LOVE_QA) "$(BUILD_DIR)/polychrome-effect-qa"

end-screen-qa:
	@rm -rf "$(BUILD_DIR)/end-screen-qa" "$(BUILD_DIR)/end-screen-qa.png"
	@mkdir -p "$(BUILD_DIR)/end-screen-qa/game" \
		"$(BUILD_DIR)/end-screen-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/end-screen-qa/assets/fonts"
	@cp -R game/. "$(BUILD_DIR)/end-screen-qa/game/"
	@cp tools/end_screen_qa_main.lua "$(BUILD_DIR)/end-screen-qa/main.lua"
	@cp assets/manifest.json "$(BUILD_DIR)/end-screen-qa/assets/"
	@cp assets/runtime/ui/effect-win-v1.png assets/runtime/ui/effect-loss-v1.png \
		assets/runtime/ui/panel-metal-v1.png "$(BUILD_DIR)/end-screen-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/end-screen-qa/assets/fonts/"
	END_SCREEN_QA_OUTPUT="$(CURDIR)/$(BUILD_DIR)/end-screen-qa.png" \
		$(LOVE_QA) "$(BUILD_DIR)/end-screen-qa"
	@test -s "$(BUILD_DIR)/end-screen-qa.png"

smoke:
	$(HEADLESS_ENV) $(LOVE_QA) .

love:
	@mkdir -p "$(BUILD_DIR)"
	@rm -f "$(LOVE_PACKAGE)"
	@$(ZIP) -q -9 -r "$(LOVE_PACKAGE)" . \
		-x '.git' -x '.git/*' -x '.github/*' -x 'build/*' \
		-x 'tmp/*' -x 'logs/*' -x '.venv/*' -x '__pycache__/*' \
		-x '.env' -x '.env.*' -x '.DS_Store' -x '*.swp'

verify: status-test asset-inventory-test test font-test card-overlap-qa blind-card-qa shop-pack-qa pack-panel-qa glass-panel-qa play-bg-qa shop-bg-qa gwang-slot-qa score-icon-qa score-effect-qa lock-effect-qa win-effect-qa loss-effect-qa end-screen-qa deck-blue-qa deck-red-qa deck-yellow-qa stake-white-qa stake-red-qa stake-green-qa tag-qa foil-effect-qa hologram-effect-qa polychrome-effect-qa smoke love
	$(HEADLESS_ENV) $(LOVE_QA) "$(LOVE_PACKAGE)"
	python3 tools/verify_bundle.py "$(LOVE_PACKAGE)"

clean:
	rm -rf "$(BUILD_DIR)"
