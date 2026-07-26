--异质绝望 新月渚
function c35100151.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35100151,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35100151)
	e1:SetCost(c35100151.spcost)
	e1:SetTarget(c35100151.sptg)
	e1:SetOperation(c35100151.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100151,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,35100152)
	e2:SetTarget(c35100151.thtg)
	e2:SetOperation(c35100151.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function c35100151.cfilter(c,tp)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and c:IsAbleToRemoveAsCost()
	 and c:IsSetCard(0xa91) and c:IsType(TYPE_SPELL)
end
function c35100151.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100151.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c35100151.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c35100151.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c35100151.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c35100151.geffilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa91) and c:IsType(TYPE_LINK) and c:IsLinkAbove(2)
end
function c35100151.thfilter(c,check)
	return c:IsLevel(3) and c:IsAttack(0) and c:IsDefense(1800)
	 and (c:IsSetCard(0xa91) or check)
	 and not c:IsCode(35100151) and c:IsAbleToHand()
end
function c35100151.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
	local check=Duel.IsExistingMatchingCard(c35100151.geffilter,tp,LOCATION_MZONE,0,1,nil)
	return Duel.IsExistingMatchingCard(c35100151.thfilter,tp,LOCATION_DECK,0,1,nil,check) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c35100151.thop(e,tp,eg,ep,ev,re,r,rp)
  local check=Duel.IsExistingMatchingCard(c35100151.geffilter,tp,LOCATION_MZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c35100151.thfilter,tp,LOCATION_DECK,0,1,1,nil,check)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
