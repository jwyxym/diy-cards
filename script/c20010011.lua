--
function c20010011.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20010010,LOCATION_DECK+LOCATION_HAND)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20010011+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c20010011.target)
	e1:SetOperation(c20010011.activate)
	c:RegisterEffect(e1)
end
function c20010011.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb33)
end
function c20010011.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20010011.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20010011.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c20010011.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c20010011.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()*2
		local def=tc:GetDefense()*2
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(def)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c20010011.efilter)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetRange(LOCATION_MZONE)
		e4:SetDescription(aux.Stringid(20010011,1))
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetOperation(c20010011.retop)
		tc:RegisterEffect(e4)
	end
end
function c20010011.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
function c20010011.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end