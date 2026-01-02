--流萤火
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SUMMON_SUCCESS)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.disable)
    e2:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e2,tp)
end
function s.disable(e,c)
    local tp=Duel.GetTurnPlayer()
    return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and c:IsControler(Duel.GetTurnPlayer()) and  Duel.GetFlagEffect(tp,id)==0
end
