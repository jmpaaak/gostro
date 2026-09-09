LOVE ?= love
ZIP ?= zip
BUILD_DIR ?= build
LOVE_PACKAGE ?= $(BUILD_DIR)/game.love

.PHONY: test status-test asset-inventory-test font-test card-overlap-qa blind-card-qa shop-pack-qa pack-panel-qa glass-panel-qa play-bg-qa shop-bg-qa gwang-slot-qa score-icon-qa score-effect-qa lock-effect-qa win-effect-qa loss-effect-qa deck-blue-qa deck-red-qa deck-yellow-qa smoke love verify clean

test:
	GAME_HEADLESS=1 GAME_UNIT=1 $(LOVE) .

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
	$(LOVE) "$(BUILD_DIR)/font-test"

card-overlap-qa:
	@rm -rf "$(BUILD_DIR)/card-overlap-qa"
	@mkdir -p "$(BUILD_DIR)/card-overlap-qa/game/tests" \
		"$(BUILD_DIR)/card-overlap-qa/game/qa" \
		"$(BUILD_DIR)/card-overlap-qa/assets/runtime/cards"
	@cp tools/card_overlap_qa_main.lua "$(BUILD_DIR)/card-overlap-qa/main.lua"
	@cp game/tests/card_overlap_qa.lua "$(BUILD_DIR)/card-overlap-qa/game/tests/"
	@cp game/qa/card_overlap.lua "$(BUILD_DIR)/card-overlap-qa/game/qa/"
	@cp assets/runtime/cards/play-card-contact-sheet-v1.png \
		"$(BUILD_DIR)/card-overlap-qa/assets/runtime/cards/"
	CARD_OVERLAP_QA_OUTPUT="$(CURDIR)/assets/runtime/cards/play-card-overlap-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/card-overlap-qa"

blind-card-qa:
	@rm -rf "$(BUILD_DIR)/blind-card-qa"
	@mkdir -p "$(BUILD_DIR)/blind-card-qa/game/ui" \
		"$(BUILD_DIR)/blind-card-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/blind-card-qa/assets/fonts"
	@cp tools/blind_card_qa_main.lua "$(BUILD_DIR)/blind-card-qa/main.lua"
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
	BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-round-cards-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=wall \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-wall-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=flint \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-flint-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=mark \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-mark-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=fish \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-fish-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=psychic \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-psychic-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=goad \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-goad-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"
	BLIND_CARD_QA_BOSS=plant \
		BLIND_CARD_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/blind-plant-card-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/blind-card-qa"

shop-pack-qa:
	@rm -rf "$(BUILD_DIR)/shop-pack-qa"
	@mkdir -p "$(BUILD_DIR)/shop-pack-qa/game/ui" \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/pack" \
		"$(BUILD_DIR)/shop-pack-qa/assets/runtime/voucher" \
		"$(BUILD_DIR)/shop-pack-qa/assets/fonts"
	@cp tools/shop_pack_qa_main.lua "$(BUILD_DIR)/shop-pack-qa/main.lua"
	@cp game/ui/shop.lua game/ui/pack_art.lua game/ui/voucher_art.lua game/ui/score_icon_art.lua "$(BUILD_DIR)/shop-pack-qa/game/ui/"
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
	@mkdir -p "$(BUILD_DIR)/shop-pack-qa/assets/runtime/ui"
	@cp assets/runtime/ui/icon-money-v1.png "$(BUILD_DIR)/shop-pack-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/shop-pack-qa/assets/fonts/"
	SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-pack-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	SHOP_QA_KIND=voucher \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=wasteful \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-wasteful-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=grabber \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-grabber-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=overstock \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-overstock-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=reroll_surplus \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-reroll-surplus-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-reroll-surplus-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=clearance_sale \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-clearance-sale-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-clearance-sale-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=seed_money \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-seed-money-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-seed-money-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=antimatter \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-antimatter-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-antimatter-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=crystal_ball \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-crystal-ball-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-crystal-ball-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=hone \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-hone-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-hone-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=directors_cut \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-directors-cut-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-directors-cut-love-v1.png"
	SHOP_QA_KIND=voucher SHOP_QA_VOUCHER=money_tree \
		SHOP_PACK_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-voucher-money-tree-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-pack-qa"
	@echo "SHOP_ART_LOVE_QA_OK voucher 320x180 $(CURDIR)/assets/runtime/ui/shop-voucher-money-tree-love-v1.png"

