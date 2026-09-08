"""INBOX (23a): gwang-editor JSON schema + File API / FSA load-save."""
import json
import os
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_PATH = os.path.join(ROOT, "game", "data", "gwang_jokers.json")
JS_PATH = os.path.join(ROOT, "tools", "gwang-editor", "editor.js")
HTML_PATH = os.path.join(ROOT, "tools", "gwang-editor", "index.html")
CSS_PATH = os.path.join(ROOT, "tools", "gwang-editor", "editor.css")

KNOWN_RARITIES = ("common", "uncommon", "rare", "legendary")
KNOWN_TRIGGERS = (
    "always",
    "contains_kind",
    "yaku",
    "deck_size",
    "money",
    "blind",
    "once",
)
KNOWN_EFFECT_KEYS = ("chips", "mult", "mult_mul", "money")
KNOWN_KINDS = ("hongdan", "cheongdan", "chodan", "godori", "pi")
KNOWN_BLINDS = ("small", "big", "boss")
KNOWN_YAKU = ("hongdan", "cheongdan", "chodan", "godori", "pi")


def _fn_body(src, name):
    start = src.find("function %s" % name)
    if start < 0:
        start = src.find("%s =" % name)
    if start < 0:
        return ""
    brace = src.find("{", start)
    if brace < 0:
        return ""
    depth = 0
    for i in range(brace, len(src)):
        if src[i] == "{":
            depth += 1
        elif src[i] == "}":
            depth -= 1
            if depth == 0:
                return src[start : i + 1]
    return src[start:]


class GwangEditorSchemaTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with open(JSON_PATH, encoding="utf-8") as f:
            cls.doc = json.load(f)
        with open(JS_PATH, encoding="utf-8") as f:
            cls.js = f.read()
        with open(HTML_PATH, encoding="utf-8") as f:
            cls.html = f.read()
        with open(CSS_PATH, encoding="utf-8") as f:
            cls.css = f.read()

    def test_catalog_is_jokers_document(self):
        self.assertIsInstance(self.doc, dict)
        self.assertIn("jokers", self.doc)
        self.assertIsInstance(self.doc["jokers"], list)
        self.assertGreaterEqual(len(self.doc["jokers"]), 30)

    def test_each_joker_has_required_fields(self):
        for index, joker in enumerate(self.doc["jokers"]):
            prefix = "joker #%d" % (index + 1)
            self.assertIsInstance(joker, dict, prefix)
            self.assertIsInstance(joker.get("id"), str)
            self.assertTrue(joker["id"], prefix)
            self.assertNotIn(" ", joker["id"], prefix)
            self.assertIsInstance(joker.get("name"), dict, prefix)
            self.assertTrue(joker["name"].get("ko"), prefix)
            self.assertTrue(joker["name"].get("en"), prefix)
            self.assertIn(joker.get("rarity"), KNOWN_RARITIES, prefix)
            self.assertIn(joker.get("trigger"), KNOWN_TRIGGERS, prefix)
            self.assertIsInstance(joker.get("effect"), dict, prefix)
            self.assertTrue(joker["effect"], prefix)
            for key in joker["effect"]:
                self.assertIn(key, KNOWN_EFFECT_KEYS, prefix)
                self.assertIsInstance(joker["effect"][key], (int, float), prefix)
            self.assertIsInstance(joker.get("desc"), dict, prefix)
            self.assertTrue(joker["desc"].get("ko"), prefix)
            self.assertTrue(joker["desc"].get("en"), prefix)
            if "image" in joker:
                self.assertIsInstance(joker["image"], str, prefix)

    def test_trigger_fields_match_kind(self):
        for joker in self.doc["jokers"]:
            trigger = joker["trigger"]
            if trigger == "contains_kind":
                self.assertIn(joker.get("kind_need"), KNOWN_KINDS, joker["id"])
            elif trigger == "yaku":
                self.assertIn(joker.get("yaku_need"), KNOWN_YAKU, joker["id"])
            elif trigger == "deck_size":
                self.assertIsInstance(joker.get("deck_max"), int, joker["id"])
            elif trigger == "money":
                self.assertIsInstance(joker.get("money_min"), int, joker["id"])
            elif trigger == "blind":
                self.assertIn(joker.get("blind_need"), KNOWN_BLINDS, joker["id"])

    def test_ids_are_unique(self):
        ids = [j["id"] for j in self.doc["jokers"]]
        self.assertEqual(len(ids), len(set(ids)))

    def test_html_has_file_api_and_fsa_controls(self):
        self.assertIn('id="openJsonInput"', self.html)
        self.assertIn('accept=".json"', self.html)
        self.assertIn('id="openFsaBtn"', self.html)
        self.assertIn('id="saveFsaBtn"', self.html)
        self.assertIn('id="downloadBtn"', self.html)
        self.assertRegex(self.html, r">\s*Open gwang_jokers\.json\s*<")
        self.assertRegex(self.html, r">\s*Open \+ enable direct save\s*<")
        self.assertRegex(self.html, r">\s*Save to disk\s*<")
        self.assertRegex(self.html, r">\s*Download JSON\s*<")

    def test_editor_js_loads_via_file_api(self):
        self.assertIn("function readFileAsJson", self.js)
        self.assertIn("file.text()", self.js)
        self.assertIn("JSON.parse", self.js)
        open_input = _fn_body(self.js, "wireOpenInput")
        self.assertTrue(open_input, "wireOpenInput must exist")
        self.assertIn("readFileAsJson", open_input)
        self.assertIn("loadDocument", open_input)
        init = _fn_body(self.js, "init")
        self.assertIn("wireOpenInput", init)

    def test_editor_js_saves_via_fsa(self):
        self.assertIn("showOpenFilePicker", self.js)
        self.assertIn("createWritable", self.js)
        open_fsa = _fn_body(self.js, "wireOpenFsa")
        self.assertTrue(open_fsa, "wireOpenFsa must exist")
        self.assertIn("fileHandle", open_fsa)
        save_fsa = _fn_body(self.js, "wireSaveFsa")
        self.assertTrue(save_fsa, "wireSaveFsa must exist")
        self.assertIn("createWritable", save_fsa)
        self.assertIn("serializePool", save_fsa)
        self.assertIn("validatePool", save_fsa)

    def test_editor_js_validates_jokers_schema(self):
        validate = _fn_body(self.js, "validatePool")
        self.assertTrue(validate, "validatePool must exist")
        self.assertIn("jokers", validate)
        self.assertIn("KNOWN_RARITIES", validate)
        self.assertIn("KNOWN_TRIGGERS", validate)
        self.assertIn("duplicate", validate)

    def test_editor_js_serializes_jokers_document(self):
        serialize = _fn_body(self.js, "serializePool")
        self.assertTrue(serialize, "serializePool must exist")
        self.assertIn("JSON.stringify", serialize)
        download = _fn_body(self.js, "wireDownload")
        self.assertTrue(download)
        self.assertIn("gwang_jokers.json", download)
        self.assertIn("validatePool", download)

    def test_editor_css_exists(self):
        self.assertGreater(len(self.css), 0)
        self.assertIn("--bg", self.css)


