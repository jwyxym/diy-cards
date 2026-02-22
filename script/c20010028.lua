--
function c20010028.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20010010,LOCATION_DECK+LOCATION_HAND)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,20010028+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c20010028.cost)
	e1:SetTarget(c20010028.target)
	e1:SetOperation(c20010028.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(20010028,ACTIVITY_SPSUMMON,c20010028.counterfilter)
end
function c20010028.counterfilter(c)
	return c:IsSetCard(0xb33)
end
function c20010028.rfilter(c,tp)
	return c:IsFaceup() and c:IsAttackPos() and Duel.GetMZoneCount(tp,c)>0
end
function c20010028.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(c20010028.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c20010028.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c20010028.filter(c,e,tp)
	return c:IsSetCard(0xb33) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20010028.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c20010028.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c20010028.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20010028.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end