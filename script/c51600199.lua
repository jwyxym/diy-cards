--魔姬之城 洛克维希
function c51600199.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51600199+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c51600199.activate)
	c:RegisterEffect(e1)
	--limit attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c51600199.condition)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c51600199.alimit)
	c:RegisterEffect(e3)

end


function c51600199.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x910) and c:IsAbleToHand()
end
function c51600199.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c51600199.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(51600199,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function c51600199.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x910)
end
function c51600199.condition(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c51600199.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
function c51600199.alimit(e,c)
	return c:IsFacedown() or not (c:IsType(TYPE_FUSION) and c:IsSetCard(0x910))
end
