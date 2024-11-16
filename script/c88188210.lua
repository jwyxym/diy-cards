--Numerical solution construction
function c88188210.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88188210+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c88188210.target)
	e1:SetOperation(c88188210.activate)
	c:RegisterEffect(e1)
end
c88188210.SetCard_Numerical_Crack=true 
function c88188210.filter(c,e,tp)
	local lv=c:GetOriginalLevel()
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_CYBERSE) and c:IsReleasable()
		and Duel.IsExistingMatchingCard(c88188210.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
function c88188210.filter1(c,e,tp,lv)
	local clv=c:GetOriginalLevel()
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(c88188210.filter2,tp,LOCATION_GRAVE,0,1,c,e,tp,lv,clv)
end
function c88188210.filter2(c,e,tp,lv,clv)
	local slv=c:GetOriginalLevel()
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and clv+slv==lv
end
function c88188210.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c88188210.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c88188210.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function c88188210.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local lv=tc:GetOriginalLevel()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if Duel.Release(tc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88188210.filter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
		local ctc=g:GetFirst()
		local clv=ctc:GetOriginalLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88188210.filter2),tp,LOCATION_GRAVE,0,1,1,ctc,e,tp,lv,clv)
		g:Merge(g1)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end