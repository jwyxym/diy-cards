--舞狮舞人午时无刻
function c11100107.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11100107)
	e1:SetTarget(c11100107.target)
	e1:SetOperation(c11100107.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11100107)
	e2:SetCondition(c11100107.condition)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c11100107.target2)
	e2:SetOperation(c11100107.operation)
	c:RegisterEffect(e2)
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(c11100107.handcon)
	c:RegisterEffect(e3)
end
function c11100107.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
function c11100107.filter(c)
	return c:IsSetCard(0xa64) and not c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function c11100107.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11100107.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c11100107.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11100107.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c11100107.filter1(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup() and c:IsSummonPlayer(tp)
end
function c11100107.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11100107.filter1,1,nil,tp)
end
function c11100107.setfilter(c)
	return c:IsSetCard(0xa64) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c11100107.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11100107.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c11100107.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c11100107.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end



