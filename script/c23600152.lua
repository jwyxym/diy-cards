--骸孽孤灯
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x0d88,LOCATION_SZONE)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.counterop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.negcon)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetCondition(s.efcon)
	e6:SetTarget(s.eftg)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xd87)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xd87)
end
function s.thfilter(c)
	return c:IsSetCard(0xd87) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
		and re:GetHandler():IsSetCard(0xd88) and rp==tp
		and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0xd88,1)
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_FUSION) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsCanRemoveCounter(tp,1,0,0xd88,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,1,0,0xd88,1,REASON_EFFECT)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_FUSION)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL)
		and Duel.IsCanRemoveCounter(tp,1,0,0xd88,2,REASON_EFFECT)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		Duel.RemoveCounter(tp,1,0,0xd88,1,REASON_EFFECT)
	end
end
function s.efcon(e)
	return e:GetHandler():GetCounter(0xd88)>2
end
function s.eftg(e,c)
	return c:IsSetCard(0xd87) and c:IsType(TYPE_FUSION)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end