// gwang-editor: static, dependency-free editor for game/data/gwang_jokers.json
// (docs/feedback/INBOX.md item 23a — File API load + FSA direct save).
//
// Validation mirrors the catalog fields used by game/gwang_catalog.lua.

const KNOWN_RARITIES = ["common", "uncommon", "rare", "legendary"];
const KNOWN_TRIGGERS = [
  "always", "contains_kind", "yaku", "deck_size", "money", "blind", "once",
];
const KNOWN_EFFECT_KEYS = ["chips", "mult", "mult_mul", "money"];
const KNOWN_KINDS = ["hongdan", "cheongdan", "chodan", "godori", "pi"];
const KNOWN_BLINDS = ["small", "big", "boss"];
const KNOWN_YAKU = ["hongdan", "cheongdan", "chodan", "godori", "pi"];

/** @type {{jokers: Array<object>}|null} */
let pool = null;
let fileHandle = null;

const els = {};
function cacheEls() {
  ["openJsonInput", "openFsaBtn", "saveFsaBtn", "downloadBtn", "statusBar", "grid"]
    .forEach((id) => { els[id] = document.getElementById(id); });
}

function setStatus(message, kind) {
  els.statusBar.textContent = message;
  els.statusBar.className = "status" + (kind ? " " + kind : "");
}

function isNonEmptyString(v) {
  return typeof v === "string" && v.length > 0;
}

function isLocalized(v) {
  return v && typeof v === "object" && isNonEmptyString(v.ko) && isNonEmptyString(v.en);
}

function validatePool(doc) {
  const errors = [];
  if (!doc || typeof doc !== "object" || !Array.isArray(doc.jokers)) {
    return ["document must be an object with a 'jokers' array"];
  }
  const seenIds = new Set();
  doc.jokers.forEach((joker, index) => {
    const prefix = `joker #${index + 1} (${joker && joker.id ? joker.id : "?"})`;
    if (!joker || typeof joker !== "object") {
      errors.push(`${prefix}: is not an object`);
      return;
    }
    if (!isNonEmptyString(joker.id) || joker.id.indexOf(" ") >= 0) {
      errors.push(`${prefix}: missing non-empty id without spaces`);
    }
    if (!isLocalized(joker.name)) errors.push(`${prefix}: missing name.ko / name.en`);
    if (!KNOWN_RARITIES.includes(joker.rarity)) {
      errors.push(`${prefix}: unknown rarity '${joker.rarity}'`);
    }
    if (!KNOWN_TRIGGERS.includes(joker.trigger)) {
      errors.push(`${prefix}: unknown trigger '${joker.trigger}'`);
    }
    if (!joker.effect || typeof joker.effect !== "object") {
      errors.push(`${prefix}: missing effect object`);
    } else {
      const keys = Object.keys(joker.effect);
      if (keys.length === 0) errors.push(`${prefix}: effect must have at least one key`);
      keys.forEach((key) => {
        if (!KNOWN_EFFECT_KEYS.includes(key)) {
          errors.push(`${prefix}: unknown effect key '${key}'`);
        } else if (typeof joker.effect[key] !== "number" || Number.isNaN(joker.effect[key])) {
          errors.push(`${prefix}: effect.${key} must be numeric`);
        }
      });
    }
    if (!isLocalized(joker.desc)) errors.push(`${prefix}: missing desc.ko / desc.en`);
    if (joker.trigger === "contains_kind" && !KNOWN_KINDS.includes(joker.kind_need)) {
      errors.push(`${prefix}: missing kind_need`);
    }
    if (joker.trigger === "yaku" && !KNOWN_YAKU.includes(joker.yaku_need)) {
      errors.push(`${prefix}: missing yaku_need`);
    }
    if (joker.trigger === "deck_size" && typeof joker.deck_max !== "number") {
      errors.push(`${prefix}: missing deck_max`);
    }
    if (joker.trigger === "money" && typeof joker.money_min !== "number") {
      errors.push(`${prefix}: missing money_min`);
    }
    if (joker.trigger === "blind" && !KNOWN_BLINDS.includes(joker.blind_need)) {
      errors.push(`${prefix}: missing blind_need`);
    }
    if (joker.image != null && typeof joker.image !== "string") {
      errors.push(`${prefix}: image must be a string data URL`);
    }
    if (isNonEmptyString(joker.id)) {
      if (seenIds.has(joker.id)) errors.push(`duplicate joker id '${joker.id}'`);
      seenIds.add(joker.id);
    }
  });
  return errors;
}

