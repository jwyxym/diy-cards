--血商的债务清算者
local s,id,o=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ccon)
	e2:SetOperation(s.cop)
	c:RegisterEffect(e2)
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
end
s.counter_add_list={0x1704}
function s.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1704)>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER)
end
function s.ccfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanAddCounter(0x1041,1)
end
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.ccfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1704,1)
		tc=g:GetNext()
	end
end
function s.checkcounter()
	local total=0
	local g=Duel.GetMatchingGroup(nil,0,0xff,0xff,nil)
	local tc=g:GetFirst()
	while tc do
		total=total+tc:GetCounter(0x1704)
		tc=g:GetNext()
	end
	return total>=3
end
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	if not s.checkcounter() then return false end
	if Duel.IsChainSolving() then return false end
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	if ct==0 then return false end
	return re and re:GetHandlerPlayer()==1-tp and re:GetOwnerPlayer()==1-tp
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	if ct>0 then
		Duel.Damage(1-tp,ct*600,REASON_EFFECT)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	if not s.checkcounter() then return false end
	if not Duel.IsChainSolving() then return false end
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	if ct==0 then return false end
	return re and re:GetHandlerPlayer()==1-tp and re:GetOwnerPlayer()==1-tp
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL+RESET_CHAIN,0,1,ct)
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 and s.checkcounter()
end

function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local labels={e:GetHandler():GetFlagEffectLabel(id)}
	local total=0
	for i=1,#labels do total=total+labels[i] end
	e:GetHandler():ResetFlagEffect(id)
	if total>0 then
		Duel.Damage(1-tp,total*600,REASON_EFFECT)
	end
end
