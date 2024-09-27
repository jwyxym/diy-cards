--祭法之域
local m=21300103
local cm=_G["c"..m]
function c21300103.initial_effect(c)
	 local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	 local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.indtg)
	e2:SetValue(cm.indct)
	c:RegisterEffect(e2)
end
function cm.filter(c)
	return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function cm.filter2(c)
	return c:IsType(TYPE_LINK) 
end
function cm.indtg(e,c)
local g=Duel.GetMatchingGroup(cm.filter2,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return false end
   local tc=g:GetMaxGroup(Card.GetAttack):GetFirst()
	return c:GetAttack()==tc:GetAttack()
end
function cm.indct(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 
end




