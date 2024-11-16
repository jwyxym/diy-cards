--
function c19990029.initial_effect(c)
	c:SetSPSummonOnce(19990029)
	--link summon
	aux.AddLinkProcedure(c,nil,2,nil,c19990029.lcheck)
	c:EnableReviveLimit()
	--atk up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c19990029.atkval)
	c:RegisterEffect(e0)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990029,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,19990029)
	e1:SetOperation(c19990029.effop)
	c:RegisterEffect(e1)
end
function c19990029.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0xb29)
end
function c19990029.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_PZONE)) and c:IsSetCard(0xb29)
end
function c19990029.atkval(e,c)
	return Duel.GetMatchingGroupCount(c19990029.cfilter,c:GetControler(),LOCATION_EXTRA+LOCATION_PZONE,0,nil)*200
end
function c19990029.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29)
end
function c19990029.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c19990029.filter,tp,LOCATION_ONFIELD,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end