class GwangEditorGridTests(unittest.TestCase):
    """INBOX (23b): each gwang joker as a vertical rounded hwatu card."""

    @classmethod
    def setUpClass(cls):
        with open(JS_PATH, encoding="utf-8") as f:
            cls.js = f.read()
        with open(HTML_PATH, encoding="utf-8") as f:
            cls.html = f.read()
        with open(CSS_PATH, encoding="utf-8") as f:
            cls.css = f.read()

    def test_html_has_card_grid(self):
        self.assertIn('id="grid"', self.html)
        self.assertIn('class="card-grid"', self.html)

    def test_css_hwatu_card_is_vertical_rounded_rect(self):
        self.assertIn(".hwatu-card", self.css)
        self.assertRegex(
            self.css,
            r"\.hwatu-card\s*\{[^}]*aspect-ratio\s*:\s*2\s*/\s*3",
            "hwatu cards must be a vertical 2:3 rectangle",
        )
        self.assertRegex(
            self.css,
            r"\.hwatu-card\s*\{[^}]*border-radius\s*:",
            "hwatu cards must have rounded corners",
        )

    def test_render_grid_emits_one_hwatu_card_per_joker(self):
        render = _fn_body(self.js, "renderGrid")
        self.assertTrue(render, "renderGrid must exist")
        self.assertIn("hwatu-card", render)
        self.assertIn("pool.jokers.map", render)
        self.assertIn("data-id", render)


