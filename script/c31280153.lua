--戈尔贡之牙
function c31280153.initial_effect(c)
	aux.AddCodeList(c,31280146)
	--发动    
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280153,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31280153+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31280153.target)
	e1:SetOperation(c31280153.activate)
	c:RegisterEffect(e1)
end
function c31280153.spfilter(c,e,tp)
	return c:IsFaceupEx() and (c:IsCode(31280146) or aux.IsCodeListed(c,31280146)) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c31280153.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280153.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280153.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31280153.defilter(c,tp)
	return c:IsFaceup() and c:IsCode(31280146) and c:GetOriginalType()&TYPE_MONSTER>0
end
function c31280153.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(c31280153.defilter,tp,LOCATION_ONFIELD,0,1,nil) 
        and Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)>0
		and Duel.SelectYesNo(tp,aux.Stringid(31280153,1)) then
		Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,c31280153.defilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.HintSelection(g)		
        if Duel.Destroy(g,REASON_EFFECT)>0 then
        	local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
            if #sg>0 then
					Duel.BreakEffect()
					Duel.HintSelection(sg)
					Duel.Destroy(sg,REASON_EFFECT)
			end                    
		end                    
	end        
end