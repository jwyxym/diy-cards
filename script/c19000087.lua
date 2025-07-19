--邪魔显现
function c19000087.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19000087+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19000087.target)
	e1:SetOperation(c19000087.activate)
	c:RegisterEffect(e1)
end
function c19000087.filter(c)
	return aux.AtkEqualsDef(c) and c:IsLevel(9) and c:IsAbleToHand()
end
function c19000087.filter2(c)
	return c:IsCode(19000086) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c19000087.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000087.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c19000087.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19000087.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19000087.filter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19000087,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetReset(RESET_PHASE+PHASE_END)
	e0:SetTarget(c19000087.splimit)
	Duel.RegisterEffect(e0,tp)
end
function c19000087.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
