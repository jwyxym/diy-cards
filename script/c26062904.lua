-- 碰面 椎名立希
-- ID: 26062904
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- ① 不入连锁的墓地特殊召唤（1回合仅1次）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon1)
    c:RegisterEffect(e1)

    -- ② 被从牌组以外的地方送墓时，检索战士族以外的记述「春日影」怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end

-- ① 条件：自己场上存在“春日影”或记述「春日影」卡名的卡，且主怪兽区有空位
function s.fieldfilter(c)
    return c:IsFaceup() and (c:IsCode(26062911) or aux.IsCodeListed(c,26062911))
end
function s.spcon1(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
end

-- ② 条件：从牌组以外的地方送墓
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

-- ② 检索对象：记述「春日影」的怪兽，且战士族以外
function s.tgfilter(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end