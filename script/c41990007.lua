--路观大王
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsAttribute,ATTRIBUTE_WATER),nil,nil,aux.FilterBoolFunction(s.synfilter),1,99)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.negcon)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetTarget(s.tg)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.rmcon)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end


function s.synfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsType(TYPE_MONSTER)
end


function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
    and Duel.IsChainNegatable(ev)
    and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	seq=math.log(seq,2)
	Duel.MoveSequence(c,seq)
    Duel.NegateActivation(ev)
end


function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.e2op)
    e1:SetReset(RESET_CHAIN)
    tc:RegisterEffect(e1)
end
function s.e2op(e,te)
    return te:GetHandler()~=e:GetHandler() 
end


function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainDisablable(ev)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CHAIN_END)
        e1:SetLabelObject(c)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1,tp)
    end
    if rc and rc:IsRelateToEffect(re) then
        Duel.Destroy(rc,REASON_EFFECT)
    end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    if c and c:IsLocation(LOCATION_REMOVED) then
        Duel.ReturnToField(c)
    end
end