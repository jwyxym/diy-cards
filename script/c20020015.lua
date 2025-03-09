--
function c20020015.initial_effect(c)
	--xyz
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetDescription(aux.Stringid(20020014,1))
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e0:SetTarget(c20020015.xyztg)
	e0:SetOperation(c20020015.xyzop)
	c:RegisterEffect(e0)
	--synchro
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetDescription(aux.Stringid(20020014,0))
	e1:SetTarget(c20020015.sctg)
	e1:SetOperation(c20020015.scop)
	c:RegisterEffect(e1)
	--handes
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20020015,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,20020015)
	e3:SetCost(c20020015.hdcost)
	e3:SetCondition(c20020015.hdcon)
	e3:SetTarget(c20020015.hdtg)
	e3:SetOperation(c20020015.hdop)
	c:RegisterEffect(e3)
	--Effect monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
	--tuner
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_TUNER)
	e5:SetValue(c20020015.tnval)
	c:RegisterEffect(e5)
end
function c20020015.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
function c20020015.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20020015.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c20020015.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c20020015.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
function c20020015.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c20020015.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
function c20020015.cfilter(c,tp)
	return c:IsSetCard(0xb35) and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c20020015.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c20020015.cfilter,1,e:GetHandler(),tp) end
	local sg=Duel.SelectReleaseGroup(tp,c20020015.cfilter,1,1,e:GetHandler(),tp)
	Duel.Release(sg,REASON_COST)
end
function c20020015.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(c20020015.cfilter,1,nil,1-tp)
end
function c20020015.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function c20020015.hdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function c20020015.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end