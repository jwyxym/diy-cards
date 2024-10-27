--“我们，都疯了”
function c20200015.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c20200015.condition)
	e1:SetTarget(c20200015.target)
	e1:SetOperation(c20200015.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c20200015.handcon)
	c:RegisterEffect(e2)
end
function c20200015.cfilter(c)
	return c:IsCode(20200003) and c:IsFaceup()
end
function c20200015.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
	and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(c20200015.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c20200015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function c20200015.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		Duel.SendtoDeck(ec,nil,2,REASON_EFFECT)
	end
end
function c20200015.handcon(e,c)
    return Duel.IsExistingMatchingCard(c20200015.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
