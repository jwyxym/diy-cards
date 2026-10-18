-- 暗夜织者的后厨 长腿
-- ID: 26052014
-- 字段：暗夜织者 0x912
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己场上有「暗夜织者」卡的场合，从墓地特召自身，之后可从卡组·墓地特召1只本家怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 解放自己场上1只昆虫族，检索本家魔陷
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

-- ① 条件：自己场上有「暗夜织者」卡
function s.fieldfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x912)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x912) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    -- 可选：从卡组·墓地特召1只本家
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- ②
function s.relfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsReleasable()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
    return c:IsSetCard(0x912) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end