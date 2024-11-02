--
function c19990023.initial_effect(c)
	--act in hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(c19990023.handcon)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCountLimit(1,19990023)
	e1:SetCost(c19990023.cost)
	e1:SetTarget(c19990023.target)
	e1:SetOperation(c19990023.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
function c19990023.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function c19990023.handcon(e,c)
	return Duel.IsExistingMatchingCard(c19990023.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c19990023.cfilter(c)
	return c:IsSetCard(0xb29) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c19990023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19990023.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,c19990023.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c19990023.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function c19990023.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end