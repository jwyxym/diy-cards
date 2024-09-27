--最美最高贵的妖精
function c76200508.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--SpecialSummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,76200508+EFFECT_COUNT_CODE_OATH)   
	e1:SetCost(c76200508.cost) 
	e1:SetTarget(c76200508.sptg) 
	e1:SetOperation(c76200508.spop) 
	c:RegisterEffect(e1) 
	Duel.AddCustomActivityCounter(76200508,ACTIVITY_SPSUMMON,c76200508.counterfilter)
end
function c76200508.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT))
end
function c76200508.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(76200508,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c76200508.stgfil(c,e,tp) 
	return c:IsFaceup() and ((c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(8)) or c:IsCode(76200500)) and Duel.IsExistingMatchingCard(c76200508.spfil,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end 
function c76200508.spfil(c,e,tp,sc) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelBelow(sc:GetBaseAttack()) 
end 
function c76200508.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c76200508.stgfil,tp,LOCATION_MZONE,0,1,nil,e,tp) end 
	local tc=Duel.SelectTarget(tp,c76200508.stgfil,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst() 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK) 
end
function c76200508.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(c76200508.spfil,tp,LOCATION_DECK,0,1,nil,e,tp,tc) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		local sg=Duel.SelectMatchingCard(tp,c76200508.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc) 
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end 
end 



