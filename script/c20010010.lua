--
function c20010010.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,20010010)
	e1:SetCost(c20010010.cost)
	e1:SetTarget(c20010010.target)
	e1:SetOperation(c20010010.operation)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCost(c20010010.thcost)
	e2:SetTarget(c20010010.thtg)
	e2:SetOperation(c20010010.thop)
	c:RegisterEffect(e2)
end
function c20010010.rfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function c20010010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c20010010.rfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(tp,c20010010.rfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c20010010.filter(c,e,tp)
	return c:IsSetCard(0xb33) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20010010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c20010010.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE)
end
function c20010010.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20010010.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
function c20010010.thfilter(c)
	return c:IsSetCard(0xb33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c20010010.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20010010.thfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010010.thfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c20010010.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end