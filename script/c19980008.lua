--
function c19980008.initial_effect(c)
	c:SetUniqueOnField(1,0,19980008)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetCountLimit(1,19980008+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(19980008,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetCost(c19980008.cost)
	e1:SetTarget(c19980008.target)
	e1:SetOperation(c19980008.activate)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetDescription(aux.Stringid(19980008,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c19980008.eqtg)
	e2:SetOperation(c19980008.eqop)
	c:RegisterEffect(e2)
	--avoid damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c19980008.condition)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(c19980008.damval)
	c:RegisterEffect(e3)
end
c19980008.has_text_type=TYPE_UNION
function c19980008.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
end
function c19980008.filter(c,e,tp)
	return c:IsSetCard(0xb34) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19980008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19980008.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c19980008.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19980008.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and aux.NecroValleyFilter()(tc) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end
function c19980008.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c19980008.eqfilter,tp,LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,tp)
end
function c19980008.eqfilter(c,tc,tp)
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION) and c:CheckUniqueOnField(tp) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK)) and not c:IsForbidden()
end
function c19980008.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19980008.tgfilter(chkc,tp) end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c19980008.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c19980008.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function c19980008.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c19980008.eqfilter,tp,LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,tp)
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
function c19980008.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)==1
end
function c19980008.damval(e,re,val,r,rp,rc)
	if val>=2000 then return 0 else return val end
end