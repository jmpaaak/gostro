-- Canonical player-facing vocabulary for Gostro.
-- Internal/save identifiers may remain legacy keys; render them through display().
local M = {}

M.labels = {
    wish_card = "기원패",
    talisman = "부적",
    plaque = "패찰",
    seal = "인장",
    talisman_bundle = "부적 꾸러미",
    round = "판",
    opening = "첫판",
    main = "큰판",
    final = "대장판",
    go = "고",
}

M.aliases = {
    planet = "wish_card",
    planets = "wish_card",
    tarot = "talisman",
    tarots = "talisman",
    tag = "plaque",
    tags = "plaque",
    voucher = "seal",
    vouchers = "seal",
    arcana = "talisman_bundle",
    arcana_pack = "talisman_bundle",
    blind = "round",
    blinds = "round",
    small = "opening",
    big = "main",
    boss = "final",
    ante = "go",
}

-- Compatibility projection for callers introduced during the migration.
M.domain = {
    planet = M.labels.wish_card,
    tarot = M.labels.talisman,
    tag = M.labels.plaque,
    voucher = M.labels.seal,
    arcana_pack = M.labels.talisman_bundle,
    blind = M.labels.round,
    small_blind = M.labels.opening,
    big_blind = M.labels.main,
    boss_blind = M.labels.final,
}

local ROUND_NAMES = {
    ko = {
        small = M.labels.opening,
        big = M.labels.main,
        boss = M.labels.final,
    },
    en = {
        small = "Opening Round",
        big = "Main Round",
        boss = "Final Round",
    },
}

function M.canonical_key(key)
    local canonical = M.aliases[key] or key
    if M.labels[canonical] == nil then
        error("unknown term: " .. tostring(key), 2)
    end
    return canonical
end

function M.display(key)
    return M.labels[M.canonical_key(key)]
end

function M.round_name(kind, locale)
    local names = ROUND_NAMES[locale or "ko"] or ROUND_NAMES.ko
    return names[kind] or kind
end

function M.go_label(go, locale)
    if locale == "en" then
        return "Go " .. tostring(go)
    end
    return tostring(go) .. M.labels.go
end

-- Legacy migration API retained for main-branch callers.
M.ante = M.go_label

function M.blind_name(kind)
    local name = M.round_name(kind)
    return name == kind and M.labels.round or name
end

return M
