LOVE ?= love
ZIP ?= zip
BUILD_DIR ?= build
LOVE_PACKAGE ?= $(BUILD_DIR)/game.love

.PHONY: test font-test smoke love verify clean

test:
	GAME_HEADLESS=1 GAME_UNIT=1 $(LOVE) .

font-test:
	@rm -rf "$(BUILD_DIR)/font-test"
	@mkdir -p "$(BUILD_DIR)/font-test/assets/fonts" "$(BUILD_DIR)/font-test/game/tests"
	@cp assets/fonts/Galmuri11.ttf assets/fonts/Galmuri-OFL.txt "$(BUILD_DIR)/font-test/assets/fonts/"
	@cp game/fonts.lua "$(BUILD_DIR)/font-test/game/fonts.lua"
	@cp game/tests/fonts.lua "$(BUILD_DIR)/font-test/game/tests/fonts.lua"
	@cp tools/font_test_main.lua "$(BUILD_DIR)/font-test/main.lua"
	$(LOVE) "$(BUILD_DIR)/font-test"

smoke:
	GAME_HEADLESS=1 $(LOVE) .

love:
	@mkdir -p "$(BUILD_DIR)"
	@rm -f "$(LOVE_PACKAGE)"
	@$(ZIP) -q -9 -r "$(LOVE_PACKAGE)" . \
		-x '.git' -x '.git/*' -x '.github/*' -x 'build/*' \
		-x 'tmp/*' -x 'logs/*' -x '.venv/*' -x '__pycache__/*' \
		-x '.env' -x '.env.*' -x '.DS_Store' -x '*.swp'

verify: test font-test smoke love
	GAME_HEADLESS=1 $(LOVE) "$(LOVE_PACKAGE)"
	python3 tools/verify_bundle.py "$(LOVE_PACKAGE)"

clean:
	rm -rf "$(BUILD_DIR)"
