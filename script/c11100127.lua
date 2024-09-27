--霸影灵的呼唤
local cm,m,o=GetID()
function cm.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(cm.cost)
    e1:SetTarget(cm.target)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCost(aux.bfgcost)
    e2:SetCondition(cm.tgcon)
    e2:SetTarget(cm.tgtg)
    e2:SetOperation(cm.tgop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(m,0))
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e3:SetCondition(cm.handcon)
    c:RegisterEffect(e3)
end
function cm.cfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.filter(c)
    return c:IsFaceup() and c:IsSetCard(0xa64) and c:IsAbleToGrave()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,2,2,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,g1:GetCount(),0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    Duel.SendtoGrave(sg,REASON_EFFECT)
end
function cm.tgcfilter(c,tp)
    return c:IsSetCard(0xa64) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and c:IsFaceup()
end
function cm.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(cm.tgcfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function cm.tgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xa64) and c:IsType(TYPE_MONSTER)
end
function cm.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and cm.tgfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cm.tgfilter,tp,LOCATION_REMOVED,0,3,nil) end
    local g=Duel.SelectTarget(tp,cm.tgfilter,tp,LOCATION_REMOVED,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,3,0,0)
end
function cm.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
    end
end
function cm.handcon(e)
    return Duel.IsExistingMatchingCard(cm.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.handfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end