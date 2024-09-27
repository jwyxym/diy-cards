--瞬华微影·池上蜉蝣
function c11127178.initial_effect(c)
	--SpecialSummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1,11127178)
	e1:SetCost(c11127178.thcost)
	e1:SetTarget(c11127178.thtg)
	e1:SetOperation(c11127178.thop)
	c:RegisterEffect(e1) 
	--special summon
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,21127178)
	e2:SetCondition(c11127178.spcon)
	e2:SetTarget(c11127178.sptg)
	e2:SetOperation(c11127178.spop)
	c:RegisterEffect(e2)
end
function c11127178.ctfil(c) 
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() 
end
function c11127178.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127178.ctfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c11127178.ctfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c11127178.spfilter(c,e,tp)
	return c:IsSetCard(0xa62) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function c11127178.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127178.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
function c11127178.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11127178.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
	end 
	Duel.RegisterFlagEffect(tp,11127178,RESET_PHASE+PHASE_END,0,1)
end
function c11127178.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and Duel.GetFlagEffect(tp,11127178)==0 
end
function c11127178.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c11127178.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end 
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0) 
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end





