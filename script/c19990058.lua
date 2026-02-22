--
function c19990058.initial_effect(c)
	c:SetUniqueOnField(1,0,19990058)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19990058+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c19990058.activate)
	c:RegisterEffect(e1)
	--atk down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c19990058.val)
	c:RegisterEffect(e2)
end
function c19990058.thfilter(c)
	return c:IsSetCard(0xb30) and c:IsAbleToHand() and not c:IsCode(19990058)
end
function c19990058.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19990058.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19990058,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c19990058.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29)
end
function c19990058.val(e,c)
	return Duel.GetMatchingGroupCount(c19990058.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*(-200)
end