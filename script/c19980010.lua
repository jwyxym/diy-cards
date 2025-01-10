--
function c19980010.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c19980010.condition)
	e1:SetTarget(c19980010.target)
	e1:SetOperation(c19980010.activate)
	e1:SetCountLimit(1,19980010+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19980010.eqtg)
	e2:SetOperation(c19980010.eqop)
	c:RegisterEffect(e2)
end
c19980010.has_text_type=TYPE_UNION
function c19980010.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
function c19980010.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19980010.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c19980010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	if Duel.GetLP(tp)==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(c19980010.chainlm)
	end
end
function c19980010.chainlm(e,rp,tp)
	return tp==rp
end
function c19980010.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c19980010.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,ct,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function c19980010.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c19980010.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,tp)
end
function c19980010.eqfilter(c,tc,tp)
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION) and c:IsRace(RACE_FISH) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c19980010.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19980010.tgfilter(chkc,tp) end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c19980010.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c19980010.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c19980010.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c19980010.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,tp)
		local ec=g:GetFirst()
		if ec and aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
			aux.SetUnionState(ec)
		end
	end
end
