--回归疯狂梦境的爱丽丝
function c19991011.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_SZONE+LOCATION_GRAVE)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetDescription(aux.Stringid(19991018,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19991011)
	e1:SetTarget(c19991011.tgtg)
	e1:SetOperation(c19991011.tgop)
	c:RegisterEffect(e1)
	--avoid battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c19991011.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function c19991011.tgfilter(c)
	return c:IsSetCard(0xb31) and c:IsAbleToGrave()
end
function c19991011.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19991011.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c19991011.thfilter(c)
	return c:IsCode(19991003) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c19991011.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19991011.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19991011.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19991011,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
function c19991011.target(e,c)
	return c:IsSetCard(0xb31)
end