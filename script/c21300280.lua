--晨跃 恒久之光
function c21300280.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c21300280.mfilter,2,99)
	c:EnableReviveLimit()   
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1) 
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21300280,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21300280)
	e2:SetCondition(c21300280.spcon) 
	e2:SetTarget(c21300280.sptg)
	e2:SetOperation(c21300280.spop)
	c:RegisterEffect(e2)
end
function c21300280.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_WIND) or c:IsLinkRace(RACE_CYBERSE)
end
function c21300280.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end 
function c21300280.spfilter(c,e,tp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	return c:IsSetCard(0x677) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function c21300280.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c21300280.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c21300280.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	local tc=Duel.SelectMatchingCard(tp,c21300280.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then  
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)~=0 and c:IsRelateToEffect(e) then 
			local e1=Effect.CreateEffect(c) 
			e1:SetType(EFFECT_TYPE_SINGLE) 
			e1:SetCode(EFFECT_UPDATE_ATTACK) 
			e1:SetRange(LOCATION_MZONE) 
			e1:SetValue(1200) 
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) 
			c:RegisterEffect(e1) 
		end 
	end 
end





