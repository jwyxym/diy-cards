--
function c19990005.initial_effect(c)
	c:SetUniqueOnField(1,0,19990005)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19990005+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c19990005.activate)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb29))
	e2:SetValue(c19990005.val)
	c:RegisterEffect(e2)
end
function c19990005.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xb29) and c:IsAbleToHand()
end
function c19990005.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19990005.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19990005,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c19990005.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29)
end
function c19990005.val(e,c)
	return Duel.GetMatchingGroupCount(c19990005.filter,c:GetControler(),LOCATION_MZONE,0,nil)*100
end
