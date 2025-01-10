--龙的群集
function c19000040.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,19000040+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19000040.target)
	e1:SetOperation(c19000040.activate)
	c:RegisterEffect(e1)
end
function c19000040.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
		and Duel.IsExistingMatchingCard(c19000040.filter2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,1,nil,c:GetCode(),e,tp)
end
function c19000040.filter2(c,code,e,tp)
	return c:IsCode(code) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19000040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19000040.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c19000040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19000040,0))
	Duel.SelectTarget(tp,c19000040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND)
end
function c19000040.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and e:GetHandler():IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c19000040.filter2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND,0,1,ft,nil,tc:GetCode(),e,tp)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DRAGON))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
