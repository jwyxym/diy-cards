--
function c20010039.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20010010,LOCATION_DECK+LOCATION_HAND)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,20010039+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c20010039.cost)
	e1:SetTarget(c20010039.target)
	e1:SetOperation(c20010039.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(20010039,ACTIVITY_SPSUMMON,c20010039.counterfilter)
	Duel.AddCustomActivityCounter(20010039,ACTIVITY_SUMMON,c20010039.counterfilter) 
end
function c20010039.counterfilter(c)
	return c:IsSetCard(0xb33)
end
function c20010039.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(20010039,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(20010039,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c20010039.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function c20010039.splimit(e,c)
	return not c:IsSetCard(0xb33)
end
function c20010039.spfilter(c,e,tp)
	return c:IsSetCard(0xb33) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:GetBaseAttack()==4000 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c20010039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,nil,tp,POS_FACEDOWN)
	if chk==0 then
		local g=Duel.GetMatchingGroup(c20010039.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function c20010039.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(c20010039.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local dg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,nil,tp,POS_FACEDOWN)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg and Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)>0 then
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
end