pack-panel-qa:
	@rm -rf "$(BUILD_DIR)/pack-panel-qa"
	@mkdir -p "$(BUILD_DIR)/pack-panel-qa/game/ui" \
		"$(BUILD_DIR)/pack-panel-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/pack-panel-qa/assets/fonts"
	@cp tools/pack_panel_qa_main.lua "$(BUILD_DIR)/pack-panel-qa/main.lua"
	@cp game/ui/pack.lua game/ui/panel_art.lua "$(BUILD_DIR)/pack-panel-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/pack-panel-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/pack-panel-qa/assets/"
	@cp assets/runtime/ui/panel-wood-v1.png "$(BUILD_DIR)/pack-panel-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/pack-panel-qa/assets/fonts/"
	PACK_PANEL_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/pack-panel-wood-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/pack-panel-qa"

glass-panel-qa:
	@rm -rf "$(BUILD_DIR)/glass-panel-qa"
	@mkdir -p "$(BUILD_DIR)/glass-panel-qa/game/ui" \
		"$(BUILD_DIR)/glass-panel-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/glass-panel-qa/assets/fonts"
	@cp tools/glass_panel_qa_main.lua "$(BUILD_DIR)/glass-panel-qa/main.lua"
	@cp game/ui/tarot_target.lua game/ui/panel_art.lua "$(BUILD_DIR)/glass-panel-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/glass-panel-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/glass-panel-qa/assets/"
	@cp assets/runtime/ui/panel-glass-v1.png "$(BUILD_DIR)/glass-panel-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/glass-panel-qa/assets/fonts/"
	GLASS_PANEL_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/pack-panel-glass-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/glass-panel-qa"

play-bg-qa:
	@rm -rf "$(BUILD_DIR)/play-bg-qa"
	@mkdir -p "$(BUILD_DIR)/play-bg-qa/game/ui" \
		"$(BUILD_DIR)/play-bg-qa/assets/runtime/ui"
	@cp tools/play_bg_qa_main.lua "$(BUILD_DIR)/play-bg-qa/main.lua"
	@cp game/ui/scene_bg.lua "$(BUILD_DIR)/play-bg-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/play-bg-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/play-bg-qa/assets/"
	@cp assets/runtime/ui/play-bg-v1.png "$(BUILD_DIR)/play-bg-qa/assets/runtime/ui/"
	PLAY_BG_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/play-bg-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/play-bg-qa"

shop-bg-qa:
	@rm -rf "$(BUILD_DIR)/shop-bg-qa"
	@mkdir -p "$(BUILD_DIR)/shop-bg-qa/game/ui" \
		"$(BUILD_DIR)/shop-bg-qa/assets/runtime/ui"
	@cp tools/shop_bg_qa_main.lua "$(BUILD_DIR)/shop-bg-qa/main.lua"
	@cp game/ui/scene_bg.lua "$(BUILD_DIR)/shop-bg-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/shop-bg-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/shop-bg-qa/assets/"
	@cp assets/runtime/ui/shop-bg-v1.png "$(BUILD_DIR)/shop-bg-qa/assets/runtime/ui/"
	SHOP_BG_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/shop-bg-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/shop-bg-qa"

gwang-slot-qa:
	@rm -rf "$(BUILD_DIR)/gwang-slot-qa"
	@mkdir -p "$(BUILD_DIR)/gwang-slot-qa/game/ui" \
		"$(BUILD_DIR)/gwang-slot-qa/game/data" \
		"$(BUILD_DIR)/gwang-slot-qa/assets/runtime/gwang"
	@cp tools/gwang_slot_qa_main.lua "$(BUILD_DIR)/gwang-slot-qa/main.lua"
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
	GWANG_QA_IDENTITY="chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="mult" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-mult-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="always_mult_small" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-always-mult-small-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="always_chips_small" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-always-chips-small-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="always_chips_mid" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-always-chips-mid-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="always_mult_mid" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-always-mult-mid-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="hongdan_x2" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-hongdan-x2-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="cheongdan_x2" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-cheongdan-x2-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="chodan_x2" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-chodan-x2-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="godori_x2" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-godori-x2-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="pi_chips_kind" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-pi-chips-kind-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="godori_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-godori-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="hongdan_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-hongdan-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="cheongdan_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-cheongdan-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="chodan_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-chodan-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="pi_yaku_mult" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-pi-yaku-mult-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="thin_deck_x3" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-thin-deck-x3-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="tiny_deck_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-tiny-deck-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="lean_deck_mult" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-lean-deck-mult-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="rich_mult" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-rich-mult-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="loaded_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-loaded-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="wealthy_x2" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-wealthy-x2-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="boss_x2" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-boss-x2-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="boss_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-boss-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="small_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-small-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="big_mult" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-big-mult-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="once_x20" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-once-x20-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="once_chips" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-once-chips-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"
	GWANG_QA_IDENTITY="compound" GWANG_SLOT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/gwang-compound-slots-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/gwang-slot-qa"

