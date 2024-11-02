--妖刀姬-樱雨刀舞
function c51200140.initial_effect(c)
	c:SetSPSummonOnce(51200140)
	--召唤条件
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),5,2,c51200140.ovfilter,aux.Stringid(51200140,0))
	c:EnableReviveLimit()
	--特招限制
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	--战破抗性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c51200140.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--魔陷康
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31000112,2))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCost(c51200140.cost)
	e4:SetCondition(c51200140.discon)
	e4:SetTarget(c51200140.distg)
	e4:SetOperation(c51200140.disop)
	c:RegisterEffect(e4)
end
	function c51200140.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x65d) and c:IsType(TYPE_LINK)
end
	function c51200140.indcon(e)
	return e:GetHandler():IsAttackPos()
end
	function c51200140.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
	function c51200140.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
	function c51200140.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
	function c51200140.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end