function loadDocument(doc, name) {
  const errors = validatePool(doc);
  pool = doc;
  els.downloadBtn.disabled = false;
  if (errors.length > 0) {
    setStatus(`Loaded '${name}' but it failed validation:\n` + errors.join("\n"), "error");
  } else {
    setStatus(`Loaded '${name}' — ${doc.jokers.length} card(s), all valid.`, "ok");
  }
  renderGrid();
}

function readFileAsJson(file) {
  return file.text().then((text) => JSON.parse(text));
}

function wireOpenInput() {
  els.openJsonInput.addEventListener("change", () => {
    const file = els.openJsonInput.files[0];
    if (!file) return;
    readFileAsJson(file)
      .then((doc) => {
        fileHandle = null;
        els.saveFsaBtn.disabled = true;
        loadDocument(doc, file.name);
      })
      .catch((err) => setStatus(`Failed to parse '${file.name}': ${err.message}`, "error"));
  });
}

function wireOpenFsa() {
  els.openFsaBtn.addEventListener("click", async () => {
    if (!window.showOpenFilePicker) {
      setStatus("File System Access API not supported in this browser — use Open gwang_jokers.json instead.", "error");
      return;
    }
    try {
      const [handle] = await window.showOpenFilePicker({
        types: [{ description: "Gwang JSON", accept: { "application/json": [".json"] } }],
      });
      const file = await handle.getFile();
      const doc = await readFileAsJson(file);
      fileHandle = handle;
      els.saveFsaBtn.disabled = false;
      loadDocument(doc, file.name);
    } catch (err) {
      if (err.name !== "AbortError") setStatus(`Failed to open file: ${err.message}`, "error");
    }
  });
}

function serializePool() {
  return JSON.stringify(pool, null, 2) + "\n";
}

function wireSaveFsa() {
  els.saveFsaBtn.addEventListener("click", async () => {
    if (!fileHandle || !pool) return;
    const errors = validatePool(pool);
    if (errors.length > 0) {
      setStatus("Cannot save: pool has validation errors:\n" + errors.join("\n"), "error");
      return;
    }
    try {
      const writable = await fileHandle.createWritable();
      await writable.write(serializePool());
      await writable.close();
      setStatus("Saved to disk.", "ok");
    } catch (err) {
      setStatus(`Failed to save: ${err.message}`, "error");
    }
  });
}

function wireDownload() {
  els.downloadBtn.addEventListener("click", () => {
    if (!pool) return;
    const errors = validatePool(pool);
    if (errors.length > 0) {
      setStatus("Cannot download: pool has validation errors:\n" + errors.join("\n"), "error");
      return;
    }
    const blob = new Blob([serializePool()], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "gwang_jokers.json";
    a.click();
    URL.revokeObjectURL(url);
    setStatus("Downloaded gwang_jokers.json — move it into game/data/ to replace the original.", "ok");
  });
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function renderGrid() {
  if (!els.grid) return;
  if (!pool || !Array.isArray(pool.jokers)) {
    els.grid.innerHTML = "";
    return;
  }
  els.grid.innerHTML = pool.jokers.map((joker) => {
    const name = (joker.name && joker.name.en) || joker.id || "?";
    return `<article class="card"><div class="name">${escapeHtml(name)}</div></article>`;
  }).join("");
}

async function autoLoadDefaults() {
  const path = "../data/gwang_jokers.json";
  try {
    const resp = await fetch("../../game/data/gwang_jokers.json");
    if (resp.ok) {
      const doc = await resp.json();
      loadDocument(doc, "gwang_jokers.json");
      return;
    }
  } catch (_) { /* not served via HTTP, ignore */ }
  setStatus("Open a gwang_jokers.json file to begin. " + path);
}

function init() {
  cacheEls();
  wireOpenInput();
  wireOpenFsa();
  wireSaveFsa();
  wireDownload();
  autoLoadDefaults();
}

document.addEventListener("DOMContentLoaded", init);
