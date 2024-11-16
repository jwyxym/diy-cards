--Numerical Sublimator
function c88188204.initial_effect(c)
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsSetCard,0xa590),nil,nil,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),1,99)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88188204,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88188204)
	e1:SetTarget(c88188204.rctg)
	e1:SetOperation(c88188204.rcop)
	c:RegisterEffect(e1)
end
c88188204.SetCard_Numerical_Crack=true 
function c88188204.rcfilter(c)
	return c:IsSetCard(0xa590) and c:IsAbleToHand()
end
function c88188204.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88188204.rcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c88188204.rcop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88188204.rcfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end