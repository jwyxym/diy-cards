--最后的度假胜地
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetCondition(this.acon)
    e1:SetTarget(this.atg)
    e1:SetValue(this.aval)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,this.regfilter)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(this.bcon)
    e2:SetTarget(this.btg)
    e2:SetOperation(this.bop)
    c:RegisterEffect(e2)
end
function this.acon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function this.atg(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER)
end
function this.aval(e,c)
    local tp=e:GetHandlerPlayer()
    return math.floor((Duel.GetLP(1-tp)-Duel.GetLP(tp))/1000)*300
end
function this.regfilter(e)
    local c=e:GetHandler()
    return not (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x723))
end
function this.bfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function this.bcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>=5
end
function this.btg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.bfilter,tp,LOCATION_MZONE,0,1,nil) end
    local g=Duel.GetMatchingGroup(this.bfilter,tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,1200)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function this.bop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(this.bfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e2:SetRange(LOCATION_MZONE)
        e2:SetValue(1)
        tc:RegisterEffect(e2)
    end
    if #g>0 then
        Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
    end
end
