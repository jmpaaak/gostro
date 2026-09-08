local terms = require("game.terms")

local M = {}

function M.run()
    assert(terms.domain.planet == "기원패")
    assert(terms.domain.tarot == "부적")
    assert(terms.domain.tag == "패찰")
    assert(terms.domain.voucher == "인장")
    assert(terms.domain.arcana_pack == "부적 꾸러미")
    
    assert(terms.ante(1) == "1고")
    assert(terms.ante(8) == "8고")
    
    assert(terms.blind_name("small") == "첫판")
    assert(terms.blind_name("big") == "큰판")
    assert(terms.blind_name("boss") == "대장판")
    assert(terms.blind_name("unknown") == "판")
    
    print("  terms: OK")
end

return M
