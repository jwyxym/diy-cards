--
function c19993026.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xb35),6,2)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19993026.con)
	e1:SetValue(c19993026.efilter)
	c:RegisterEffect(e1)
	--activate trap in hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19993026,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb35))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(c19993026.con)
	e2:SetValue(19993026)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19993026,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c19993026.discon)
	e3:SetOperation(c19993026.disop)
	c:RegisterEffect(e3)
end
function c19993026.con(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,19993005)
end
function c19993026.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c19993026.filter(c)
	return c:IsSetCard(0xb35) and c:IsType(TYPE_TRAP)
end
function c19993026.disfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:CheckRemoveOverlayCard(c:GetControler(),1,REASON_EFFECT)
end
function c19993026.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(c19993026.disfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():GetFlagEffect(19993026)<=0 and e:GetHandler():GetOverlayGroup():IsExists(c19993026.filter,1,nil)
end
function c19993026.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(19993026,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
		local tc=Duel.SelectMatchingCard(tp,c19993026.disfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
			Duel.Hint(HINT_CARD,0,19993026)
			Duel.NegateEffect(ev)
			e:GetHandler():RegisterFlagEffect(19993026,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19993026,4))
		end
	end
end