class GwangEditorImageUploadTests(unittest.TestCase):
    """INBOX (23c): per-card image upload, center-crop into the hwatu frame."""

    @classmethod
    def setUpClass(cls):
        with open(JS_PATH, encoding="utf-8") as f:
            cls.js = f.read()
        with open(HTML_PATH, encoding="utf-8") as f:
            cls.html = f.read()
        with open(CSS_PATH, encoding="utf-8") as f:
            cls.css = f.read()

    def test_render_grid_emits_per_card_image_input(self):
        render = _fn_body(self.js, "renderGrid")
        self.assertTrue(render, "renderGrid must exist")
        self.assertIn('type="file"', render)
        self.assertIn("accept=", render)
        self.assertIn("image/*", render)
        self.assertIn("card-image-input", render)

    def test_center_crop_resizes_to_card_aspect(self):
        crop = _fn_body(self.js, "centerCropToCard")
        self.assertTrue(crop, "centerCropToCard must exist")
        self.assertIn("createElement", crop)
        self.assertIn("canvas", crop)
        self.assertIn("drawImage", crop)
        self.assertIn("toDataURL", crop)
        self.assertRegex(
            crop,
            r"2\s*/\s*3|CARD_ASPECT|240|360",
            "crop must keep the hwatu 2:3 card ratio",
        )
        self.assertRegex(
            crop,
            r"sx|sy|\(srcW\s*-\s*sw\)\s*/\s*2|\(srcH\s*-\s*sh\)\s*/\s*2",
            "crop must be centered",
        )

    def test_image_upload_places_art_in_card_frame(self):
        render = _fn_body(self.js, "renderGrid")
        self.assertIn("joker.image", render)
        self.assertIn("hwatu-art", render)
        self.assertIn("centerCropToCard", self.js)
        self.assertIn("wireImageUploads", self.js)
        wire = _fn_body(self.js, "wireImageUploads")
        self.assertTrue(wire, "wireImageUploads must exist")
        self.assertIn("card-image-input", wire)
        self.assertIn("centerCropToCard", wire)
        self.assertIn("joker.image", wire)
        self.assertIn("renderGrid", wire)

    def test_css_art_fills_card_frame(self):
        self.assertIn(".hwatu-art", self.css)
        self.assertRegex(
            self.css,
            r"\.hwatu-art\s*\{[^}]*object-fit\s*:",
            "uploaded art must fill the card frame",
        )
        self.assertRegex(
            self.css,
            r"\.hwatu-art\s*\{[^}]*position\s*:\s*absolute",
            "art sits inside the rounded hwatu frame",
        )


class GwangEditorImagePersistTests(unittest.TestCase):
    """INBOX (23d): persist card art as a base64 data URL in JSON image."""

    @classmethod
    def setUpClass(cls):
        with open(JS_PATH, encoding="utf-8") as f:
            cls.js = f.read()

    def test_crop_emits_base64_data_url(self):
        crop = _fn_body(self.js, "centerCropToCard")
        self.assertTrue(crop, "centerCropToCard must exist")
        self.assertIn("toDataURL", crop)
        self.assertRegex(
            crop,
            r"image/png|data:image",
            "crop must emit a PNG data URL",
        )

    def test_validate_pool_requires_image_data_url(self):
        self.assertIn("function isImageDataUrl", self.js)
        is_url = _fn_body(self.js, "isImageDataUrl")
        self.assertTrue(is_url, "isImageDataUrl must exist")
        self.assertIn("data:image/", is_url)
        self.assertIn("base64", is_url)
        validate = _fn_body(self.js, "validatePool")
        self.assertTrue(validate, "validatePool must exist")
        self.assertIn("isImageDataUrl", validate)
        self.assertIn("image", validate)

    def test_serialize_pool_writes_image_field(self):
        serialize = _fn_body(self.js, "serializePool")
        self.assertTrue(serialize, "serializePool must exist")
        self.assertIn("JSON.stringify", serialize)
        self.assertIn("image", serialize)
        self.assertIn("jokers", serialize)

    def test_save_and_download_persist_image(self):
        save_fsa = _fn_body(self.js, "wireSaveFsa")
        download = _fn_body(self.js, "wireDownload")
        self.assertTrue(save_fsa, "wireSaveFsa must exist")
        self.assertTrue(download, "wireDownload must exist")
        self.assertIn("serializePool", save_fsa)
        self.assertIn("serializePool", download)
        self.assertIn("validatePool", save_fsa)
        self.assertIn("validatePool", download)


if __name__ == "__main__":
    unittest.main()
