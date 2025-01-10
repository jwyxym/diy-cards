--
function c19980006.initial_effect(c)
	c:SetUniqueOnField(1,0,19980006)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,19980006+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(c19980006.activate)
	c:RegisterEffect(e0)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c19980006.eqtg)
	e1:SetOperation(c19980006.eqop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(c19980006.condition)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb34))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb34))
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
c19980006.has_text_type=TYPE_UNION
function c19980006.thfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToHand()
end
function c19980006.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19980006.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19980006,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19980006.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function c19980006.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_FISH)
end
function c19980006.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c19980006.eqfilter,tp,LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,tp)
end
function c19980006.eqfilter(c,tc,tp)
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION) and c:CheckUniqueOnField(tp) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK)) and not c:IsForbidden()
end
function c19980006.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19980006.tgfilter(chkc,tp) end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c19980006.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c19980006.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function c19980006.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c19980006.eqfilter,tp,LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,tp)
		local ec=g:GetFirst()
		if ec and aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
			aux.SetUnionState(ec)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_SZONE)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ec:RegisterEffect(e1)
		end
	end
end
function c19980006.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)==1
end