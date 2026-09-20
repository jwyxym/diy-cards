--疯狂梦境的初遇
function c19991029.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,19991029+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19991029.condition)
	e1:SetTarget(c19991029.target)
	e1:SetOperation(c19991029.activate)
	c:RegisterEffect(e1)
end
function c19991029.cfilter(c)
	return c:IsSetCard(0xb31) and c:IsFaceup() and c:IsLevel(3) and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT))
end
function c19991029.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19991029.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c19991029.filter(c)
	return c:IsSetCard(0xb31,0xb32) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function c19991029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19991029.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c19991029.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19991029.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

