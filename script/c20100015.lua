--
function c20100015.initial_effect(c)
	c:SetUniqueOnField(1,0,20100015)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,20100015+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20100015.tg)
	e1:SetOperation(c20100015.act)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_DECK)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTarget(c20100015.rmtg)
	c:RegisterEffect(e2)
end
function c20100015.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
function c20100015.act(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		 Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		 local e1=Effect.CreateEffect(e:GetHandler())
		 e1:SetType(EFFECT_TYPE_SINGLE)
		 e1:SetCode(EFFECT_DISABLE)
		 e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		 e1:SetTarget(c20100015.distarget)
		 tc:RegisterEffect(e1)
		 local e2=Effect.CreateEffect(e:GetHandler())
		 e2:SetType(EFFECT_TYPE_SINGLE)
		 e2:SetCode(EFFECT_DISABLE_EFFECT)
		 e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		 tc:RegisterEffect(e2)
		 tc=g:GetNext()
   end
end
function c20100015.distarget(e,c)
	return c:IsSetCard(0xb28) and c:IsFaceup()
end
function c20100015.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and c:IsSetCard(0xb28)
end