score-icon-qa:
	@rm -rf "$(BUILD_DIR)/score-icon-qa"
	@mkdir -p "$(BUILD_DIR)/score-icon-qa/game/ui" \
		"$(BUILD_DIR)/score-icon-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/score-icon-qa/assets/fonts"
	@cp tools/score_icon_qa_main.lua "$(BUILD_DIR)/score-icon-qa/main.lua"
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
		$(LOVE) "$(BUILD_DIR)/score-icon-qa"

score-effect-qa:
	@rm -rf "$(BUILD_DIR)/score-effect-qa"
	@mkdir -p "$(BUILD_DIR)/score-effect-qa/game/ui" \
		"$(BUILD_DIR)/score-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/score-effect-qa/assets/fonts"
	@cp tools/score_effect_qa_main.lua "$(BUILD_DIR)/score-effect-qa/main.lua"
	@cp game/ui/score_anim.lua game/ui/effect_art.lua "$(BUILD_DIR)/score-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/score-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/score-effect-qa/assets/"
	@cp assets/runtime/ui/effect-score-v1.png "$(BUILD_DIR)/score-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/score-effect-qa/assets/fonts/"
	SCORE_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-score-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/score-effect-qa"

lock-effect-qa:
	@rm -rf "$(BUILD_DIR)/lock-effect-qa"
	@mkdir -p "$(BUILD_DIR)/lock-effect-qa/game/ui" \
		"$(BUILD_DIR)/lock-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/lock-effect-qa/assets/fonts"
	@cp tools/lock_effect_qa_main.lua "$(BUILD_DIR)/lock-effect-qa/main.lua"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua \
		"$(BUILD_DIR)/lock-effect-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/lock-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/lock-effect-qa/assets/"
	@cp assets/runtime/ui/effect-lock-v1.png assets/runtime/ui/deck-yellow-v1.png \
		"$(BUILD_DIR)/lock-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/lock-effect-qa/assets/fonts/"
	LOCK_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-lock-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/lock-effect-qa"

win-effect-qa:
	@rm -rf "$(BUILD_DIR)/win-effect-qa"
	@mkdir -p "$(BUILD_DIR)/win-effect-qa/game/ui" \
		"$(BUILD_DIR)/win-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/win-effect-qa/assets/fonts"
	@cp tools/win_effect_qa_main.lua "$(BUILD_DIR)/win-effect-qa/main.lua"
	@cp game/ui/effect_art.lua game/ui/scene_bg.lua \
		"$(BUILD_DIR)/win-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/win-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/win-effect-qa/assets/"
	@cp assets/runtime/ui/effect-win-v1.png assets/runtime/ui/play-bg-v1.png \
		"$(BUILD_DIR)/win-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/win-effect-qa/assets/fonts/"
	WIN_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-win-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/win-effect-qa"

loss-effect-qa:
	@rm -rf "$(BUILD_DIR)/loss-effect-qa"
	@mkdir -p "$(BUILD_DIR)/loss-effect-qa/game/ui" \
		"$(BUILD_DIR)/loss-effect-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/loss-effect-qa/assets/fonts"
	@cp tools/loss_effect_qa_main.lua "$(BUILD_DIR)/loss-effect-qa/main.lua"
	@cp game/ui/effect_art.lua game/ui/scene_bg.lua \
		"$(BUILD_DIR)/loss-effect-qa/game/ui/"
	@cp game/asset_loader.lua "$(BUILD_DIR)/loss-effect-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/loss-effect-qa/assets/"
	@cp assets/runtime/ui/effect-loss-v1.png assets/runtime/ui/play-bg-v1.png \
		"$(BUILD_DIR)/loss-effect-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/loss-effect-qa/assets/fonts/"
	LOSS_EFFECT_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/effect-loss-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/loss-effect-qa"

