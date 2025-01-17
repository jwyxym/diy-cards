--神圣清晶
local s,id,o=GetID()
function s.initial_effect(c)
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--can't be disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.chainfilter)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.chainfilter)
	c:RegisterEffect(e4)
end
function s.cfilter(c,seq2)
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsCode(76200612) and seq1==4-seq2
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and loc==LOCATION_SZONE
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
function s.chainfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:GetActiveType()==TYPE_SPELL+TYPE_CONTINUOUS
end
