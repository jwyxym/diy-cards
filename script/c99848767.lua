-- 苦命鸳鸯
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.matfilter(c,e,tp,fc)
	return aux.IsMaterialListCode(fc,c:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.fusionfilter(c,e,tp)
	if not c:IsType(TYPE_FUSION) then return false end
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil,e,tp,c)
	return g:GetCount()>=2
end

function s.zonecheck(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not s.zonecheck(tp) then return false end
		return Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not s.zonecheck(tp) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fc=Duel.SelectMatchingCard(tp,s.fusionfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not fc then return end

	Duel.ConfirmCards(1-tp,fc)

	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil,e,tp,fc)
	if mg:GetCount()<2 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=mg:Select(tp,2,2,nil)
	if sg:GetCount()<2 then return end

	local tc1=sg:GetFirst()
	local tc2=sg:GetNext()

	if tc1==tc2 then return end


	local success1 = Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	local success2 = Duel.SpecialSummonStep(tc2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)

	if success1 and success2 then
		Duel.SpecialSummonComplete()
	 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)  
		tc1:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)

   
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e3)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e4)
   
	else
		Duel.SpecialSummonCancel()
	 
	end
end