LOVE ?= love
ZIP ?= zip
BUILD_DIR ?= build
LOVE_PACKAGE ?= $(BUILD_DIR)/game.love

.PHONY: test status-test font-test card-overlap-qa blind-card-qa smoke love verify clean

test:
	GAME_HEADLESS=1 GAME_UNIT=1 $(LOVE) .

status-test:
	python3 -m unittest -v scripts.test_compact_status

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
		assets/runtime/boss-blind/flint-v1.png \
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

smoke:
	GAME_HEADLESS=1 $(LOVE) .

love:
	@mkdir -p "$(BUILD_DIR)"
	@rm -f "$(LOVE_PACKAGE)"
	@$(ZIP) -q -9 -r "$(LOVE_PACKAGE)" . \
		-x '.git' -x '.git/*' -x '.github/*' -x 'build/*' \
		-x 'tmp/*' -x 'logs/*' -x '.venv/*' -x '__pycache__/*' \
		-x '.env' -x '.env.*' -x '.DS_Store' -x '*.swp'

verify: status-test test font-test card-overlap-qa blind-card-qa smoke love
	GAME_HEADLESS=1 $(LOVE) "$(LOVE_PACKAGE)"
	python3 tools/verify_bundle.py "$(LOVE_PACKAGE)"

clean:
	rm -rf "$(BUILD_DIR)"
