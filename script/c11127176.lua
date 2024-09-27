--瞬华白花·月下梦昙
function c11127176.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1,11127176)
	e1:SetCost(c11127176.thcost)
	e1:SetTarget(c11127176.thtg)
	e1:SetOperation(c11127176.thop)
	c:RegisterEffect(e1) 
	--special summon
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,21127176)
	e2:SetCondition(c11127176.spcon)
	e2:SetTarget(c11127176.sptg)
	e2:SetOperation(c11127176.spop)
	c:RegisterEffect(e2)
end
function c11127176.ctfil(c) 
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() 
end
function c11127176.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127176.ctfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c11127176.ctfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c11127176.thfilter(c)
	return c:IsSetCard(0xa62) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c11127176.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127176.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c11127176.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11127176.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end 
	Duel.RegisterFlagEffect(tp,11127176,RESET_PHASE+PHASE_END,0,1)
end
function c11127176.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and Duel.GetFlagEffect(tp,11127176)==0 
end
function c11127176.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c11127176.spop(e,tp,eg,ep,ev,re,r,rp)
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



