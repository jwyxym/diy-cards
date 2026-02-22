--
function c19990057.initial_effect(c)
	--Activate MoveToPzone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990057,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,19990057)
	e1:SetTarget(c19990057.target)
	e1:SetOperation(c19990057.activate)
	e1:SetValue(c19990057.zones)
	c:RegisterEffect(e1)
	--extra pendulum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990057,3))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,19990057+100)
	e2:SetCost(c19990057.expcost)
	e2:SetTarget(c19990057.exptg)
	e2:SetOperation(c19990057.expop)
	c:RegisterEffect(e2)
end
function c19990057.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	if not b or p0 and p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
function c19990057.penfilter(c)
	return c:IsSetCard(0xb29) and c:IsType(TYPE_PENDULUM)
		and not c:IsForbidden()
end
function c19990057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(c19990057.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function c19990057.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c19990057.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c19990057.costfilter(c,tp)
	return c:IsSetCard(0xb29,0xb30) and c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
end
function c19990057.expcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990057.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19990057.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19990057.exptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,19990057)==0 end
end
function c19990057.expop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990057,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,19990057+200)
	e1:SetValue(c19990057.pendvalue)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,19990057,RESET_PHASE+PHASE_END,0,1)
end
function c19990057.pendvalue(e,c)
	return c:IsSetCard(0xb29)
end