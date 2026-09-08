local M = {}

M.domain = {
    planet = "기원패",
    tarot = "부적",
    tag = "패찰",
    voucher = "인장",
    arcana_pack = "부적 꾸러미",
    blind = "판",
    small_blind = "첫판",
    big_blind = "큰판",
    boss_blind = "대장판",
}

function M.ante(number)
    return tostring(number) .. "고"
end

function M.blind_name(kind)
    if kind == "small" then return M.domain.small_blind end
    if kind == "big" then return M.domain.big_blind end
    if kind == "boss" then return M.domain.boss_blind end
    return M.domain.blind
end

return M
