--一瞬华彩
function c11127175.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,11127175)
	e1:SetCondition(c11127175.condition)
	e1:SetTarget(c11127175.target)
	e1:SetOperation(c11127175.activate)
	c:RegisterEffect(e1)
end
function c11127175.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_FUSION) and c:IsLevelAbove(5) 
end
function c11127175.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c11127175.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	if not Duel.IsChainDisablable(ev) then return false end
	return rp==1-tp 
end
function c11127175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0) 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function c11127175.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then 
		Duel.BreakEffect()
		local p=1-tp  
		if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0xa62) end,tp,LOCATION_MZONE,0,3,nil) then p=tp end 
		local rg=Duel.SelectMatchingCard(p,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil) 
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end


