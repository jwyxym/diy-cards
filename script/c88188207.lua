--Data rearrangement
function c88188207.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88188207+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c88188207.target)
	e1:SetOperation(c88188207.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c88188207.op)
	c:RegisterEffect(e2)
end
c88188207.SetCard_Numerical_Crack=true 
function c88188207.filter(c)
	return c:IsSetCard(0xa590) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c88188207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88188207.filter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function c88188207.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c88188207.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c88188207.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
end