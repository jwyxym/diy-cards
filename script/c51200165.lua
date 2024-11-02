--见切
function c51200165.initial_effect(c)
	--三色康
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,51200165)
	e1:SetCondition(c51200165.condition)
	e1:SetTarget(c51200165.target)
	e1:SetOperation(c51200165.activate)
	c:RegisterEffect(e1)
end
	function c51200165.actcfilter(c)
	return c:IsSetCard(0x65d) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
	function c51200165.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(c51200165.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
	function c51200165.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
	function c51200165.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end