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


if __name__ == "__main__":
    unittest.main()
