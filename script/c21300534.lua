--末路的炎燚
function c21300534.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,21300534+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21300534.condition)
	e1:SetTarget(c21300534.target)
	e1:SetOperation(c21300534.activate)
	c:RegisterEffect(e1)
end
function c21300534.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x674) and c:IsType(TYPE_LINK+TYPE_XYZ+TYPE_SYNCHRO)
end
function c21300534.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c21300534.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c21300534.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.ndcon(tp,re) and Duel.GetMatchingGroupCount(c21300534.tdfilter,tp,LOCATION_MZONE,0,nil)>0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function c21300534.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function c21300534.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			local g=Duel.GetMatchingGroup(c21300534.tdfilter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
			if g:GetCount()>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=g:Select(tp,1,1,nil)
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end

