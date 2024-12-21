--尸朽之墓园
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FIEND),2,2,this.lcheck)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(this.discon)
    e2:SetCost(this.discost)
	e2:SetTarget(this.distg)
	e2:SetOperation(this.disop)
	c:RegisterEffect(e2)
end
function this.lfilter(c)
	return c:IsLinkType(TYPE_SYNCHRO)
end
function this.lcheck(g)
	return g:IsExists(this.lfilter,1,nil)
end
function this.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(Card.IsControler,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function this.disfilter(c)
    return c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end
function this.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.disfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,this.disfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function this.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function this.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
