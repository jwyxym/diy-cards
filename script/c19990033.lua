--
function c19990033.initial_effect(c)
	c:SetUniqueOnField(1,0,19990033)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990033,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,19990033+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c19990033.cost)
	e1:SetTarget(c19990033.target)
	e1:SetOperation(c19990033.activate)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990033,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,19990033+100)
	e2:SetCondition(c19990033.thcon1)
	e2:SetTarget(c19990033.sptg)
	e2:SetOperation(c19990033.spop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990033,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,19990033+100)
	e3:SetCondition(c19990033.thcon2)
	e3:SetTarget(c19990033.sptg)
	e3:SetOperation(c19990033.spop)
	c:RegisterEffect(e3)
end
function c19990033.costfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsSetCard(0xb29) and c:IsAbleToGraveAsCost()
end
function c19990033.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990033.costfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19990033.costfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c19990033.rmfilter(c)
	return c:IsSetCard(0xb30) and c:IsAbleToRemove()
end
function c19990033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990033.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.GetMatchingGroup(c19990033.rmfilter,tp,LOCATION_DECK,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c19990033.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19990033.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function c19990033.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xb29)
end
function c19990033.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990033.cfilter1,1,nil,tp)
end
function c19990033.cfilter2(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsSetCard(0xb29,0xb30)
end
function c19990033.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990033.cfilter2,1,nil,tp)
end
function c19990033.filter(c,e,tp)
	return c:IsSetCard(0xb29) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19990033.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19990033.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c19990033.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19990033.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