deck-blue-qa:
	@rm -rf "$(BUILD_DIR)/deck-blue-qa"
	@mkdir -p "$(BUILD_DIR)/deck-blue-qa/game/ui" \
		"$(BUILD_DIR)/deck-blue-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/deck-blue-qa/assets/fonts"
	@cp tools/deck_blue_qa_main.lua "$(BUILD_DIR)/deck-blue-qa/main.lua"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua \
		"$(BUILD_DIR)/deck-blue-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/deck-blue-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/deck-blue-qa/assets/"
	@cp assets/runtime/ui/deck-blue-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/deck-blue-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/deck-blue-qa/assets/fonts/"
	DECK_BLUE_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/deck-blue-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/deck-blue-qa"

deck-red-qa:
	@rm -rf "$(BUILD_DIR)/deck-red-qa"
	@mkdir -p "$(BUILD_DIR)/deck-red-qa/game/ui" \
		"$(BUILD_DIR)/deck-red-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/deck-red-qa/assets/fonts"
	@cp tools/deck_red_qa_main.lua "$(BUILD_DIR)/deck-red-qa/main.lua"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua \
		"$(BUILD_DIR)/deck-red-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/deck-red-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/deck-red-qa/assets/"
	@cp assets/runtime/ui/deck-red-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/deck-red-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/deck-red-qa/assets/fonts/"
	DECK_RED_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/deck-red-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/deck-red-qa"

deck-yellow-qa:
	@rm -rf "$(BUILD_DIR)/deck-yellow-qa"
	@mkdir -p "$(BUILD_DIR)/deck-yellow-qa/game/ui" \
		"$(BUILD_DIR)/deck-yellow-qa/assets/runtime/ui" \
		"$(BUILD_DIR)/deck-yellow-qa/assets/fonts"
	@cp tools/deck_yellow_qa_main.lua "$(BUILD_DIR)/deck-yellow-qa/main.lua"
	@cp game/ui/run_setup.lua game/ui/seed.lua game/ui/effect_art.lua game/ui/deck_art.lua \
		"$(BUILD_DIR)/deck-yellow-qa/game/ui/"
	@cp game/asset_loader.lua game/fonts.lua game/rng.lua "$(BUILD_DIR)/deck-yellow-qa/game/"
	@cp assets/manifest.json "$(BUILD_DIR)/deck-yellow-qa/assets/"
	@cp assets/runtime/ui/deck-yellow-v1.png assets/runtime/ui/effect-lock-v1.png \
		"$(BUILD_DIR)/deck-yellow-qa/assets/runtime/ui/"
	@cp assets/fonts/Galmuri11.ttf "$(BUILD_DIR)/deck-yellow-qa/assets/fonts/"
	DECK_YELLOW_QA_OUTPUT="$(CURDIR)/assets/runtime/ui/deck-yellow-love-v1.png" \
		$(LOVE) "$(BUILD_DIR)/deck-yellow-qa"

smoke:
	GAME_HEADLESS=1 $(LOVE) .

love:
	@mkdir -p "$(BUILD_DIR)"
	@rm -f "$(LOVE_PACKAGE)"
	@$(ZIP) -q -9 -r "$(LOVE_PACKAGE)" . \
		-x '.git' -x '.git/*' -x '.github/*' -x 'build/*' \
		-x 'tmp/*' -x 'logs/*' -x '.venv/*' -x '__pycache__/*' \
		-x '.env' -x '.env.*' -x '.DS_Store' -x '*.swp'

verify: status-test asset-inventory-test test font-test card-overlap-qa blind-card-qa shop-pack-qa pack-panel-qa glass-panel-qa play-bg-qa shop-bg-qa gwang-slot-qa score-icon-qa score-effect-qa lock-effect-qa win-effect-qa loss-effect-qa deck-blue-qa deck-red-qa deck-yellow-qa smoke love
	GAME_HEADLESS=1 $(LOVE) "$(LOVE_PACKAGE)"
	python3 tools/verify_bundle.py "$(LOVE_PACKAGE)"

clean:
	rm -rf "$(BUILD_DIR)"
