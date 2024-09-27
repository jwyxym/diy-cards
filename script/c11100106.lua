--舞狮雾时误食武士巫师
function c11100106.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11100106+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11100106.target)
	e1:SetOperation(c11100106.activate)
	e1:SetCost(c11100106.cost)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c11100106.handcon)
	c:RegisterEffect(e2)
end
function c11100106.hcfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_DARK) and not (not c:IsRace(RACE_BEAST) and not c:IsAttribute(ATTRIBUTE_DARK))
end
function c11100106.handcon(e)
	return Duel.IsExistingMatchingCard(c11100106.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) or Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
function c11100106.cfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c11100106.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11100106.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c11100106.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c11100106.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,RACE_WARRIOR+RACE_SPELLCASTER)>=2 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_CONTROL)
	end
end
function c11100106.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly()
		if Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,RACE_WARRIOR+RACE_SPELLCASTER)>=2
			and tc:IsDisabled() and tc:IsControler(1-tp) and tc:IsControlerCanBeChanged()
			and Duel.SelectYesNo(tp,aux.Stringid(11100106,0)) then
			Duel.BreakEffect()
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end




