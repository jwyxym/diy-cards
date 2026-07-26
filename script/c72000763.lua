--零鸟姬 水风女精·零
function c72000763.initial_effect(c)
	aux.AddCodeList(c,72000753)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),4,2)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,72000763)
	e1:SetTarget(c72000763.target)
	e1:SetOperation(c72000763.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c72000763.val2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(c72000763.val)
	e3:SetTarget(c72000763.tg)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,72000764)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c72000763.spcon)
	e1:SetCost(c72000763.spcost)
	e1:SetTarget(c72000763.sptg)
	e1:SetOperation(c72000763.spop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(72000763,ACTIVITY_SPSUMMON,c72000763.counterfilter)
end
function c72000763.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_FAIRY | RACE_WINDBEAST | RACE_WARRIOR) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c72000763.cfilter(c)
	return (c:IsLevelBelow(5) and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WATER) or c:IsCode(72000753)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function c72000763.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c72000763.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c72000763.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c72000763.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
function c72000763.val(e,c)
	return Duel.GetOverlayCount(0,LOCATION_MZONE,LOCATION_MZONE)*100
end
function c72000763.val2(e,c)
	return -Duel.GetOverlayCount(0,LOCATION_MZONE,LOCATION_MZONE)*100
end
function c72000763.tg(e,c)
	return c:IsRace(RACE_FAIRY+RACE_WINDBEAST+RACE_WARRIOR)
end
function c72000763.spcfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsSetCard(0x48)
end
function c72000763.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c72000763.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c72000763.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(72000763,tp,ACTIVITY_SPSUMMON)==0 and e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c72000763.splimit)
	Duel.RegisterEffect(e1,tp)
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function c72000763.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_FAIRY+RACE_WINDBEAST+RACE_WARRIOR) and c:IsType(TYPE_XYZ))
end
function c72000763.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY+RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c72000763.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72000763.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c72000763.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c72000763.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
function c72000763.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	local tc=sg:GetFirst()
	while tc do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=sg:GetNext()
	end
	Duel.SpecialSummonComplete()
end
