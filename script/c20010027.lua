--
function c20010027.initial_effect(c)
    --change code
    aux.EnableChangeCode(c,20010010,LOCATION_DECK+LOCATION_HAND)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetDescription(aux.Stringid(20010027,0))
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,20010027)
    e1:SetCost(c20010027.cost1)
    e1:SetTarget(c20010027.tg)
    e1:SetOperation(c20010027.op)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetDescription(aux.Stringid(20010027,1))
    e2:SetCost(c20010027.cost2)
    c:RegisterEffect(e2)
    --act in hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e3:SetCondition(c20010027.handcon)
    c:RegisterEffect(e3)
end
function c20010027.cfilter(c)
    return c:IsSetCard(0xb33) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c20010027.ccfilter(c)
    return c:IsCode(20010010) and not c:IsPublic()
end
function c20010027.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c20010027.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c20010027.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010027.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c20010027.ccfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,c20010027.ccfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
end
function c20010027.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c20010027.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
function c20010027.handcon(e)
    return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end