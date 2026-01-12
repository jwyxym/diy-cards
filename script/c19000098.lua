--
function c19000098.initial_effect(c)
	--Activate(Effect)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetCountLimit(1,19000098)
	e0:SetCondition(c19000098.condition)
	e0:SetTarget(aux.nbtg)
	e0:SetOperation(c19000098.activate2)
	c:RegisterEffect(e0)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCountLimit(1,19000098)
	e1:SetCondition(c19000098.condition)
	e1:SetTarget(c19000098.target1)
	e1:SetOperation(c19000098.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
function c19000098.cfilter(c)
	return c:IsFaceup() and (c:IsLevel(9) or c:IsRank(9))
end
function c19000098.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19000098.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function c19000098.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function c19000098.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
function c19000098.activate1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end