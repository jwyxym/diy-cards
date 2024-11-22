--
function c19990006.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c19990006.condition)
	e1:SetCountLimit(1,19990006)
	e1:SetCost(c19990006.cost)
	e1:SetTarget(c19990006.target)
	e1:SetOperation(c19990006.activate)
	c:RegisterEffect(e1)
end
function c19990006.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c19990006.cfilter(c)
	return c:IsSetCard(0xb29) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c19990006.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19990006.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,c19990006.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c19990006.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c19990006.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end