--极巧机冶·精锻
function c11100215.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11100215+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c11100215.cost)
	e1:SetTarget(c11100215.target)
	e1:SetOperation(c11100215.activate)
	c:RegisterEffect(e1)
end
function c11100215.cfilter(c)
	return c:IsDiscardable() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and aux.AtkEqualsDef(c)
end
function c11100215.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11100215.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c11100215.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c11100215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c11100215.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end