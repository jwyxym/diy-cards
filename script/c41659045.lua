--唱晓的少女·诺克图娜
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--灵摆①
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,10))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id+30000)
	e1:SetCost(s.pcost)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	--灵摆②
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.racetg)
	e2:SetValue(RACE_SPELLCASTER)
	c:RegisterEffect(e2)
	--①
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCondition(s.facecon)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.top)
	c:RegisterEffect(e3)
	--②
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.ecxcon)
	e4:SetCost(s.ecxcost)
	e4:SetTarget(s.ecxtg)
	e4:SetOperation(s.ecxop)
	c:RegisterEffect(e4)
end
function s.racetg(e,c)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and aux.GetColumn(c)==aux.GetColumn(e:GetHandler())
end
--灵摆①
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)
end
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoExtraP(g,nil,REASON_COST)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
--①
function s.facecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_HAND) or c:IsFaceup()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
end
function s.top(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local wiz=c:IsRace(RACE_SPELLCASTER)
	if not Duel.SendtoExtraP(c,nil,REASON_EFFECT) then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_SPELLCASTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	if not wiz then return end
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,id+20000)
	e2:SetValue(s.pendvalue)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.pendvalue(e,c)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER)
end
--②
function s.ecxcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return false end
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	return rc:IsSetCard(0xe99) and rc:IsRace(RACE_SPELLCASTER)
		and rc:IsControler(tp) and rc:IsLocation(LOCATION_MZONE)
end
--回手作为cost
function s.ecxcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SendtoHand(c,nil,REASON_COST)
	Duel.ConfirmCards(1-tp,c)
end
function s.ecxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.ecxop(e,tp,eg,ep,ev,re,r,rp)
	s.exop(e,tp,e:GetHandler())
end
--回手后的效果（陷阱②也适用这部分）
function s.exop(e,tp,ec)
	Duel.Draw(tp,1,REASON_EFFECT)
end
_G.KETSUBA_EXTRA_EFFECTS=_G.KETSUBA_EXTRA_EFFECTS or {}
_G.KETSUBA_EXTRA_EFFECTS[id]=s.exop
_G.KETSUBA_EXTRA_EFFECTS[41659020]=s.exop
