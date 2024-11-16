--Super-PLU-Infection
function c20100011.initial_effect(c)
	--act in hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e0:SetCondition(c20100011.handcon)
	c:RegisterEffect(e0)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20100011)
	e1:SetTarget(c20100011.target)
	e1:SetOperation(c20100011.operation)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c20100011.reptg)
	e2:SetValue(c20100011.repval)
	e2:SetOperation(c20100011.repop)
	c:RegisterEffect(e2)
end
function c20100011.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb28)
end
function c20100011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20100011.filter,tp,LOCATION_ONFIELD,0,1,nil) end
end
function c20100011.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c20100011.filter,tp,LOCATION_ONFIELD,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c20100011.efilter)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function c20100011.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
function c20100011.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb28)
end
function c20100011.handcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c20100011.cfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function c20100011.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb28) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function c20100011.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c20100011.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c20100011.repval(e,c)
	return c20100011.repfilter(c,e:GetHandlerPlayer())
end
function c20100011.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end