local cm,m,o=GetID()
function cm.initial_effect(c)
    aux.AddLinkProcedure(c,cm.mat,2)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetCountLimit(1)
    e3:SetCondition(cm.con)
    e3:SetTarget(cm.tg)
    e3:SetOperation(cm.op)
    c:RegisterEffect(e3)
end
cm.mat = function (c)
    return c:IsLinkRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
cm.con = function (e,tp,eg,ep,ev,re,r,rp)
    return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()
end
cm.tg = function (e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
end
cm.op = function (e,tp,eg,ep,ev,re,r,rp)
    Debug.Message('无用的关心……我不需要！')
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
    if #g>0 then
        for tc in aux.Next(g) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
            tc:RegisterEffect(e1,true)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_CANNOT_TRIGGER)
            tc:RegisterEffect(e2,true)
        end
    end
end