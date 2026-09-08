// gwang-editor: static, dependency-free editor for game/data/gwang_jokers.json
// (docs/feedback/INBOX.md item 23f — catalog edit form).
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
const CARD_ASPECT = 2 / 3;
const CARD_ART_W = 240;
const CARD_ART_H = 360;

/** @type {{jokers: Array<object>}|null} */
let pool = null;
let fileHandle = null;
let selectedJokerId = null;

const els = {};
function cacheEls() {
  [
    "openJsonInput", "openFsaBtn", "saveFsaBtn", "downloadBtn", "statusBar", "grid",
    "editorEmpty", "editorForm", "cardId", "nameKo", "nameEn", "rarity", "trigger",
    "kindNeed", "yakuNeed", "deckMax", "moneyMin", "blindNeed",
    "effectChips", "effectMult", "effectMultMul", "descKo", "descEn",
  ]
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

function isImageDataUrl(v) {
  return typeof v === "string" && v.indexOf("data:image/") === 0 && v.indexOf(";base64,") > 0;
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
    if (joker.image != null && !isImageDataUrl(joker.image)) {
      errors.push(`${prefix}: image must be a base64 data URL`);
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
  selectedJokerId = null;
  els.downloadBtn.disabled = false;
  if (errors.length > 0) {
    setStatus(`Loaded '${name}' but it failed validation:\n` + errors.join("\n"), "error");
  } else {
    setStatus(`Loaded '${name}' — ${doc.jokers.length} card(s), all valid.`, "ok");
  }
  renderGrid();
  renderEditor();
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
  const documentToSave = {
    ...pool,
    jokers: pool.jokers.map((joker) => ({
      ...joker,
      ...(joker.image ? { image: joker.image } : {}),
    })),
  };
  return JSON.stringify(documentToSave, null, 2) + "\n";
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

function centerCropToCard(img) {
  const canvas = document.createElement("canvas");
  canvas.width = CARD_ART_W;
  canvas.height = CARD_ART_H;
  const srcW = img.naturalWidth || img.width;
  const srcH = img.naturalHeight || img.height;
  let sx = 0;
  let sy = 0;
  let sw = srcW;
  let sh = srcH;
  const srcAspect = srcW / srcH;
  if (srcAspect > CARD_ASPECT) {
    sw = srcH * CARD_ASPECT;
    sx = (srcW - sw) / 2;
  } else if (srcAspect < CARD_ASPECT) {
    sh = srcW / CARD_ASPECT;
    sy = (srcH - sh) / 2;
  }
  const ctx = canvas.getContext("2d");
  ctx.drawImage(img, sx, sy, sw, sh, 0, 0, CARD_ART_W, CARD_ART_H);
  return canvas.toDataURL("image/png");
}

function wireImageUploads() {
  if (!els.grid) return;
  els.grid.querySelectorAll(".card-image-input").forEach((input) => {
    input.addEventListener("change", () => {
      const file = input.files && input.files[0];
      if (!file || !pool) return;
      const id = input.getAttribute("data-id");
      const joker = pool.jokers.find((item) => item.id === id);
      if (!joker) return;
      const url = URL.createObjectURL(file);
      const img = new Image();
      img.onload = () => {
        joker.image = centerCropToCard(img);
        URL.revokeObjectURL(url);
        renderGrid();
        setStatus("Image saved as base64 data URL on JSON image field.", "ok");
      };
      img.onerror = () => {
        URL.revokeObjectURL(url);
        setStatus("Failed to load image.", "error");
      };
      img.src = url;
    });
  });
}

function formatEffectText(effect) {
  if (!effect || typeof effect !== "object") return "";
  const parts = [];
  if (Number.isFinite(effect.chips)) parts.push(`${effect.chips >= 0 ? "+" : ""}${effect.chips} chips`);
  if (Number.isFinite(effect.mult)) parts.push(`${effect.mult >= 0 ? "+" : ""}${effect.mult} mult`);
  if (Number.isFinite(effect.mult_mul)) parts.push(`×${effect.mult_mul} mult`);
  if (Number.isFinite(effect.money)) parts.push(`${effect.money >= 0 ? "+" : "-"}$${Math.abs(effect.money)}`);
  return parts.join(" · ");
}

function optionalNumber(input) {
  const value = input.value.trim();
  return value === "" ? undefined : Number(value);
}

function updateTriggerFields() {
  document.querySelectorAll("[data-trigger-field]").forEach((label) => {
    label.hidden = label.getAttribute("data-trigger-field") !== els.trigger.value;
  });
}

function renderEditor() {
  const joker = pool && pool.jokers.find((item) => item.id === selectedJokerId);
  els.editorEmpty.hidden = Boolean(joker);
  els.editorForm.hidden = !joker;
  if (!joker) return;
  els.cardId.value = joker.id;
  els.nameKo.value = joker.name.ko;
  els.nameEn.value = joker.name.en;
  els.rarity.value = joker.rarity;
  els.trigger.value = joker.trigger;
  els.kindNeed.value = joker.kind_need || "hongdan";
  els.yakuNeed.value = joker.yaku_need || "hongdan";
  els.deckMax.value = joker.deck_max == null ? "" : joker.deck_max;
  els.moneyMin.value = joker.money_min == null ? "" : joker.money_min;
  els.blindNeed.value = joker.blind_need || "small";
  els.effectChips.value = joker.effect.chips == null ? "" : joker.effect.chips;
  els.effectMult.value = joker.effect.mult == null ? "" : joker.effect.mult;
  els.effectMultMul.value = joker.effect.mult_mul == null ? "" : joker.effect.mult_mul;
  els.descKo.value = joker.desc.ko;
  els.descEn.value = joker.desc.en;
  updateTriggerFields();
}

function selectJoker(id) {
  selectedJokerId = id;
  renderGrid();
  renderEditor();
}

function wireCardSelection() {
  els.grid.querySelectorAll(".edit-card-btn").forEach((button) => {
    button.addEventListener("click", () => selectJoker(button.getAttribute("data-id")));
  });
}

function applyEditor(event) {
  event.preventDefault();
  if (!pool) return;
  const index = pool.jokers.findIndex((item) => item.id === selectedJokerId);
  if (index < 0) return;
  const original = pool.jokers[index];
  const effect = { ...original.effect };
  [
    ["chips", els.effectChips], ["mult", els.effectMult], ["mult_mul", els.effectMultMul],
  ].forEach(([key, input]) => {
    const value = optionalNumber(input);
    if (value == null) delete effect[key]; else effect[key] = value;
  });
  const candidate = {
    ...original,
    id: els.cardId.value.trim(),
    name: { ko: els.nameKo.value.trim(), en: els.nameEn.value.trim() },
    rarity: els.rarity.value,
    trigger: els.trigger.value,
    effect,
    desc: { ko: els.descKo.value.trim(), en: els.descEn.value.trim() },
  };
  delete candidate.kind_need;
  delete candidate.yaku_need;
  delete candidate.deck_max;
  delete candidate.money_min;
  delete candidate.blind_need;
  if (candidate.trigger === "contains_kind") candidate.kind_need = els.kindNeed.value;
  if (candidate.trigger === "yaku") candidate.yaku_need = els.yakuNeed.value;
  if (candidate.trigger === "deck_size") candidate.deck_max = optionalNumber(els.deckMax);
  if (candidate.trigger === "money") candidate.money_min = optionalNumber(els.moneyMin);
  if (candidate.trigger === "blind") candidate.blind_need = els.blindNeed.value;

  const draft = { ...pool, jokers: pool.jokers.slice() };
  draft.jokers[index] = candidate;
  const errors = validatePool(draft);
  if (errors.length > 0) {
    setStatus("Cannot apply changes:\n" + errors.join("\n"), "error");
    return;
  }
  pool = draft;
  selectedJokerId = candidate.id;
  renderGrid();
  renderEditor();
  setStatus(`Applied changes to '${candidate.id}'. Save or download JSON to persist them.`, "ok");
}

function wireEditor() {
  els.editorForm.addEventListener("submit", applyEditor);
  els.trigger.addEventListener("change", updateTriggerFields);
}

function renderGrid() {
  if (!els.grid) return;
  if (!pool || !Array.isArray(pool.jokers)) {
    els.grid.innerHTML = "";
    return;
  }
  els.grid.innerHTML = pool.jokers.map((joker) => {
    const name = (joker.name && joker.name.en) || joker.id || "?";
    const id = joker.id || "";
    const rarity = KNOWN_RARITIES.includes(joker.rarity) ? joker.rarity : "common";
    const effectText = formatEffectText(joker.effect);
    const art = joker.image
      ? `<img class="hwatu-art" alt="" src="${escapeHtml(joker.image)}">`
      : "";
    const selected = id === selectedJokerId ? " selected" : "";
    return `<article class="hwatu-card${selected}" data-id="${escapeHtml(id)}">${art}<div class="star">★</div><div class="rarity-ribbon ${rarity}">${escapeHtml(rarity)}</div><div class="card-overlay"><div class="name">${escapeHtml(name)}</div><div class="effect-text">${escapeHtml(effectText)}</div><div class="card-actions"><button class="edit-card-btn" type="button" data-id="${escapeHtml(id)}">Edit</button><label class="card-image-btn">Upload image<input class="card-image-input" type="file" accept="image/*" data-id="${escapeHtml(id)}" hidden></label></div></div></article>`;
  }).join("");
  wireImageUploads();
  wireCardSelection();
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
  wireEditor();
  autoLoadDefaults();
}

document.addEventListener("DOMContentLoaded", init);
