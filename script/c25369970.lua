-- 《圣夜骑士团 诺埃尔》
-- 卡号：62355639
-- 字段：圣夜骑士 (0x159)
-- 属性：光 种族：天使族 等级：4 攻击：1400 守备：1100
local s,id=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    -- ① 手卡丢弃，从手卡特召光属性怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 场上有光属性天使族时，从手卡·墓地特召自身，那之后选发检索
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

-- ① Cost：丢弃自身
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- ① 特召过滤：手牌光属性怪兽（不能是自身）
function s.spfilter1(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

-- ② 条件：场上有光属性天使族怪兽
function s.spcon2(e,tp)
    return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter2(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end

-- ② Target：特召自身
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ② Operation：特召自身，那之后选发检索
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- ②检索过滤：圣夜骑士卡（排除自身）
function s.thfilter(c)
    return c:IsSetCard(SET_HOLY_NIGHT) and c:IsAbleToHand() and not c:IsCode(id)
end