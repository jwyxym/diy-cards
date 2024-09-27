--五十巫师无视舞狮误事
function c11100105.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11100105+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c11100105.cost)
	e1:SetTarget(c11100105.target)
	e1:SetOperation(c11100105.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c11100105.handcon)
	c:RegisterEffect(e2)
end
function c11100105.hcfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_FIRE)) or (c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_DARK))
end
function c11100105.handcon(e)
	return Duel.IsExistingMatchingCard(c11100105.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c11100105.cfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c11100105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11100105.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c11100105.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c11100105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c11100105.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function c11100105.filter3(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11100105.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
		if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(c11100105.filter2,1-tp,LOCATION_ONFIELD,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(c11100105.filter3,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(11100105,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=Duel.SelectMatchingCard(tp,c11100105.filter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			end
			Duel.SpecialSummonComplete()
	end
end

	

