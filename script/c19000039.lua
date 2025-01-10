--龙的启示
function c19000039.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19000039+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19000039.target)
	e1:SetOperation(c19000039.activate)
	c:RegisterEffect(e1)
end
function c19000039.thfilter(c,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(0) and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and (check or Duel.IsExistingMatchingCard(c19000039.thfilter2,tp,LOCATION_DECK,0,1,c,c:GetOriginalAttribute(),c:GetOriginalLevel()))
end
function c19000039.thfilter2(c,att,lv)
	return not c:IsRace(RACE_DRAGON) and c:GetOriginalAttribute()==att and c:GetOriginalLevel()==lv and c:IsAbleToHand()
end
function c19000039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000039.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
end
function c19000039.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19000039.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.ConfirmCards(1-tp,tc)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and tc:IsLocation(LOCATION_HAND)
			and Duel.IsExistingMatchingCard(c19000039.thfilter2,tp,LOCATION_DECK,0,1,nil,tc:GetOriginalAttribute(),tc:GetOriginalLevel()) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=Duel.SelectMatchingCard(tp,c19000039.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetOriginalAttribute(),tc:GetOriginalLevel())
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DRAGON))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

