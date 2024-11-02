--无 尽 幻 梦
local cm,m,o=GetID()
function cm.initial_effect(c)
    aux.AddCodeList(c,11100130)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DRAW+CATEGORY_DICE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.condition)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,0))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(cm.handcon)
    c:RegisterEffect(e2)
end
function cm.handfilter(c)
    return c:IsFaceup() and c:IsCode(11100130)
end
function cm.handcon(e)
    return Duel.IsExistingMatchingCard(cm.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.cfilter(c)
    return c:IsFaceup() and c:IsCode(11100130)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local dc=0
    local ct=0
    for i=1,5,1 do
        local a=Duel.TossDice(tp,1)
        dc=dc+a
        if a==1 or a==5 then ct=ct+1 end
    end
    if dc==5 then
        Duel.Draw(1-tp,5,REASON_EFFECT)
        Duel.BreakEffect()
        Duel.Draw(tp,2,REASON_EFFECT)
    elseif dc==30 then
        Duel.Draw(tp,5,REASON_EFFECT)
        Duel.Draw(1-tp,2,REASON_EFFECT)
        Duel.BreakEffect()
        local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    else
        Duel.Damage(1-tp,dc*100,REASON_EFFECT)
        Duel.BreakEffect()
        if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end