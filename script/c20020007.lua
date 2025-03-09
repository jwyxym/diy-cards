--
function c20020007.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_ATKCHANGE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(TIMING_DAMAGE_STEP)
	e0:SetCondition(aux.dscon)
	e0:SetTarget(c20020007.target)
	e0:SetOperation(c20020007.activate)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20020007)
	e1:SetTarget(c20020007.tgtg)
	e1:SetOperation(c20020007.tgop)
	c:RegisterEffect(e1)
	c20020007.sps_effect=e1
	--Effect monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
end
function c20020007.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb35)
end
function c20020007.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20020007.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20020007.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c20020007.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c20020007.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function c20020007.tgfilter(c)
	return c:IsSetCard(0xb35) and c:IsAbleToGrave()
end
function c20020007.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20020007.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c20020007.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c20020007.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
