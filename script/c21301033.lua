--墨染乐章 乱奏
function c21301033.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,21301033)
	e1:SetCondition(c21301033.condition)
	e1:SetTarget(c21301033.target)
	e1:SetOperation(c21301033.activate)
	c:RegisterEffect(e1) 
	--to grave 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21301033)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21301033.tgtg)
	e2:SetOperation(c21301033.tgop)
	c:RegisterEffect(e2)
end
function c21301033.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x682)
end
function c21301033.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c21301033.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	return true 
end
function c21301033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0) 
end
function c21301033.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x682) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21301033,0)) then
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil) 
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT) 
	end
end
function c21301033.tgfil(c) 
	return c:IsSetCard(0x682) and not c:IsCode(21301033) 
end 
function c21301033.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301033.tgfil,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED) 
end
function c21301033.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c21301033.tgfil,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst() 
	if tc then 
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end 
end 



