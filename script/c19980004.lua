--
function c19980004.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(c19980004.cost)
	e0:SetTarget(c19980004.target)
	e0:SetOperation(c19980004.activate)
	e0:SetCountLimit(1,19980003+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c19980004.eqtg)
	e1:SetOperation(c19980004.eqop)
	c:RegisterEffect(e1)
end
c19980004.has_text_type=TYPE_UNION
function c19980004.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
end
function c19980004.filter(c)
	return c:IsSetCard(0xb34) and c:IsAbleToHand()
end
function c19980004.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19980004.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c19980004.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19980004.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19980004.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19980004.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c19980004.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_FISH)
end
function c19980004.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c19980004.eqfilter,tp,LOCATION_REMOVED+LOCATION_DECK,0,1,nil,c,tp)
end
function c19980004.eqfilter(c,tc,tp)
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
		and c:IsRace(RACE_FISH) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c19980004.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19980004.tgfilter(chkc,tp) end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c19980004.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c19980004.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED+LOCATION_DECK)
end
function c19980004.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c19980004.eqfilter,tp,LOCATION_REMOVED+LOCATION_DECK,0,1,1,nil,tc,tp)
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
