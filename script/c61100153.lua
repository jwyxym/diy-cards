-- 61100153（通常为速攻魔法或反击陷阱，支持连锁响应）
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local cf1=re:IsHasType(EFFECT_TYPE_TRIGGER_F)
	local cf2=re:IsHasType(EFFECT_TYPE_QUICK_F)
	return ep==tp and Duel.IsChainNegatable(ev) and not (cf1 or cf2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=Duel.GetChainInfo(ev,CHAININFO_TARGET_PARAM)
	local tp=Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER)
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(te)
	if tc~=nil then Duel.SetTargetCard(tc) else end
	Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		local ec=eg:GetFirst()
		ec:CancelToGrave()
		if Duel.SendtoHand(ec,c:GetControler(),REASON_EFFECT) then
			local operation=re:GetOperation()
			operation(re,1-c:GetControler(),nil,0,0,0,0,0)
		end
	end
end
		
