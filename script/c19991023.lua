--从疯狂梦境苏醒的爱丽丝
function c19991023.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_FZONE+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19991023+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c19991023.activate)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsOriginalSetCard,0xb32))
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function c19991023.thfilter(c)
	return c:IsOriginalSetCard(0xb32) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToHand()
end
function c19991023.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19991023.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19991023,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

