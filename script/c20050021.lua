--梦想与回忆
function c20050021.initial_effect(c)
	c:SetUniqueOnField(1,0,20050021)
	aux.AddCodeList(c,19000032)
	--Activate MoveToPzone
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20050021,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e0:SetCountLimit(1,20050021+EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(c20050021.target)
	e0:SetOperation(c20050021.activate)
	e0:SetValue(c20050021.zones)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20050021,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c20050021.con)
	e1:SetTarget(c20050021.tg)
	e1:SetOperation(c20050021.op)
	c:RegisterEffect(e1)
	--reduce tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20050021,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c20050021.ntcon)
	e3:SetTarget(c20050021.nttg)
	c:RegisterEffect(e3)
end
function c20050021.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	if not b or p0 and p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
function c20050021.penfilter(c)
	return c:IsCode(19000032) and c:IsType(TYPE_PENDULUM)
		and not c:IsForbidden() and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or c:IsFaceup())
end
function c20050021.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(c20050021.penfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function c20050021.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c20050021.penfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c20050021.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==19000032 and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp)
end
function c20050021.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20050021.cfilter,1,nil,tp)
end
function c20050021.thfilter(c)
	return aux.IsCodeListed(c,19000032) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c20050021.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20050021.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c20050021.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,c20050021.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
function c20050021.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c20050021.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION)
end