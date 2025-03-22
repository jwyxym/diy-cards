--大千录 蘭若度母
local this,id,ofs=GetID()
function this.initial_effect(c)
    local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_ACTIVATE)
    e:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(this.effval)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(this.effval)
	c:RegisterEffect(e5)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(this.dcost)
    e1:SetTarget(this.dtg)
    e1:SetOperation(this.dop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(this.descost)
    e2:SetTarget(this.destg)
    e2:SetOperation(this.desop)
    c:RegisterEffect(e2)
end
function this.effval(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return p==tp and tc:IsSetCard(0x3981) and tc:GetType()==TYPE_SPELL
end
function this.dfilter(c)
    return c:IsSetCard(0x3980) and c:IsReleasable()
end
function this.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function this.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,this.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,2,nil)
    Duel.Release(g,REASON_COST)
end
function this.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,0,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(this.filter,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(3000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
end
function this.dop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(this.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Damage(p,d,REASON_EFFECT)
    end
end
function this.desfilter(c)
    return c:IsSetCard(0x3981) and c:GetType()==TYPE_SPELL and c:IsAbleToRemoveAsCost()
end
function this.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.desfilter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,this.desfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function this.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Damage(tp,2000,REASON_EFFECT,true)
        Duel.Damage(1-tp,500,REASON_EFFECT,true)
        Duel.RDComplete()
    end
end
