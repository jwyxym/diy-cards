-- 露法丝的参谋·迪娜
-- id: 71000260

local s, id = GetID()

function s.initial_effect(c)
    -- ①：自己主要阶段，自己场上没有怪兽存在，或者有「露法丝·玛法尔」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION) -- 起动效果，默认主阶段
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id) -- ①效果单独的1回合1次
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「女神的魔法」卡加入手卡。
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 1) -- 与③共用限制，实现二选一
    e2:SetTarget(s.thtg1)
    e2:SetOperation(s.thop1)
    c:RegisterEffect(e2)

    -- ③：自己主要阶段，自己场上有「露法丝·玛法尔」怪兽存在的场合才能发动。从卡组把1只「十二星天」怪兽加入手卡。
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 1) -- 与②共用限制
    e3:SetCondition(s.thcon2)
    e3:SetTarget(s.thtg2)
    e3:SetOperation(s.thop2)
    c:RegisterEffect(e3)
end

-- 「露法丝·玛法尔」的判定（包含普通版和霸王版）
function s.lufas_filter(c)
    return c:IsCode(71000242) or c:IsCode(71010248)
end

-- ① 特召条件
function s.spcon(e, c)
    local tp = e:GetHandler():GetControler()
    -- 自己场上没有怪兽存在，或者有「露法丝·玛法尔」怪兽存在
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 
        or Duel.IsExistingMatchingCard(s.lufas_filter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ① 特召目标
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

-- ① 特召操作
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- ②「女神的魔法」检索 (字段 3e13)
function s.thfilter1(c)
    return c:IsSetCard(0x3e13) and c:IsAbleToHand() 
end

function s.thtg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter1, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop1(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter1, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

-- ③ 发动条件
function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.lufas_filter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ③「十二星天」检索 (字段 3e14)
function s.thfilter2(c)
    return c:IsSetCard(0x3e14) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop2(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end