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

return M
