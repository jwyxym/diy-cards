--刀袭
function c51200190.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,51200190)
	e1:SetCondition(c51200190.condition)
	e1:SetTarget(c51200190.target)
	e1:SetOperation(c51200190.activate)
	c:RegisterEffect(e1)
end
	function c51200190.actcfilter(c)
	return c:IsSetCard(0x65d) and c:IsLocation(LOCATION_MZONE)
end
	function c51200190.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c51200190.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
	function c51200190.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	function c51200190.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c51200190.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c51200190.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c51200190.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_ALL,LOCATION_MZONE)
end
	function c51200190.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
	function c51200190.fselect(g)
	return g:GetClassCount(Card.GetControler)==g:GetCount() and g:IsExists(c51200190.fcheck,1,nil,g)
end
	function c51200190.fcheck(c,g)
	return g:IsExists(Card.IsRace,1,c,c:GetRace()) or g:IsExists(Card.IsAttribute,1,c,c:GetAttribute())
end
	function c51200190.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local res=false
	if tc:IsRelateToEffect(e) then
		res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		if res then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
	if res then
		local g=Duel.GetMatchingGroup(c51200190.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:CheckSubGroup(c51200190.fselect,2,2) and Duel.SelectYesNo(tp,aux.Stringid(51200190,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g:SelectSubGroup(tp,c51200190.fselect,false,2,2)
			Duel.HintSelection(sg)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end