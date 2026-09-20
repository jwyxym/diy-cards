--爱丽丝，疯狂国度的纯真之梦
function c19991008.initial_effect(c)
	c:SetSPSummonOnce(19991008)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_GRAVE+LOCATION_MZONE)
	--direct attack
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e0)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19991008,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c19991008.discon1)
	e1:SetTarget(c19991008.negtg)
	e1:SetOperation(c19991008.negop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c19991008.discon2)
	c:RegisterEffect(e2)
end
function c19991008.filter(c)
	return c:IsCode(19991003) and c:IsFaceup()
end
function c19991008.discon1(e,tp,eg,ep,ev,re,r,rp)
    return not (Duel.IsExistingMatchingCard(c19991008.filter,tp,LOCATION_SZONE,0,1,e:GetHandler()) or Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,19991003))
end
function c19991008.discon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c19991008.filter,tp,LOCATION_SZONE,0,1,e:GetHandler()) or Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,19991003)
end
function c19991008.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c19991008.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
