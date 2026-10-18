--吸血鬼的侍奉
function c11771430.initial_effect(c)
    -- 卡组检索
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(11771430,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,11771430)
    e1:SetTarget(c11771430.tg1)
    e1:SetOperation(c11771430.op1)
    c:RegisterEffect(e1)
    -- 特殊召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(11771430,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,11771431)
    e2:SetCondition(aux.exccon)
    e2:SetCost(c11771430.cost2)
    e2:SetTarget(c11771430.tg2)
    e2:SetOperation(c11771430.op2)
    c:RegisterEffect(e2)
end
-- 1
function c11771430.filter1(c)
    return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c11771430.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c11771430.filter1,tp,LOCATION_DECK,0,1,nil) 
        and Duel.CheckLPCost(tp,500) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c11771430.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.PayLPCost(tp,500)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c11771430.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
-- 2
function c11771430.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.CheckLPCost(tp,1000) end
    aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.PayLPCost(tp,1000)
end
function c11771430.filter2(c,e,tp)
    return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771430.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c11771430.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c11771430.op2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11771430.filter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
